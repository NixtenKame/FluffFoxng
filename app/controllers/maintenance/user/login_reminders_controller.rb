# frozen_string_literal: true

module Maintenance
  module User
    class LoginRemindersController < ApplicationController
      def new
        @matched_usernames = []
      end

      def create
        email = params.dig(:user, :email).to_s.strip
        users = ::User.with_email(email)
        @matched_usernames = users.map(&:name)

        flash.now[:notice] = if @matched_usernames.any?
                               "Found #{@matched_usernames.size} account(s) for that email."
                             else
                               "No account found for that email."
                             end
        render :new
      end
    end
  end
end
