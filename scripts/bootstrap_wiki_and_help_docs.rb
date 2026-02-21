# frozen_string_literal: true

# Bootstrap or refresh WikiPage + HelpPage records used by the app.
# Run with:
#   bundle exec rails runner scripts/bootstrap_wiki_and_help_docs.rb

FOOTER = "© 2026 FluffFox Community. All rights reserved.".freeze

HELP_DEFINITIONS = {
  "home" => {
    wiki: "help:home",
    title: "Help Home",
    related: %w[posts upload tags rules accounts]
  },
  "posts" => {
    wiki: "help:posts",
    title: "Posts",
    related: %w[upload tags comments notes pools sets blacklist]
  },
  "upload" => {
    wiki: "help:upload",
    title: "Uploading",
    related: %w[uploading_guidelines tagging_checklist tags upload_whitelist posts]
  },
  "uploading_guidelines" => {
    wiki: "help:uploading_guidelines",
    title: "Uploading Guidelines",
    related: %w[upload tagging_checklist tags rules]
  },
  "tagging_checklist" => {
    wiki: "help:tagging_checklist",
    title: "Tagging Checklist",
    related: %w[tags upload uploading_guidelines cheatsheet]
  },
  "tags" => {
    wiki: "flufffox:tags",
    title: "Tags",
    related: %w[cheatsheet tag_aliases tag_implications tag_relationships tagging_checklist]
  },
  "cheatsheet" => {
    wiki: "help:cheatsheet",
    title: "Search Cheatsheet",
    related: %w[tags posts]
  },
  "tag_aliases" => {
    wiki: "flufffox:tag_aliases",
    title: "Tag Aliases",
    related: %w[tag_implications tag_relationships tags]
  },
  "tag_implications" => {
    wiki: "flufffox:tag_implications",
    title: "Tag Implications",
    related: %w[tag_aliases tag_relationships tags]
  },
  "tag_relationships" => {
    wiki: "help:tag_relationships",
    title: "Tag Relationships",
    related: %w[tag_aliases tag_implications tags]
  },
  "artists" => {
    wiki: "help:artists",
    title: "Artists",
    related: %w[upload tags]
  },
  "comments" => {
    wiki: "help:comments",
    title: "Comments",
    related: %w[forum posts rules]
  },
  "forum" => {
    wiki: "help:forum",
    title: "Forum",
    related: %w[comments rules dmail]
  },
  "wiki" => {
    wiki: "help:wiki",
    title: "Wiki",
    related: %w[tags posts forum]
  },
  "notes" => {
    wiki: "flufffox:notes",
    title: "Notes",
    related: %w[posts comments]
  },
  "pools" => {
    wiki: "flufffox:pools",
    title: "Pools",
    related: %w[sets posts]
  },
  "sets" => {
    wiki: "help:sets",
    title: "Sets",
    related: %w[pools posts]
  },
  "blacklist" => {
    wiki: "flufffox:blacklist",
    title: "Blacklist",
    related: %w[user_settings global_blacklist posts]
  },
  "global_blacklist" => {
    wiki: "help:global_blacklist",
    title: "Global Blacklist",
    related: %w[blacklist user_settings rules]
  },
  "user_settings" => {
    wiki: "help:user_settings",
    title: "User Settings",
    related: %w[blacklist global_blacklist accounts]
  },
  "accounts" => {
    wiki: "help:accounts",
    title: "Accounts",
    related: %w[user_settings dmail api user_name_change_requests]
  },
  "user_name_change_requests" => {
    wiki: "help:user_name_change_requests",
    title: "Username Changes",
    related: %w[accounts]
  },
  "dmail" => {
    wiki: "help:dmail",
    title: "DMail",
    related: %w[accounts forum comments]
  },
  "upload_whitelist" => {
    wiki: "help:upload_whitelist",
    title: "Upload Whitelist",
    related: %w[upload uploading_guidelines]
  },
  "api" => {
    wiki: "help:api",
    title: "API",
    related: %w[accounts tags posts]
  },
  "rules" => {
    wiki: "flufffox:rules",
    title: "Rules",
    related: %w[uploading_guidelines comments forum]
  },
  "blips" => {
    wiki: "help:blips",
    title: "Blips",
    related: %w[comments forum]
  }
}.freeze

