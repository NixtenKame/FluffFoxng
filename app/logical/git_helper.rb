# frozen_string_literal: true

module GitHelper
  def self.git(*args)
    Open3.capture3("git", "-c", "safe.directory=#{Rails.root}", *args)
  end

  def self.init
    if Rails.root.join("REVISION").exist?
      @hash = @tag = Rails.root.join("REVISION").read.strip
    elsif git("rev-parse", "--show-toplevel")[2].success?
      @hash = git("rev-parse", "HEAD")[0].strip
      @tag = git("describe", "--tags", "--abbrev=0")[0].strip
    else
      @hash = @tag = ""
    end
  end

  def self.tag
    @tag
  end

  def self.hash
    @hash
  end

  def self.version
    @tag.presence || short_hash
  end

  def self.short_hash
    @hash[0..8]
  end

  def self.commit_url(commit_hash)
    "#{Danbooru.config.source_code_url}/commit/#{commit_hash}"
  end

  def self.release_url(tag_name)
    "#{Danbooru.config.source_code_url}/releases/tag/#{tag_name}"
  end

  def self.version_url
    return release_url(@tag) if @tag.present?
    commit_url(@hash)
  end
end
