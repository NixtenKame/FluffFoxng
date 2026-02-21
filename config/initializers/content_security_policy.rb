# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    posthog_origin = begin
      posthog_host = Danbooru.config.posthog_api_host.presence
      if posthog_host.present?
        uri = URI.parse(posthog_host)
        "#{uri.scheme}://#{uri.host}#{":#{uri.port}" if uri.port.present? && ![80, 443].include?(uri.port)}"
      end
    rescue URI::InvalidURIError
      nil
    end
    posthog_assets_origin = posthog_origin&.sub(".i.posthog.com", "-assets.i.posthog.com")

    data_origin = begin
      data_url = ENV["DANBOORU_DATA_BASE_URL"].presence
      if data_url.present?
        uri = URI.parse(data_url)
        "#{uri.scheme}://#{uri.host}#{":#{uri.port}" if uri.port.present? && ![80, 443].include?(uri.port)}"
      end
    rescue URI::InvalidURIError
      nil
    end

    script_sources = [
      :self,
      "https://www.google.com/recaptcha/",
      "https://www.gstatic.com/recaptcha/",
      "https://www.recaptcha.net/",
      "https://assets.freespeechcoalition.com",
      "https://kit.fontawesome.com",
    ]
    script_sources << posthog_origin if posthog_origin.present?
    script_sources << posthog_assets_origin if posthog_assets_origin.present?

    connect_sources = [
      :self,
      "api.freespeechcoalition.com",
      "https://api.lanyard.rest",
    ]
    connect_sources << posthog_origin if posthog_origin.present?

    policy.default_src :self
    policy.script_src(*script_sources)
    policy.script_src(*policy.script_src, :unsafe_eval) if Rails.env.development?

    policy.style_src :self, :unsafe_inline

    policy.connect_src(*connect_sources)
    policy.connect_src(*policy.connect_src, "ws://localhost:3036", "http://localhost:3036", "https://api.lanyard.rest") if Rails.env.development?

    media_sources = [:self, "nixten.ddns.net:9001"]
    media_sources << data_origin if data_origin.present?

    image_sources = [:self, :data, "https://cdn.discordapp.com", "https://discord.com", "https://nixten.ddns.net:9001"]
    image_sources << data_origin if data_origin.present?

    policy.object_src  :none
    policy.media_src(*media_sources)
    policy.frame_ancestors :self
    policy.frame_src   "https://www.google.com/recaptcha/", "https://www.recaptcha.net/", "https://discord.com"
    policy.font_src    :self
    policy.img_src(*image_sources)
    policy.child_src   :none
    policy.form_action :self, "https://discord.com"
    policy.base_uri :self
    policy.worker_src :self, "blob:"
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = false
end