EXTRA_WIKIS = [
  "flufffox:terms of service",
  "flufffox:privacy policy",
  "flufffox:contact",
  "flufffox:takedown",
  "flufffox:takedown new",
  "flufffox:takedown verification",
  "flufffox:upload limit",
  "flufffox:avoid posting notice",
  "flufffox:discord",
  "flufffox:post relationships",
  "flufffox:staff",
  "anonymous_artist",
  "unknown_artist",
  "tag_what_you_see",
  "howto:sites_and_sources"
].freeze

AUTO_MARKERS = [
  "This page documents how FluffFox handles",
  "starter document generated during site bootstrap"
].freeze

def pick_actor
  User.where(level: User::Levels::ADMIN).order(:id).first ||
    User.where(level: User::Levels::MODERATOR).order(:id).first ||
    User.find_by(name: "auto_moderator") ||
    User.order(:id).first
end

def topic_from_title(raw_title)
  WikiPage.normalize_name(raw_title).to_s
end

def pretty_topic(topic)
  topic.tr("_", " ").tr(":", " - ").split.map(&:capitalize).join(" ")
end

def default_doc_body(raw_title)
  topic = topic_from_title(raw_title)
  <<~TEXT.strip
    h2. #{pretty_topic(topic)}

    This page explains how FluffFox handles "#{topic}".

    h3. Purpose
    * Define what this feature is for.
    * Explain expected behavior for users and staff.

    h3. How To Use
    * Follow the linked workflow from the relevant page in the UI.
    * If something is unclear, ask staff before taking irreversible actions.

    h3. Policy Notes
    * Staff may enforce additional limits to protect service quality.
    * Repeated abuse may result in restrictions.
  TEXT
end

