# frozen_string_literal: true

# Bootstrap missing WikiPage and HelpPage records used by the app.
# Run with:
#   bundle exec rails runner scripts/bootstrap_wiki_and_help_docs.rb

def pick_actor
  User.where(level: User::Levels::ADMIN).order(:id).first ||
    User.where(level: User::Levels::MODERATOR).order(:id).first ||
    User.find_by(name: "auto_moderator") ||
    User.order(:id).first
end

FOOTER = "© 2026 FluffFox Community. All rights reserved."

def topic_from_title(raw_title)
  WikiPage.normalize_name(raw_title).to_s
end

def default_doc_body(raw_title)
  topic = topic_from_title(raw_title)
  <<~TEXT.strip
    h2. #{topic.tr("_", " ").tr(":", " - ").split.map(&:capitalize).join(" ")}

    This page documents how FluffFox handles "#{topic}".

    h3. Summary
    * Purpose: explain the feature and expected behavior.
    * Scope: who is affected and what actions are allowed.
    * Enforcement: staff may update this policy as needed.

    h3. Notes
    * This is a starter document generated during site bootstrap.
    * Replace this text with your final production policy content.
  TEXT
end

def content_for_title(raw_title)
  key = topic_from_title(raw_title)

  case key
  when "flufffox:terms_of_service"
    <<~TEXT.strip
      h2. FluffFox Terms of Service

      By using FluffFox, you agree to follow these terms.

      h3. Eligibility
      * You must be at least 13 years old.
      * You are responsible for complying with your local laws.

      h3. Account Rules
      * Keep your account credentials secure.
      * Do not impersonate others or evade moderation actions.
      * You are responsible for activity on your account.

      h3. Content Rules
      * Upload only content you are allowed to share.
      * Follow all site content policies and tagging requirements.
      * Removed content may not be reuploaded without staff approval.

      h3. Enforcement
      * Staff may remove content or limit accounts that violate rules.
      * Severe or repeated violations may result in permanent bans.

      h3. Liability
      * The service is provided as-is without warranties.
      * FluffFox may update features, policies, or these terms at any time.
    TEXT
  when "flufffox:privacy_policy"
    <<~TEXT.strip
      h2. FluffFox Privacy Policy

      This page explains what data FluffFox stores and how it is used.

      h3. Data We Collect
      * Account data (username, email, profile settings).
      * Activity data (uploads, edits, moderation actions).
      * Technical data (IP address, browser metadata, logs).

      h3. Why We Use Data
      * Operate and secure the service.
      * Investigate abuse, spam, and policy violations.
      * Provide support and improve site quality.

      h3. Data Sharing
      * We do not sell personal data.
      * We may disclose data when legally required or to protect users/site integrity.

      h3. Retention
      * Data is retained as long as needed for operations, legal obligations, and safety.

      h3. Contact
      * For privacy requests, use [[flufffox:contact]].
    TEXT
  when "flufffox:rules"
    <<~TEXT.strip
      h2. FluffFox Rules

      h3. Core Rules
      * Follow all applicable laws.
      * Do not harass, threaten, or abuse other users.
      * Do not spam, scam, or evade moderation actions.

      h3. Upload Rules
      * Upload only content relevant to the site.
      * Tag accurately and completely.
      * Respect takedown and avoid-posting notices.

      h3. Moderation
      * Staff decisions are final in urgent safety cases.
      * Appeals may be sent through official support channels.
    TEXT
  when "flufffox:contact"
    <<~TEXT.strip
      h2. Contact FluffFox

      For support, policy questions, or urgent reports, contact site staff.

      h3. Recommended Channels
      * Account or moderation issues: create a ticket.
      * Legal/takedown requests: use the takedown process.
      * General questions: forum or staff contact page.
    TEXT
  when "flufffox:takedown", "flufffox:takedown_new", "flufffox:takedown_verification"
    <<~TEXT.strip
      h2. Takedown Process

      If you are a rights holder and need content removed:
      * Provide identifying details and proof of ownership/authority.
      * Include exact post IDs or URLs.
      * Describe requested action and reason.

      h3. Verification
      * Requests may require identity verification.
      * False or abusive requests may be denied.

      h3. Processing
      * Staff reviews and logs all valid requests.
      * Affected posts may be removed, restricted, or flagged for follow-up.
    TEXT
  when "flufffox:upload_limit"
    <<~TEXT.strip
      h2. Upload Limit

      Upload limits help keep queue quality and moderation manageable.

      h3. How It Works
      * New and lower-trust accounts have stricter limits.
      * Limits adjust based on account standing and post history.
      * Abuse or repeated violations may reduce your limit.
    TEXT
  when "flufffox:avoid_posting_notice"
    <<~TEXT.strip
      h2. Avoid Posting Notice

      Some artists request that their works not be reposted here.
      Respect active avoid-posting and conditional DNP entries.

      h3. Before Uploading
      * Check artist status and related notes.
      * If uncertain, ask staff before posting.
    TEXT
  when "flufffox:tags", "help:uploading_guidelines", "help:tagging_checklist"
    <<~TEXT.strip
      h2. Uploading and Tagging Guidelines

      h3. Minimum Expectations
      * Use accurate, descriptive tags.
      * Include core subject, character/species, and content tags.
      * Avoid misleading, joke, or intentionally wrong tags.

      h3. Quality
      * Do not upload corrupted, extremely low-quality, or irrelevant files.
      * Check duplicates before uploading.
    TEXT
  when "flufffox:post_relationships"
    <<~TEXT.strip
      h2. Post Relationships

      Use parent/child links for related variants, edits, or source versions.
      Keep relationships accurate so browsing and moderation stay clear.
    TEXT
  when "flufffox:notes"
    <<~TEXT.strip
      h2. Notes Guide

      Notes should be readable, concise, and not obstruct key artwork.
      Keep translations accurate and avoid speculation.
    TEXT
  when "flufffox:pools"
    <<~TEXT.strip
      h2. Pool Guidelines

      Pools should group related posts in meaningful order.
      Use clear naming and avoid duplicate/empty pools.
    TEXT
  when "flufffox:tag_aliases", "flufffox:tag_implications"
    <<~TEXT.strip
      h2. Tag Alias and Implication Rules

      Aliases merge synonymous tags.
      Implications add broader tags automatically when appropriate.
      Proposals should be precise and justified.
    TEXT
  when "flufffox:staff"
    <<~TEXT.strip
      h2. Staff Contact

      Use this page to identify staff roles and proper escalation paths.
      Do not use private channels to bypass moderation workflows.
    TEXT
  when "flufffox:blacklist", "help:global_blacklist", "help:user_settings"
    <<~TEXT.strip
      h2. Blacklist and Content Filters

      You can hide content with personal blacklist settings.
      Global restrictions may apply to specific content classes.
    TEXT
  when "help:api"
    <<~TEXT.strip
      h2. API Documentation

      h3. Authentication
      * Use your API key from account settings.

      h3. Usage
      * Respect rate limits.
      * Cache responses when possible.
      * Do not scrape aggressively.
    TEXT
  when "help:home"
    <<~TEXT.strip
      h2. Help Index

      Start here for core docs:
      * [[help:posts]]
      * [[help:tags]]
      * [[help:upload]]
      * [[help:api]]
      * [[flufffox:rules]]
    TEXT
  when "anonymous_artist", "unknown_artist"
    <<~TEXT.strip
      h2. #{key}

      Use this tag only when no verified artist identity is available.
      If artist information is known, use the correct artist tag instead.
    TEXT
  when "tag_what_you_see"
    <<~TEXT.strip
      h2. Tag What You See

      Tag the visible content directly.
      Do not assume details not shown in the post.
    TEXT
  when "howto:sites_and_sources"
    <<~TEXT.strip
      h2. Sites and Sources

      Always include the best available source URL.
      Prefer original artist/source pages over reposts.
    TEXT
  else
    default_doc_body(raw_title)
  end
