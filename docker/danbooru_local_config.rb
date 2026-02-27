# frozen_string_literal: true

module Danbooru
  class CustomConfiguration < Configuration
    # Site-wide safe mode default. Users can still enable personal safe mode.
    def safe_mode?
      false
    end

    def webp_previews_enabled?
      true
    end

    # In local/dev setups, serve post files from the dedicated file-server.
    def storage_manager
      StorageManager::Local.new(
        base_dir: Rails.public_path.join("data").to_s,
        hierarchical: true,
        base_url: ENV.fetch("DANBOORU_DATA_BASE_URL", ""),
        base_path: "/data"
      )
    end
  end
end