def content_for_title(raw_title)
  key = topic_from_title(raw_title)

  case key
  when "help:home"
    <<~TEXT.strip
      h2. FluffFox Help Home

      Use this index to quickly find documentation for major site features.

      h3. Core Guides
      * Uploading: [[help:upload]]
      * Uploading Guidelines: [[help:uploading_guidelines]]
      * Tagging Checklist: [[help:tagging_checklist]]
      * Tag System: [[flufffox:tags]]
      * Search Cheatsheet: [[help:cheatsheet]]
      * Rules: [[flufffox:rules]]

      h3. Account + Safety
      * Accounts: [[help:accounts]]
      * User Settings: [[help:user_settings]]
      * Blacklist: [[flufffox:blacklist]]
      * Global Blacklist: [[help:global_blacklist]]

      h3. Community + Metadata
      * Comments: [[help:comments]]
      * Forum: [[help:forum]]
      * Wiki: [[help:wiki]]
      * Artists: [[help:artists]]
      * Tag Relationships: [[help:tag_relationships]]
    TEXT
  when "help:posts"
    <<~TEXT.strip
      h2. Posts

      Posts are the core content records on FluffFox. Each post stores media, tags, sources, rating, and moderation state.

      h3. Lifecycle
      * Upload creates a post record and media derivatives (preview/sample).
      * Posts may be pending, approved, flagged, replaced, or deleted.
      * Staff can regenerate previews/samples when needed.

      h3. Editing
      * Update tags, sources, description, relationships, and metadata responsibly.
      * Keep tags visible-fact based. Use [[tag_what_you_see]].
      * Do not remove important warning or attribution information.

      h3. Relationships
      * Parent/child is for version lineage or close variants.
      * Keep links accurate and avoid circular/noisy relationships.
      * See [[flufffox:post_relationships]].

      h3. Moderation States
      * Pending: waiting for approval or further review.
      * Flagged: potentially violating rules/guidelines.
      * Deleted: removed from normal visibility and may not be reuploaded.
    TEXT
  when "help:upload"
    <<~TEXT.strip
      h2. Uploading

      Uploading has two parts: file/source submission and metadata quality.

      h3. Before You Upload
      * Verify the file is allowed, complete, and relevant.
      * Check for duplicates first.
      * Gather proper source links (artist page + post URL when available).

      h3. Upload Form Fields
      * File or direct URL: provide exactly one source file input.
      * Tags: include minimum quality tags and key descriptors.
      * Rating: choose the correct site rating for visible content.
      * Description: include translation/context when useful.
      * Optional background color: applies to transparent derivatives when enabled.

      h3. Source Rules
      * Prefer original pages over repost mirrors.
      * Include all meaningful sources if multiple are relevant.
      * See [[howto:sites_and_sources]].

      h3. After Upload
      * Review the final post for tag correctness.
      * Fix mistakes immediately.
      * Respond to moderation feedback constructively.
    TEXT
  when "help:uploading_guidelines"
    <<~TEXT.strip
      h2. Uploading Guidelines

      These guidelines protect content quality and moderation throughput.

      h3. Required Quality
      * Clear, viewable media; no corrupted files.
      * Sufficiently descriptive tags.
      * Correct rating and source attribution.

      h3. Not Allowed
      * Duplicate uploads of existing or destroyed content.
      * Intentionally misleading tags or ratings.
      * Uploads that ignore active policy restrictions.

      h3. Moderation Outcomes
      * Content may be flagged, set pending, replaced, or removed.
      * Repeated low-quality uploads can reduce upload privileges.
    TEXT
  when "help:tagging_checklist"
    <<~TEXT.strip
      h2. Tagging Checklist

      Use this checklist before final submit:

      h3. Core Tags
      * Subject/character/species present.
      * Notable visual features present.
      * Important scene/action tags present.

      h3. Classification
      * Correct rating selected.
      * Artist/contributor tags set where known.
      * Special warnings (if applicable) included.

      h3. Cleanup
      * Remove typo tags.
      * Avoid contradictory tags.
      * Confirm tags reflect visible facts only.
    TEXT
  when "flufffox:tags"
    <<~TEXT.strip
      h2. Tag System

      Tags power search, filtering, moderation tools, and discovery.

      h3. General Principles
      * Tag what is visible.
      * Prefer specific tags over vague tags.
      * Keep taxonomy consistent with existing usage.

      h3. Category Notes
      * Artist/Contributor: authorship and contribution metadata.
      * Character/Species/Copyright: identity and universe metadata.
      * Meta/Lore: workflow/organizational tags and world info.

      h3. Maintenance
      * Use aliases for synonyms and common misspellings.
      * Use implications for broad -> specific logical relations.
      * Use BUR workflows for bulk correction.
    TEXT
  when "help:cheatsheet"
    <<~TEXT.strip
      h2. Search Cheatsheet

      h3. Basic
      * `tag1 tag2` => intersection
      * `-tag` => exclude
      * `~tag` => optional / OR-style scoring

      h3. Useful Metatags
      * `rating:s` or `rating:q`
      * `user:name`
      * `status:pending` / `status:flagged`
      * `order:score` / `order:id_desc`
      * `parent:none` / `child:any`

      h3. Tips
      * Start broad, then add exclusions.
      * Save frequent queries in bookmarks.
      * Use blacklist for personal filtering, not search-only logic.
    TEXT
  when "help:tag_relationships"
    <<~TEXT.strip
      h2. Tag Relationships

      This page covers aliases, implications, and Bulk Update Requests.

      h3. Alias
      * Alias merges one tag into another canonical tag.
      * Use for strict synonyms and misspellings.

      h3. Implication
      * Implication adds a broader tag whenever a specific tag is used.
      * Avoid implications that are context-dependent or often false.

      h3. BUR
      * Use BUR when changes affect many posts at once.
      * Include clear rationale and examples.
      * Keep requests narrow enough for safe review.
    TEXT
  when "flufffox:tag_aliases"
    <<~TEXT.strip
      h2. Tag Alias Policy

      Use aliases to normalize equivalent tag names.

      h3. Good Alias Candidates
      * Spelling variants
      * Deprecated naming conventions
      * Duplicate terms with identical meaning

      h3. Avoid
      * Aliasing tags with different semantic scope
      * Aliasing tags that should instead be implications
      * Ambiguous aliases without consensus
    TEXT
  when "flufffox:tag_implications"
    <<~TEXT.strip
      h2. Tag Implication Policy

      Implications should be mechanically true in almost all cases.

      h3. Good Implications
      * Specific subtype -> broader supertype
      * Canonical structure where exceptions are rare

      h3. Bad Implications
      * Context-heavy assumptions
      * Subjective style interpretations
      * Relations with frequent exceptions
    TEXT
  when "help:artists"
    <<~TEXT.strip
      h2. Artists

      Artist entries connect creator names to URLs and metadata.

      h3. Best Practices
      * Keep names normalized and consistent.
      * Add official profile/source URLs.
      * Avoid speculative merges.

      h3. During Upload
      * Tag the artist if known.
      * Use `unknown_artist` only when truly unknown.
      * Replace temporary tags when verified data appears.
    TEXT
  when "help:comments"
    <<~TEXT.strip
      h2. Comments

      Comments are for constructive discussion tied to the post.

      h3. Expectations
      * Stay on-topic.
      * Keep tone respectful.
      * Avoid harassment, baiting, and spam.

      h3. Moderation
      * Hidden comments are still logged for staff review.
      * Repeated abuse can lead to restrictions.
    TEXT
  when "help:forum"
    <<~TEXT.strip
      h2. Forum

      Forum topics are for broader discussion that is not tied to a single post.

      h3. Usage
      * Create clear titles and focused opening posts.
      * Use existing topics when discussion already exists.
      * Keep long-running topics organized.

      h3. Conduct
      * Follow site rules and code of conduct.
      * No harassment or intentional derailment.
    TEXT
  when "help:wiki"
    <<~TEXT.strip
      h2. Wiki

      The wiki is the source of truth for tags, procedures, and policy details.

      h3. Editing Standards
      * Prefer accurate, concise, and updateable prose.
      * Include examples where ambiguity is likely.
      * Avoid personal opinions in policy pages.

      h3. Maintenance
      * Keep pages synchronized with current moderation practice.
      * Link related pages for navigation clarity.
    TEXT
  when "flufffox:notes"
    <<~TEXT.strip
      h2. Notes

      Notes annotate image regions for translation/context.

      h3. Guidelines
      * Keep note text concise and faithful.
      * Place notes precisely and avoid covering unrelated detail.
      * Use consistent terminology for recurring text.

      h3. Translation Notes
      * Prefer literal accuracy first, then readability.
      * Mark uncertain translations clearly.
    TEXT
  when "flufffox:pools"
    <<~TEXT.strip
      h2. Pools

      Pools group related posts into a sequence.

      h3. Suitable Pool Types
      * Comics / ordered visual narratives
      * Variants with meaningful progression
      * Themed curated collections (if coherent)

      h3. Quality Rules
      * Use clear naming and descriptions.
      * Keep order intentional.
      * Avoid duplicate or empty pools.
    TEXT
  when "help:sets"
    <<~TEXT.strip
      h2. Sets

      Sets are personal or shared collections of posts.

      h3. When To Use
      * Quick curation without strict sequence requirements.
      * Personal bookmarks by theme/project.

      h3. Differences vs Pools
      * Sets are lighter-weight.
      * Pools are generally used for ordered story-like sequences.
    TEXT
  when "flufffox:blacklist"
    <<~TEXT.strip
      h2. Blacklist

      Blacklist hides posts matching your personal filter rules.

      h3. How It Works
      * Rules apply client-side to matching posts.
      * You can hide, collapse, or mask matches.
      * Use this for personal preferences; do not misuse site flags.

      h3. Tips
      * Keep rules specific to avoid overblocking.
      * Test changes on known tag searches.
    TEXT
  when "help:global_blacklist"
    <<~TEXT.strip
      h2. Global Blacklist

      Some content is hidden by account/safety restrictions regardless of personal settings.

      h3. Why This Exists
      * Protect legal/safety boundaries.
      * Enforce age/sensitive-content restrictions.

      h3. Notes
      * Personal blacklist cannot override global restrictions.
      * Some content may require login or higher trust to view.
    TEXT
  when "help:user_settings"
    <<~TEXT.strip
      h2. User Settings

      Settings control browsing behavior, accessibility, and filtering.

      h3. Important Settings
      * Default image size
      * Safe mode and content filters
      * Theme and UI preferences
      * Blacklist behavior

      h3. Troubleshooting
      * If pages look wrong, clear cached theme settings.
      * Verify safe mode/global restrictions before reporting missing posts.
    TEXT
  when "help:accounts"
    <<~TEXT.strip
      h2. Accounts

      Your account controls permissions, identity, and security.

      h3. Security
      * Use a strong unique password.
      * Enable 2FA when available.
      * Do not share credentials.

      h3. Reputation + Limits
      * Upload and edit limits may depend on account standing.
      * Good moderation history improves trust.

      h3. Recovery
      * Keep your email current for password recovery.
      * Contact staff for edge cases.
    TEXT
  when "help:user_name_change_requests"
    <<~TEXT.strip
      h2. Username Change Requests

      Username changes are moderated to avoid impersonation/confusion.

      h3. Requirements
      * New name must follow naming rules.
      * Name must not impersonate staff or public figures.
      * Repeated churn requests may be denied.
    TEXT
  when "help:dmail"
    <<~TEXT.strip
      h2. DMail

      DMail is the site’s private messaging system.

      h3. Appropriate Use
      * Account/support follow-ups.
      * Civil, relevant communication.

      h3. Not Allowed
      * Harassment, threats, or spam campaigns.
      * Evasion of moderation via alternate accounts.
    TEXT
  when "help:upload_whitelist"
    <<~TEXT.strip
      h2. Upload Whitelist

      Direct URL uploads are restricted to trusted/approved domains.

      h3. Why
      * Prevent abuse and malicious fetches.
      * Reduce SSRF and unsafe remote access vectors.

      h3. User Behavior
      * If a URL is blocked, download manually and upload the file directly.
      * Request whitelist changes through proper staff channels with justification.
    TEXT
  when "help:api"
    <<~TEXT.strip
      h2. API

      The API provides structured access to posts, tags, users, and more.

      h3. Authentication
      * Use account API credentials when required.
      * Keep keys secret and rotate if exposed.

      h3. Best Practices
      * Respect rate limits and server load.
      * Cache responses and avoid tight polling loops.
      * Handle errors/retries gracefully.

      h3. Compatibility
      * Expect fields/endpoints to evolve over time.
      * Build tolerant clients and monitor change notes.
    TEXT
  when "flufffox:rules"
    <<~TEXT.strip
      h2. FluffFox Rules

      h3. Core Conduct
      * Follow applicable law.
      * No harassment, threats, doxxing, hate content, or spam.
      * Do not evade moderation actions.

      h3. Content + Upload
      * Follow upload and tagging guidelines.
      * Do not reupload removed/destroyed content.
      * Respect rights-holder and avoid-posting requests.

      h3. Enforcement
      * Staff may remove content, restrict features, or ban accounts.
      * Severe/repeated violations may receive immediate escalation.
    TEXT
  when "help:blips"
    <<~TEXT.strip
      h2. Blips

      Blips are short-form status updates.

      h3. Expectations
      * Keep posts concise and respectful.
      * Do not use blips for harassment or spam.

      h3. Moderation
      * Blips are subject to the same conduct rules as comments/forum.
    TEXT
  when "flufffox:terms_of_service"
    <<~TEXT.strip
      h2. Terms of Service

      h3. Acceptance
      * Using FluffFox means you agree to these terms and related policies.

      h3. User Responsibility
      * You are responsible for your account activity and submitted content.
      * You must comply with laws and site policy.

      h3. Service Scope
      * Service may change without notice.
      * Abuse prevention and moderation may limit access.

      h3. Liability
      * Service is provided as-is.
    TEXT
  when "flufffox:privacy_policy"
    <<~TEXT.strip
      h2. Privacy Policy

      h3. Data Collected
      * Account profile data.
      * Activity/moderation logs.
      * Technical diagnostics and security logs.

      h3. Usage
      * Operate and secure the platform.
      * Investigate abuse and policy violations.
      * Improve service quality.

      h3. Sharing
      * Data is disclosed only when required by law or safety obligations.
    TEXT
  when "flufffox:contact"
    <<~TEXT.strip
      h2. Contact

      Use official channels for support, moderation, or policy questions.

      h3. Recommended Paths
      * Account issues: ticket/support channel.
      * Legal/takedown: formal takedown workflow.
      * General discussion: forum.
    TEXT
  when "flufffox:takedown", "flufffox:takedown_new", "flufffox:takedown_verification"
    <<~TEXT.strip
      h2. Takedown Process

      Rights holders can request removal of content.

      h3. Required Info
      * Exact post URLs/IDs.
      * Ownership/authority statement.
      * Requested action and rationale.

      h3. Validation
      * Requests may require identity verification.
      * False reports may be denied and logged.
    TEXT
  when "flufffox:upload_limit"
    <<~TEXT.strip
      h2. Upload Limits

      Upload limits are used to protect queue quality and moderation throughput.

      h3. Factors
      * Account trust and history.
      * Recent approvals/rejections.
      * Active pending load.
    TEXT
  when "flufffox:avoid_posting_notice"
    <<~TEXT.strip
      h2. Avoid Posting Notice

      Some artists request non-reposting conditions.

      h3. Before Upload
      * Verify artist status and any conditions.
      * If unclear, ask staff before submitting.
    TEXT
  when "flufffox:post_relationships"
    <<~TEXT.strip
      h2. Post Relationships

      Parent/child relationships should capture meaningful version lineage.

      h3. Use Cases
      * Alternate crops/edits from same source.
      * Revised versions where both are relevant to keep.

      h3. Avoid
      * Linking unrelated posts.
      * Building noisy chains for weak similarity.
    TEXT
  when "flufffox:staff"
    <<~TEXT.strip
      h2. Staff

      Staff handle moderation, safety, and policy enforcement.

      h3. Contact Etiquette
      * Use official channels and provide evidence.
      * Do not mass ping or DM-spam staff.
    TEXT
  when "anonymous_artist", "unknown_artist"
    <<~TEXT.strip
      h2. #{pretty_topic(key)}

      Use this tag only when no verifiable artist identity is available.
      Replace with the proper artist tag if reliable attribution appears.
    TEXT
  when "tag_what_you_see"
    <<~TEXT.strip
      h2. Tag What You See

      Only tag visible facts in the current post.
      Do not infer details from external context unless the post itself shows them.
    TEXT
  when "howto:sites_and_sources"
    <<~TEXT.strip
      h2. Sites and Sources

      Provide the best available source links for every upload.

      h3. Priority
      * Original artist page
      * Original post/submission page
      * Secondary mirrors only when necessary
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

