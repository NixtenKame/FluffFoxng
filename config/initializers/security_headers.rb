# frozen_string_literal: true

Rails.application.configure do
  config.action_dispatch.default_headers = config.action_dispatch.default_headers.merge(
    "X-Content-Type-Options" => "nosniff",
    "X-Frame-Options" => "SAMEORIGIN",
    "Referrer-Policy" => "strict-origin-when-cross-origin",
    "Permissions-Policy" => "geolocation=(), microphone=(), camera=()"
  )
end
