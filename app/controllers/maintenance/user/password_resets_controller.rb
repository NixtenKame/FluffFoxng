# frozen_string_literal: true

module Maintenance
  module User
    class PasswordResetsController < ApplicationController
      def new
        @reset_name = ""
      end

      def edit
        redirect_to new_maintenance_user_password_reset_path, notice: "Token reset links are disabled. Use your authenticator code to reset your password."
      end

      def create
        if RateLimiter.check_limit("password_reset:#{request.remote_ip}", 5, 1.hour)
          return redirect_to new_maintenance_user_password_reset_path, notice: "Too many reset attempts. Please wait and try again."
        end

        name = params[:name].to_s.strip
        otp_code = params[:otp_code].to_s
        password = params[:password].to_s
        password_confirm = params[:password_confirm].to_s
        @reset_name = name

        user = ::User.find_by_name(name)
        if user.nil? || !user.otp_enabled?
          return redirect_to new_maintenance_user_password_reset_path, notice: "Invalid username or authenticator code."
        end

        unless user.verify_two_factor_code(otp_code)
          return redirect_to new_maintenance_user_password_reset_path, notice: "Invalid username or authenticator code."
        end

        if password != password_confirm
          return redirect_to new_maintenance_user_password_reset_path, notice: "Passwords do not match."
        end

        if password.length < 8
          return redirect_to new_maintenance_user_password_reset_path, notice: "Password must be at least 8 characters."
        end

        user.upgrade_password(password)
        redirect_to new_session_path, notice: "Password reset. You can now log in."
      end

      def update
        redirect_to new_maintenance_user_password_reset_path, notice: "Token reset links are disabled. Use your authenticator code to reset your password."
      end
    end
  end
end
