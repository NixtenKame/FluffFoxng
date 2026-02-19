# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    sparams = params.fetch(:session, {}).slice(:url, :name, :password, :remember, :otp_code)
    if RateLimiter.check_limit("login:#{request.remote_ip}", 15, 12.hours)
      DanbooruLogger.add_attributes("user.login" => "rate_limited")
      return redirect_to(new_session_path, notice: "Username/Password was incorrect")
    end
    session_creator = SessionCreator.new(request, session, cookies, sparams[:name], sparams[:password], sparams[:remember].to_s.truthy?)

    if session_creator.authenticate
      user = session_creator.user
      if user.otp_enabled? && !user.verify_two_factor_code(sparams[:otp_code])
        session.delete(:user_id)
        session.delete(:ph)
        session.delete(:last_authenticated_at)
        cookies.delete(:remember)
        RateLimiter.hit("login:#{request.remote_ip}", 6.hours)
        DanbooruLogger.add_attributes("user.login" => "fail_otp")
        return redirect_back(fallback_location: new_session_path, notice: "Username/Password was incorrect")
      end

      url = sparams[:url] if sparams[:url] && sparams[:url].start_with?("/") && !sparams[:url].start_with?("//")
      DanbooruLogger.add_attributes("user.login" => "success")
      if user.otp_setup_required?
        redirect_to(new_maintenance_user_two_factor_path, notice: "Set up authenticator app login to continue.")
      else
        redirect_to(url || posts_path)
      end
    else
      RateLimiter.hit("login:#{request.remote_ip}", 6.hours)
      DanbooruLogger.add_attributes("user.login" => "fail")
      redirect_back(fallback_location: new_session_path, notice: "Username/Password was incorrect")
    end
  end

  def destroy
    session.delete(:user_id)
    cookies.delete(:remember)
    session.delete(:last_authenticated_at)
    redirect_to(posts_path, notice: "You are now logged out")
  end

  def confirm_password
  end
end