def bootstrap_body?(body)
  return true if body.to_s.strip.empty?
  AUTO_MARKERS.any? { |marker| body.include?(marker) }
end

def ensure_wiki(raw_title)
  normalized = WikiPage.normalize_name(raw_title)
  page = WikiPage.titled(normalized)

  if page.present?
    if bootstrap_body?(page.body)
      page.update!(body: body_with_footer(raw_title))
      return [:updated, page]
    end

    footer_state = ensure_footer(page)
    return [footer_state, page]
  end

  page = WikiPage.new(title: raw_title, body: body_with_footer(raw_title))
  page.save!
  [:created, page]
end

def ensure_help(slug, attrs)
  wiki_title = WikiPage.normalize_name(attrs.fetch(:wiki))
  help = HelpPage.find_by(name: slug)

  if help.present?
    changed = false
    if help.wiki_page != wiki_title
      help.wiki_page = wiki_title
      changed = true
    end
    if help.title.to_s.strip.empty? && attrs[:title].present?
      help.title = attrs[:title]
      changed = true
    end
    if help.related.to_s.strip.empty? && attrs[:related].present?
      help.related = attrs[:related].join(", ")
      changed = true
    end

    help.save! if changed
    return [changed ? :updated : :exists, help]
  end

  help = HelpPage.new(
    name: slug,
    wiki_page: wiki_title,
    title: attrs[:title].to_s,
    related: (attrs[:related] || []).join(", ")
  )
  help.save!
  [:created, help]
