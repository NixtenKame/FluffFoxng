# frozen_string_literal: true

require "fileutils"
require "zlib"

class DbExport
  TABLES = %w[
    pools
    posts
    tag_aliases
    tag_implications
    tags
    wiki_pages
  ].freeze

  def self.daily!
    new.daily!
  end

  def daily!
    return if Danbooru.config.db_export_path.blank?

    FileUtils.mkdir_p(export_dir)
    date_stamp = Time.now.utc.strftime("%Y-%m-%d")

    TABLES.each do |table|
      export_table(table, date_stamp)
    end

    prune_old_exports!(keep: Danbooru.config.db_export_keep_latest.to_i)
  end

  private

  def export_dir
    @export_dir ||= begin
      export_path = Danbooru.config.db_export_path.to_s.sub(%r{^/}, "")
      Rails.root.join("public", export_path)
    end
  end

  def export_table(table, date_stamp)
    destination = export_dir.join("#{table}-#{date_stamp}.csv.gz")
    temporary = "#{destination}.tmp"

    File.open(temporary, "wb") do |file|
      gzip = Zlib::GzipWriter.new(file, Zlib::BEST_COMPRESSION)
      copy_table_as_csv(table, gzip)
      gzip.close
    end

    FileUtils.mv(temporary, destination)
  ensure
    FileUtils.rm_f(temporary) if temporary.present?
  end

  def prune_old_exports!(keep:)
    return if keep <= 0

    TABLES.each do |table|
      exports = Dir.glob(export_dir.join("#{table}-*.csv.gz")).sort.reverse
      old_exports = exports.drop(keep)
      FileUtils.rm_f(old_exports)
    end
  end

  def copy_table_as_csv(table, output)
    connection = ActiveRecord::Base.connection
    raw = connection.raw_connection
    quoted_table = connection.quote_table_name(table)
    sql = "COPY (SELECT * FROM #{quoted_table}) TO STDOUT WITH (FORMAT CSV, HEADER TRUE)"

    raw.copy_data(sql) do
      while (row = raw.get_copy_data)
        output.write(row)
      end
    end
  end
end
