# frozen_string_literal: true

class ComicsController < ApplicationController
  respond_to :html, :json

  def index
    @comics = Pool.search(search_params.merge(category: "series", is_active: true))
                  .order(updated_at: :desc)
                  .paginate(params[:page], limit: params[:limit], search_count: params[:search])
  end

  def show
    @comic = Pool.find(params[:id])
    @posts = @comic.posts.paginate_posts(params[:page], limit: params[:limit], total_count: @comic.post_ids.count)
  end

  def reader
    @comic = Pool.find(params[:id])
    @position = params.fetch(:position, 1).to_i.clamp(1, [@comic.post_ids.length, 1].max)
    @post = Post.find_by(id: @comic.post_ids[@position - 1])

    @previous_position = @position > 1 ? @position - 1 : nil
    @next_position = @position < @comic.post_ids.length ? @position + 1 : nil
  end
end
