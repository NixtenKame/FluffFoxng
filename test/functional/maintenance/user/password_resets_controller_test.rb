# frozen_string_literal: true

require "test_helper"

module Maintenance
  module User
    class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
      context "A password resets controller" do
        setup do
          @user = create(:user, email: "abc@com.net")
          ActionMailer::Base.delivery_method = :test
          ActionMailer::Base.deliveries.clear
        end

        should "render the new page" do
          get new_maintenance_user_password_reset_path
          assert_response :success
        end

        context "when password_reset_show_link is disabled" do
          setup do
            Danbooru.config.stubs(:password_reset_show_link?).returns(false)
            @secret = Totp.generate_secret
            @user.enable_two_factor!(secret: @secret, backup_codes: Totp.generate_backup_codes(count: 2))
          end

          context "create action" do
            context "given invalid parameters" do
              setup do
                post maintenance_user_password_reset_path, params: { name: "", otp_code: "", password: "password123", password_confirm: "password123" }
              end

              should "redirect to the new page" do
                assert_redirected_to new_maintenance_user_password_reset_path
              end
            end

            context "given an invalid authenticator code" do
              setup do
                @old_password = @user.bcrypt_password_hash
                post maintenance_user_password_reset_path, params: {
                  name: @user.name,
                  otp_code: "000000",
                  password: "newpassword123",
                  password_confirm: "newpassword123",
                }
              end

              should "not reset the password" do
                @user.reload
                assert_equal(@old_password, @user.bcrypt_password_hash)
              end

              should "redirect to the new page" do
                assert_redirected_to new_maintenance_user_password_reset_path
              end
            end

            context "given valid parameters" do
              setup do
                @old_password = @user.bcrypt_password_hash
                post maintenance_user_password_reset_path, params: {
                  name: @user.name,
                  otp_code: Totp.at(@secret, Time.current),
                  password: "newpassword123",
                  password_confirm: "newpassword123",
                }
              end

              should "change the password" do
                @user.reload
                assert_not_equal(@old_password, @user.bcrypt_password_hash)
              end

              should "redirect to login page" do
                assert_redirected_to new_session_path
              end
            end
          end

          context "edit action" do
            setup do
              get edit_maintenance_user_password_reset_path, params: { uid: @user.id, key: "x" }
            end

            should "redirect to new reset page" do
              assert_redirected_to new_maintenance_user_password_reset_path
            end
          end

          context "update action" do
            setup do
              put maintenance_user_password_reset_path, params: { uid: @user.id.to_s, key: "x", password: "test12345", password_confirm: "test12345" }
            end

            should "redirect to new reset page" do
              assert_redirected_to new_maintenance_user_password_reset_path
            end
          end
        end

        context "when password_reset_show_link is enabled" do
          setup do
            Danbooru.config.stubs(:password_reset_show_link?).returns(true)
          end

          context "create action" do
            context "given an unknown email" do
              setup do
                @old_password = @user.bcrypt_password_hash
                post maintenance_user_password_reset_path, params: {
                  email: "missing@example.com",
                  password: "newpassword123",
                  password_confirm: "newpassword123",
                }
              end

              should "not reset the password" do
                @user.reload
                assert_equal(@old_password, @user.bcrypt_password_hash)
              end

              should "redirect to the new page" do
                assert_redirected_to new_maintenance_user_password_reset_path
              end
            end

            context "given a valid email" do
              setup do
                @old_password = @user.bcrypt_password_hash
                post maintenance_user_password_reset_path, params: {
                  email: @user.email,
                  password: "newpassword123",
                  password_confirm: "newpassword123",
                }
              end

              should "change the password" do
                @user.reload
                assert_not_equal(@old_password, @user.bcrypt_password_hash)
              end

              should "redirect to login page" do
                assert_redirected_to new_session_path
              end
            end
          end

          context "edit action" do
            setup do
              get edit_maintenance_user_password_reset_path, params: { uid: @user.id, key: "x" }
            end

            should "redirect to new reset page" do
              assert_redirected_to new_maintenance_user_password_reset_path
            end
          end

          context "update action" do
            setup do
              put maintenance_user_password_reset_path, params: {
                uid: @user.id.to_s,
                key: "x",
                password: "test12345",
                password_confirm: "test12345",
              }
            end

            should "redirect to new reset page" do
              assert_redirected_to new_maintenance_user_password_reset_path
            end
          end
        end
      end
    end
  end
end
