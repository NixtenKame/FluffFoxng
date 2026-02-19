# frozen_string_literal: true

require "test_helper"

class TotpTest < ActiveSupport::TestCase
  test "it generates and verifies totp codes" do
    secret = Totp.generate_secret
    code = Totp.at(secret, Time.current)

    assert_equal true, Totp.verify?(secret, code)
    assert_equal false, Totp.verify?(secret, "000000")
  end

  test "it generates backup codes" do
    codes = Totp.generate_backup_codes(count: 5)
    assert_equal 5, codes.length
    assert_equal 5, codes.uniq.length
  end
end
