# frozen_string_literal: true

module Maintenance
  module User
    class TwoFactorsController < ApplicationController
      before_action :member_only

      def show
        @backup_codes = flash[:two_factor_backup_codes] || []
      end

      def new
        if CurrentUser.user.otp_enabled?
          return redirect_to maintenance_user_two_factor_path, notice: "Two-factor authentication is already enabled."
        end

        @secret = pending_secret
        @otpauth_uri = build_otpauth_uri(@secret)
      end

      def create
        secret = pending_secret
        code = params[:otp_code].to_s

        unless Totp.verify?(secret, code)
          @secret = secret
          @otpauth_uri = build_otpauth_uri(secret)
          flash.now[:notice] = "Invalid authentication code. Try again."
          return render :new, status: :unprocessable_entity
        end

        backup_codes = Totp.generate_backup_codes
        CurrentUser.user.enable_two_factor!(secret: secret, backup_codes: backup_codes)
        session.delete(:pending_otp_secret)
        flash[:two_factor_backup_codes] = backup_codes
        redirect_to maintenance_user_two_factor_path, notice: "Two-factor authentication has been enabled."
      end

      def regenerate_backup_codes
        unless CurrentUser.user.otp_enabled?
          return redirect_to new_maintenance_user_two_factor_path, notice: "Enable two-factor first."
        end

        unless CurrentUser.user.verify_two_factor_code(params[:otp_code].to_s)
          return redirect_to maintenance_user_two_factor_path, notice: "Invalid authentication code."
        end

        backup_codes = Totp.generate_backup_codes
        CurrentUser.user.set_two_factor_backup_codes!(backup_codes)
        flash[:two_factor_backup_codes] = backup_codes
        redirect_to maintenance_user_two_factor_path, notice: "Backup codes regenerated."
      end

      def skip
        if CurrentUser.user.otp_enabled?
          return redirect_to maintenance_user_two_factor_path, notice: "Two-factor is already enabled."
        end

        CurrentUser.user.update!(otp_required_for_login: false)
        session.delete(:pending_otp_secret)
        redirect_to posts_path, notice: "Two-factor setup skipped. You can enable it later in settings."
      end

      private

      def pending_secret
        session[:pending_otp_secret] ||= Totp.generate_secret
      end

      def build_otpauth_uri(secret)
        Totp.otpauth_uri(
          secret: secret,
          account_name: CurrentUser.user.name,
          issuer: Danbooru.config.app_name
        )
      end
    end
  end
end
