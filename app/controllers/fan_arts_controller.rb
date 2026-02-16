# frozen_string_literal: true

class FanArtsController < ApplicationController
  before_action :redirect_to_index, only: %i[show]

  def index
    @fan_artworks = FanArt.ordered
  end

  def new
    @fan_art = FanArt.new
  end

  def create
    @fan_art = FanArt.new(fan_art_params)

    if @fan_art.save
      redirect_to fan_arts_path, notice: "Fan art submitted successfully! Thank you for your contribution."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    redirect_to fan_arts_path
  end

  private

  def fan_art_params
    params.require(:fan_art).permit(:title, :image_url, :artist_name, :artist_url)
  end

  def redirect_to_index
    redirect_to fan_arts_path
  end
end
