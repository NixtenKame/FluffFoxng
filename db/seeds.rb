# frozen_string_literal: true

require "digest/md5"
require "net/http"
require "tempfile"

# Uncomment to see detailed logs
# ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)

admin = User.find_or_create_by!(name: "admin") do |user|
  user.created_at = 2.weeks.ago
  user.password = "fluffyfox"
  user.password_confirmation = "fluffyfox"
  user.password_hash = ""
  user.email = "admin@flufffox.local"
  user.can_upload_free = true
  user.can_approve_posts = true
  user.level = User::Levels::ADMIN
end

User.find_or_create_by!(name: Danbooru.config.system_user) do |user|
  user.password = "ae3n4oie2n3oi4en23oie4noienaorshtaioresnt"
  user.password_confirmation = "ae3n4oie2n3oi4en23oie4noienaorshtaioresnt"
  user.password_hash = ""
  user.email = "system@flufffox.local"
  user.can_upload_free = true
  user.can_approve_posts = true
  user.level = User::Levels::JANITOR
end

ForumCategory.find_or_create_by!(name: "Tag Alias and Implication Suggestions") do |category|
  category.can_view = 0
end

def api_request(path)
  response = Faraday.get("https://nixten.ddns.net#{path}", nil, user_agent: "FluffFox/seeding")
  JSON.parse(response.body)
end

def setup_upload_whitelist
  UploadWhitelist.create do |entry|
    entry.domain = "nixten\\.ddns\\.net:9001" # rubocop:disable Style/RedundantStringEscape
  end
end

def setup_report_reasons
  PostReportReason.create!(reason: "Malicious File", description: "The file contains either malicious code or contains a hidden file archive. This is not for imagery depicted in the image itself.")
end

unless Rails.env.test?
  CurrentUser.user = admin
  CurrentUser.ip_addr = "127.0.0.1"
  begin
    setup_upload_whitelist
    setup_report_reasons
  rescue StandardError => e
    puts "--------"
    puts "#{e.class}: #{e.message}"
    puts "Failure during seeding, continuing on..."
    puts "--------"
  end
end
