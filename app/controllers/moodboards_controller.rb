# frozen_string_literal: true

class MoodboardsController < ApplicationController
  respond_to :html, :json

  MAX_POSTS = 60
  MIN_POSTS = 6

  def index
    @tags = params[:tags].to_s.strip
    @layout = normalize_layout(params[:layout])
    @size = normalize_size(params[:size])
    @nonce = params[:nonce].presence || SecureRandom.hex(3)

    @posts = if @tags.present?
               PostSets::Post.new("#{@tags} order:random", 1, limit: @size).posts
             else
               Post.none
             end
  end

  private

  def normalize_layout(layout)
    %w[grid cinematic collage].include?(layout) ? layout : "grid"
  end

  def normalize_size(size)
    value = size.to_i
    return 18 if value <= 0

    value.clamp(MIN_POSTS, MAX_POSTS)
  end
end
