# frozen_string_literal: true

# Webpush 1.1.0 uses mutable OpenSSL::PKey::EC setters that break on OpenSSL 3.
# This patch builds an EC key from raw VAPID keys without using setters.

require "base64"
require "webpush"

module Webpush
  class VapidKey
    def initialize
      if OpenSSL::OPENSSL_VERSION_NUMBER >= 0x30000000
        @curve = OpenSSL::PKey::EC.generate("prime256v1")
      else
        @curve = OpenSSL::PKey::EC.new("prime256v1")
        @curve.generate_key
      end
    end

    class << self
      alias_method :from_keys_without_openssl3, :from_keys
      alias_method :from_pem_without_openssl3, :from_pem

      def from_keys(public_key, private_key)
        if openssl3?
          build_from_raw_keys(public_key, private_key)
        else
          from_keys_without_openssl3(public_key, private_key)
        end
      end

      def from_pem(pem)
        if openssl3?
          build_from_pem(pem)
        else
          from_pem_without_openssl3(pem)
        end
      end

      private

      def openssl3?
        OpenSSL::OPENSSL_VERSION_NUMBER >= 0x30000000
      end

      def build_from_pem(pem)
        key = OpenSSL::PKey.read(pem)
        instance = allocate
        instance.instance_variable_set(:@curve, key)
        instance
      end

      def build_from_raw_keys(public_key, private_key)
        group = OpenSSL::PKey::EC::Group.new("prime256v1")
        priv_bytes = Webpush.decode64(private_key)
        pub_bytes = Webpush.decode64(public_key)

        # ECPrivateKey ASN.1 structure:
        # SEQUENCE { INTEGER 1, OCTET STRING (private), [0] OID (curve), [1] BIT STRING (public) }
        params = OpenSSL::ASN1::ObjectId.new(group.curve_name, 0, :EXPLICIT)
        pub = OpenSSL::ASN1::BitString.new(pub_bytes, 1, :EXPLICIT)
        seq = OpenSSL::ASN1::Sequence.new([
          OpenSSL::ASN1::Integer.new(1),
          OpenSSL::ASN1::OctetString.new(priv_bytes),
          params,
          pub
        ])
        der = seq.to_der
        pem = "-----BEGIN EC PRIVATE KEY-----\n#{Base64.encode64(der)}-----END EC PRIVATE KEY-----\n"

        build_from_pem(pem)
      end
    end
  end
end

module Webpush
  module Encryption
    class << self
      alias_method :encrypt_without_openssl3, :encrypt

      def encrypt(message, p256dh, auth)
        return encrypt_without_openssl3(message, p256dh, auth) unless OpenSSL::OPENSSL_VERSION_NUMBER >= 0x30000000

        assert_arguments(message, p256dh, auth)

        group_name = "prime256v1"
        salt = Random.new.bytes(16)

        server = OpenSSL::PKey::EC.generate(group_name)
        server_public_key_bn = server.public_key.to_bn

        group = OpenSSL::PKey::EC::Group.new(group_name)
        client_public_key_bn = OpenSSL::BN.new(Webpush.decode64(p256dh), 2)
        client_public_key = OpenSSL::PKey::EC::Point.new(group, client_public_key_bn)

        shared_secret = server.dh_compute_key(client_public_key)

        client_auth_token = Webpush.decode64(auth)

        info = "WebPush: info\0" + client_public_key_bn.to_s(2) + server_public_key_bn.to_s(2)
        content_encryption_key_info = "Content-Encoding: aes128gcm\0"
        nonce_info = "Content-Encoding: nonce\0"

        prk = HKDF.new(shared_secret, salt: client_auth_token, algorithm: "SHA256", info: info).next_bytes(32)

        content_encryption_key = HKDF.new(prk, salt: salt, info: content_encryption_key_info).next_bytes(16)

        nonce = HKDF.new(prk, salt: salt, info: nonce_info).next_bytes(12)

        ciphertext = encrypt_payload(message, content_encryption_key, nonce)

        serverkey16bn = convert16bit(server_public_key_bn)
        rs = ciphertext.bytesize
        raise ArgumentError, "encrypted payload is too big" if rs > 4096

        aes128gcmheader = "#{salt}" + [rs].pack("N*") + [serverkey16bn.bytesize].pack("C*") + serverkey16bn

        aes128gcmheader + ciphertext
      end
    end
  end
end