end

def body_with_footer(raw_title)
  "#{content_for_title(raw_title).rstrip}\n\n#{FOOTER}"
end

def ensure_footer(page)
  body = page.body.to_s
  return :unchanged if body.include?(FOOTER)

  updated = body.rstrip
  updated += "\n\n" unless updated.empty?
  updated += FOOTER
  page.update!(body: updated)
  :updated
end

def ensure_wiki(raw_title, body: nil)
  normalized = WikiPage.normalize_name(raw_title)
  page = WikiPage.titled(normalized)
  if page.present?
    if page.body.to_s.strip.empty? || page.body.to_s.include?("TODO: write documentation")
      page.update!(body: body || body_with_footer(raw_title))
      return [:updated, page]
    end

    footer_state = ensure_footer(page)
    return [footer_state, page]
  end

  page = WikiPage.new(
    title: raw_title, # normalized by model callback
    body: body || body_with_footer(raw_title)
  )
  page.save!
  [:created, page]
end

def ensure_help(name, raw_wiki_title)
  normalized_wiki = WikiPage.normalize_name(raw_wiki_title)
  help = HelpPage.find_by(name: name)
  return [:exists, help] if help.present?

  help = HelpPage.new(
    name: name,
    wiki_page: normalized_wiki,
    title: "",
    related: ""
  )
  help.save!
  [:created, help]
