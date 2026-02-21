# frozen_string_literal: true

# Expand help wiki pages with detailed operational docs.
# Run with:
#   bundle exec rails runner scripts/enrich_help_docs.rb

FOOTER = "© 2026 FluffFox Community. All rights reserved.".freeze


def topic_title(text)
  text.to_s.tr("_", " ").split.map(&:capitalize).join(" ")
end

def body_for(slug, wiki_title)
  case slug
  when "home"
    <<~TEXT.strip
      h2. Help Home

      This index explains how to use the site from first login to advanced moderation workflows.

      h3. Start Here
      * New uploader: [[help:upload]], [[help:uploading_guidelines]], [[help:tagging_checklist]]
      * Regular browsing: [[help:posts]], [[help:cheatsheet]], [[flufffox:blacklist]]
      * Account setup: [[help:accounts]], [[help:user_settings]]

      h3. Core Concepts
      * Posts are the media records and metadata container.
      * Tags are the search/filter backbone.
      * Wiki pages define policy, standards, and naming conventions.
      * Help pages are curated wiki pages focused on workflows.

      h3. If You Get Stuck
      * Check the matching help page for the feature you are using.
      * Read warning/error messages fully before retrying.
      * Ask on forum/staff channels with post IDs and exact steps.
    TEXT
  when "posts"
    <<~TEXT.strip
      h2. Posts

      A post includes media + metadata + moderation state.

      h3. What Everything Means
      * ID: immutable numeric reference.
      * Rating: content safety class used for filtering and policy.
      * Tags: searchable descriptors for content and attribution.
      * Source: origin URLs and attribution chain.
      * Status flags: pending/flagged/deleted and lock states.
      * Relationships: parent/child links for version lineage.

      h3. How To Work With Posts
      1. Upload with complete tags and valid sources.
      2. Verify final post output (preview/sample + metadata).
      3. Correct mistakes quickly (tags/source/description).
      4. Use relationships for variants/edits where appropriate.

      h3. Common Mistakes
      * Wrong rating.
      * Missing artist/source tags.
      * Overly vague tags.
      * Linking unrelated parent/child posts.

      h3. Troubleshooting
      * Post exists but media looks wrong: regenerate thumbnails/samples.
      * Duplicate rejection: compare md5/source with existing post.
      * Pending too long: confirm it meets guidelines, then wait for queue review.
    TEXT
  when "upload"
    <<~TEXT.strip
      h2. Uploading

      Uploading is a metadata-quality task, not just file submission.

      h3. Form Fields Explained
      * File/URL: choose one input source.
      * Sources: one or more origin links, one per line.
      * Tags: artist/species/character/content descriptors.
      * Rating: correct class for visible content.
      * Description: useful context/translation notes.
      * Background color option: optional flatten color for transparent derivatives.
      * Upload as pending: manual moderation path when unsure.

      h3. Upload Workflow
      1. Confirm file quality and relevance.
      2. Check duplicate risk.
      3. Add complete tags and source links.
      4. Submit and review output.
      5. Fix errors immediately.

      h3. URL Upload Notes
      * Remote URLs must pass whitelist checks.
      * Some preview URLs are blocked; use the original file URL when possible.
      * If URL fails, download and upload manually.

      h3. Failure Handling
      * If you see 5xx/Failbooru errors, check if the post was still created.
      * If created, open it and validate metadata.
      * If not created, retry once and capture exact error text.
    TEXT
  when "uploading_guidelines"
    <<~TEXT.strip
      h2. Uploading Guidelines

      h3. Acceptance Standard
      * Content is relevant and viewable.
      * Metadata is complete enough for search/moderation.
      * Source attribution is provided where available.

      h3. Quality Bar
      * No corrupted files.
      * No intentionally misleading metadata.
      * No policy-prohibited repost behavior.

      h3. Moderator Decision Factors
      * Technical quality and completeness.
      * Tag usefulness and correctness.
      * Rule compliance and prior uploader behavior.

      h3. Consequences
      * Flags, pending state, replacement requests, or deletion.
      * Repeat low-quality behavior may reduce upload privileges.
    TEXT
  when "tagging_checklist"
    <<~TEXT.strip
      h2. Tagging Checklist

      Use this every time before submit.

      h3. Required Before Submit
      * Artist known? Add artist tag.
      * Character/species visible? Add those tags.
      * Key content themes present? Add relevant descriptors.
      * Rating matches visible content.

      h3. Cleanup Pass
      * Remove typos and duplicates.
      * Replace joke/vague tags with useful descriptors.
      * Ensure all tags are visually grounded.

      h3. Final Verification
      * Search your own tag combo and verify this post fits.
      * Confirm blacklist-sensitive tags are present if needed.
      * Re-open post after submit and sanity-check again.
    TEXT
  when "tags"
    <<~TEXT.strip
      h2. Tags

      Tags are the primary indexing system.

      h3. Tag Categories (Practical Meaning)
      * Artist/Contributor: attribution and authorship.
      * Character/Species/Copyright: identity taxonomy.
      * General/Meta/Lore: visual/content and organizational context.

      h3. Good Tagging Rules
      * Prefer specific over broad tags when both apply.
      * Avoid assumptions outside visible evidence.
      * Keep conventions aligned with existing wiki norms.

      h3. Maintenance Tools
      * Alias: merge duplicate/synonym tags.
      * Implication: auto-add broader parent tags.
      * BUR: large-scale correction workflow.

      h3. When Unsure
      * Check wiki page for the tag.
      * Use checklist pages and related help links.
      * Ask before mass-editing tag structures.
    TEXT
  when "cheatsheet"
    <<~TEXT.strip
      h2. Search Cheatsheet

      h3. Query Basics
      * `tag_a tag_b` => AND
      * `-tag` => exclude
      * `~tag` => optional boost/or behavior

      h3. High-Value Metatags
      * `rating:s` / `rating:q`
      * `user:name`
      * `status:pending` / `status:flagged` / `status:deleted`
      * `order:score` / `order:id_desc`
      * `id:12345` / `md5:...`

      h3. Query Building Pattern
      1. Start with subject tags.
      2. Add rating/status constraints.
      3. Exclude unwanted content via `-tag`.
      4. Add ordering for browsing objective.
    TEXT
  when "tag_aliases", "tag_implications", "tag_relationships"
    <<~TEXT.strip
      h2. Tag Relationships

      h3. Alias vs Implication
      * Alias = same meaning, one canonical destination.
      * Implication = one tag logically includes another.

      h3. Review Criteria
      * Is the relation objectively true most of the time?
      * Will this reduce or increase moderator workload?
      * Are edge cases acceptable without major false positives?

      h3. Change Safety
      * Test on a sample set first.
      * Keep proposals narrowly scoped.
      * Prefer reversible, incremental changes.
    TEXT
  when "artists"
    <<~TEXT.strip
      h2. Artists

      h3. Artist Entry Purpose
      * Link creator identity with canonical naming.
      * Track source URLs and attribution context.

      h3. Practical Workflow
      1. Verify artist identity from source.
      2. Add/update artist record and URLs.
      3. Apply correct artist tag on post.
      4. Fix temporary tags if new evidence appears.

      h3. Avoid
      * Guessing identity from weak signals.
      * Merging distinct artists without proof.
      * Leaving known attribution as unknown.
    TEXT
  when "comments", "forum", "dmail", "blips"
    <<~TEXT.strip
      h2. Communication Features

      h3. Feature Use
      * Comments: post-specific discussion.
      * Forum: topic-based long-form discussion.
      * DMail: private message channel.
      * Blips: short status updates.

      h3. Conduct Standard
      * Stay respectful and on-topic.
      * No harassment, spam, or manipulation.
      * Follow moderation requests promptly.

      h3. Enforcement
      * Content may be hidden/removed.
      * Repeated abuse escalates to restrictions.
    TEXT
  when "wiki"
    <<~TEXT.strip
      h2. Wiki

      h3. Purpose
      * Canonical definitions, policies, and process docs.

      h3. Editing Method
      1. Confirm current policy before editing.
      2. Write concise, actionable wording.
      3. Add examples where ambiguity is likely.
      4. Link related pages for navigation.

      h3. Quality Standard
      * Factual and maintainable text.
      * Minimal opinion language.
      * Reflects actual moderation practice.
    TEXT
  when "notes"
    <<~TEXT.strip
      h2. Notes

      h3. What Notes Are For
      * Translation and contextual annotation on image regions.

      h3. Best Practices
      * Keep placement precise.
      * Keep text concise and accurate.
      * Avoid covering key art unnecessarily.

      h3. Translation Quality
      * Prefer faithful meaning over creative paraphrase.
      * Mark uncertainty where necessary.
    TEXT
  when "pools", "sets"
    <<~TEXT.strip
      h2. Pools and Sets

      h3. Difference
      * Pools: ordered/structured grouping.
      * Sets: lightweight curated collections.

      h3. Operational Tips
      * Use clear names and descriptions.
      * Keep ordering intentional for pools.
      * Avoid empty or duplicate collections.
    TEXT
  when "blacklist", "global_blacklist", "user_settings", "accounts", "user_name_change_requests"
    <<~TEXT.strip
      h2. Account and Filtering

      h3. What These Features Mean
      * Blacklist: personal content filtering rules.
      * Global blacklist: platform-level restricted visibility.
      * User settings: browsing and accessibility controls.
      * Account controls: identity/security/limits.

      h3. How To Work It
      * Start with simple blacklist rules.
      * Verify safe mode/global restrictions before bug reports.
      * Keep account recovery/security settings up to date.

      h3. Troubleshooting
      * Missing posts: check safe mode + blacklist + global restrictions.
      * Access limits: check account standing and moderation history.
    TEXT
  when "upload_whitelist"
    <<~TEXT.strip
      h2. Upload Whitelist

      h3. What It Means
      * Direct URL uploads are restricted to approved domains.

      h3. Why It Exists
      * Security (SSRF/abuse prevention).
      * Source quality and stability control.

      h3. What To Do If Blocked
      * Upload local file manually.
      * Provide valid source links in metadata.
      * Request whitelist review with concrete examples.
    TEXT
  when "api"
    <<~TEXT.strip
      h2. API

      h3. Core Rules
      * Respect rate limits.
      * Cache aggressively.
      * Avoid burst scraping patterns.

      h3. Client Reliability
      * Handle non-JSON and 5xx gracefully.
      * Implement retries with backoff.
      * Avoid hard dependency on unstable fields.

      h3. Security
      * Keep keys private.
      * Rotate compromised credentials immediately.
    TEXT
  when "rules"
    <<~TEXT.strip
      h2. Rules

      h3. Platform Rules
      * Follow laws and site policies.
      * No harassment, spam, or evasion.
      * Respect staff moderation decisions.

      h3. Content Rules
      * Upload only policy-compliant content.
      * Use accurate metadata and sources.
      * Do not reupload removed content without approval.

      h3. Enforcement Ladder
      * Warning -> restriction -> suspension/ban.
      * Severe abuse may skip directly to high-severity actions.
    TEXT
  else
    <<~TEXT.strip
      h2. #{topic_title(wiki_title.to_s.split(":").last)}

      This page explains what this feature means, how to use it, and common troubleshooting steps.

      h3. What It Means
      * Feature purpose and expected behavior.

      h3. How To Use It
      1. Open the related section in the UI.
      2. Follow the standard workflow.
      3. Verify output and correct mistakes.

      h3. Troubleshooting
      * Check validation errors and required fields.
      * Confirm permissions and policy constraints.
      * If issue persists, capture exact steps and request support.
    TEXT
  end
end

def apply_footer(text)
  base = text.to_s.rstrip
  "#{base}\n\n#{FOOTER}"
end

actor = User.where(level: User::Levels::ADMIN).order(:id).first || User.order(:id).first
raise "No users found" if actor.nil?

CurrentUser.user = actor
CurrentUser.ip_addr = "127.0.0.1"

updated = []
skipped = []

HelpPage.includes(:wiki).find_each do |help|
  next if help.name.to_s.start_with?("test._ignore")

  wiki = help.wiki
  unless wiki
    skipped << help.name
    next
  end

  new_body = apply_footer(body_for(help.name, wiki.title))
  if wiki.body.to_s.rstrip == new_body.rstrip
    skipped << help.name
    next
  end

  wiki.update!(body: new_body)
  updated << help.name
end

puts "Actor: #{actor.name} (id=#{actor.id})"
puts "Updated help wiki pages: #{updated.size}"
puts updated.sort
puts "Unchanged/skipped: #{skipped.size}"
