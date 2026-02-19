# frozen_string_literal: true

require "openssl"
require "securerandom"
require "uri"

class Totp
  PERIOD = 30
  DIGITS = 6
  ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

  class << self
    def generate_secret(bytes: 20)
      base32_encode(SecureRandom.random_bytes(bytes))
    end

    def verify?(secret, code, now: Time.current, drift: 1)
      normalized = normalize_code(code)
      return false unless normalized.match?(/\A\d{#{DIGITS}}\z/)

      (-drift..drift).any? do |offset|
        secure_compare(normalized, at(secret, now + (offset * PERIOD)))
      end
    rescue ArgumentError
      false
    end

    def at(secret, at_time)
      counter = (at_time.to_i / PERIOD).floor
      hotp(secret, counter)
    end

    def otpauth_uri(secret:, account_name:, issuer:)
      label = "#{issuer}:#{account_name}"
      "otpauth://totp/#{uri_escape(label)}?secret=#{secret}&issuer=#{uri_escape(issuer)}&algorithm=SHA1&digits=#{DIGITS}&period=#{PERIOD}"
    end

    def generate_backup_codes(count: 10)
      Array.new(count) { SecureRandom.alphanumeric(10).upcase.scan(/.{1,5}/).join("-") }
    end

    private

    def hotp(secret, counter)
      key = base32_decode(secret.to_s)
      msg = [counter].pack("Q>")
      digest = OpenSSL::HMAC.digest("sha1", key, msg)
      offset = digest.bytes.last & 0x0f
      bin_code = digest.byteslice(offset, 4).unpack1("N") & 0x7fffffff
      (bin_code % (10**DIGITS)).to_s.rjust(DIGITS, "0")
    end

    def base32_encode(bytes)
      bits = bytes.unpack1("B*")
      bits += "0" * ((5 - bits.length % 5) % 5)
      bits.scan(/.{5}/).map { |chunk| ALPHABET[chunk.to_i(2)] }.join
    end

    def base32_decode(str)
      cleaned = str.upcase.gsub(/[^A-Z2-7]/, "")
      raise ArgumentError, "empty base32 secret" if cleaned.empty?

      bits = cleaned.chars.map do |char|
        idx = ALPHABET.index(char)
        raise ArgumentError, "invalid base32 character" if idx.nil?
        idx.to_s(2).rjust(5, "0")
      end.join

      bits = bits[0, bits.length - (bits.length % 8)]
      [bits].pack("B*")
    end

    def normalize_code(code)
      code.to_s.delete(" \t-")
    end

    def uri_escape(value)
      URI.encode_www_form_component(value.to_s)
    end

    def secure_compare(a, b)
      ActiveSupport::SecurityUtils.secure_compare(a, b)
    rescue ArgumentError
      false
    end
  end
end