end

actor = pick_actor
raise "No users found; create at least one user first." if actor.nil?

CurrentUser.user = actor
CurrentUser.ip_addr = "127.0.0.1"

wiki_inputs = [
  # Static/legal pages
  "flufffox:terms of service",
  "flufffox:privacy policy",
  "flufffox:rules",
  "flufffox:contact",
  "flufffox:takedown",
  "flufffox:takedown new",
  "flufffox:takedown verification",
  "flufffox:upload limit",
  "flufffox:avoid posting notice",
  "flufffox:discord",
  # Common policy/guideline pages
  "flufffox:tags",
  "flufffox:post relationships",
  "flufffox:notes",
  "flufffox:pools",
  "flufffox:tag aliases",
  "flufffox:tag implications",
  "flufffox:staff",
  "flufffox:blacklist",
  # Generic wiki references in UI/uploader
  "anonymous_artist",
  "unknown_artist",
  "tag_what_you_see",
  "howto:sites_and_sources",
  "help:home",
  "help:flag_notice",
  "help:replacement_notice",
  # Help wiki targets
  "help:accounts",
  "help:api",
  "help:artists",
  "help:blips",
  "help:cheatsheet",
  "help:comments",
  "help:dmail",
  "help:forum",
  "help:global_blacklist",
  "help:posts",
  "help:sets",
  "help:tagging_checklist",
  "help:upload",
  "help:upload_whitelist",
  "help:uploading_guidelines",
  "help:user_name_change_requests",
  "help:user_settings",
  "help:wiki"
]

help_map = {
  "accounts" => "help:accounts",
  "api" => "help:api",
  "artists" => "help:artists",
  "blacklist" => "flufffox:blacklist",
  "blips" => "help:blips",
  "cheatsheet" => "help:cheatsheet",
  "comments" => "help:comments",
  "dmail" => "help:dmail",
  "forum" => "help:forum",
  "global_blacklist" => "help:global_blacklist",
  "notes" => "flufffox:notes",
  "pools" => "flufffox:pools",
  "posts" => "help:posts",
  "rules" => "flufffox:rules",
  "sets" => "help:sets",
  "tag_aliases" => "flufffox:tag aliases",
  "tag_implications" => "flufffox:tag implications",
  "tagging_checklist" => "help:tagging_checklist",
  "tags" => "flufffox:tags",
  "upload" => "help:upload",
  "upload_whitelist" => "help:upload_whitelist",
  "uploading_guidelines" => "help:uploading_guidelines",
  "user_name_change_requests" => "help:user_name_change_requests",
  "user_settings" => "help:user_settings",
  "wiki" => "help:wiki"
}

created_wikis = []
existing_wikis = []
updated_wikis = []
wiki_inputs.each do |raw_title|
  state, page = ensure_wiki(raw_title)
  if state == :created
    created_wikis << page.title
  elsif state == :updated
    updated_wikis << page.title
  else
    existing_wikis << page.title
  end
end

created_help = []
existing_help = []
help_map.each do |name, wiki_title|
  state, help = ensure_help(name, wiki_title)
  if state == :created
    created_help << "#{help.name} -> #{help.wiki_page}"
  else
    existing_help << "#{help.name} -> #{help.wiki_page}"
  end
end

puts "Actor: #{actor.name} (id=#{actor.id})"
puts "Wiki created: #{created_wikis.size}"
puts created_wikis.sort
puts "Wiki already present: #{existing_wikis.size}"
puts "Wiki footer updated: #{updated_wikis.size}"
puts updated_wikis.sort
puts "Help created: #{created_help.size}"
puts created_help.sort
puts "Help already present: #{existing_help.size}"
