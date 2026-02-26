# frozen_string_literal: true

require "test_helper"

class DbExportTest < ActiveSupport::TestCase
  context "prune_old_exports!" do
    should "keep only the newest exports per table" do
      Dir.mktmpdir do |dir|
        exporter = DbExport.new
        exporter.stubs(:export_dir).returns(Pathname.new(dir))

        stub_const(DbExport, :TABLES, %w[posts tags]) do
          %w[2026-02-20 2026-02-21 2026-02-22].each do |date|
            FileUtils.touch(File.join(dir, "posts-#{date}.csv.gz"))
            FileUtils.touch(File.join(dir, "tags-#{date}.csv.gz"))
          end

          exporter.send(:prune_old_exports!, keep: 2)

          assert_equal(
            %w[posts-2026-02-21.csv.gz posts-2026-02-22.csv.gz],
            Dir.glob(File.join(dir, "posts-*.csv.gz")).map { |f| File.basename(f) }.sort,
          )
          assert_equal(
            %w[tags-2026-02-21.csv.gz tags-2026-02-22.csv.gz],
            Dir.glob(File.join(dir, "tags-*.csv.gz")).map { |f| File.basename(f) }.sort,
          )
        end
      end
    end
  end
end