end

actor = pick_actor
raise "No users found; create at least one user first." if actor.nil?

CurrentUser.user = actor
CurrentUser.ip_addr = "127.0.0.1"

wiki_inputs = (EXTRA_WIKIS + HELP_DEFINITIONS.values.map { |v| v[:wiki] }).uniq

created_wikis = []
updated_wikis = []
existing_wikis = []

wiki_inputs.each do |raw_title|
  state, page = ensure_wiki(raw_title)
  case state
  when :created
    created_wikis << page.title
  when :updated
    updated_wikis << page.title
  else
    existing_wikis << page.title
  end
end

created_help = []
updated_help = []
existing_help = []

HELP_DEFINITIONS.each do |slug, attrs|
  state, help = ensure_help(slug, attrs)
  line = "#{help.name} -> #{help.wiki_page}"
  case state
  when :created
    created_help << line
  when :updated
    updated_help << line
  else
    existing_help << line
  end
end

puts "Actor: #{actor.name} (id=#{actor.id})"
puts "Wiki created: #{created_wikis.size}"
puts created_wikis.sort
puts "Wiki updated: #{updated_wikis.size}"
puts updated_wikis.sort
puts "Wiki unchanged: #{existing_wikis.size}"
puts "Help created: #{created_help.size}"
puts created_help.sort
puts "Help updated: #{updated_help.size}"
puts updated_help.sort
puts "Help unchanged: #{existing_help.size}"
