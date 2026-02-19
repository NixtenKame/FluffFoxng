# frozen_string_literal: true

module Moderator
  class BadgesController < ApplicationController
    before_action :moderator_only
    before_action :set_badge, only: %i[edit update destroy assign unassign]

    def index
      @badges = Badge.order(:name).includes(user_badges: :user)
      @badge = Badge.new
    end

    def create
      @badge = Badge.new(badge_params)
      if @badge.save
        redirect_to moderator_badges_path, notice: "Badge created."
      else
        @badges = Badge.order(:name).includes(user_badges: :user)
        render :index, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @badge.update(badge_params)
        redirect_to moderator_badges_path, notice: "Badge updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @badge.destroy
      redirect_to moderator_badges_path, notice: "Badge deleted."
    end

    def assign
      user = User.find_by_name(params[:user_name].to_s)
      if user.nil?
        return redirect_to moderator_badges_path, notice: "User not found."
      end

      user_badge = @badge.user_badges.new(user: user, creator_id: CurrentUser.id)
      if user_badge.save
        redirect_to moderator_badges_path, notice: "Badge assigned to #{user.name}."
      else
        redirect_to moderator_badges_path, notice: user_badge.errors.full_messages.to_sentence.presence || "Couldn't assign badge."
      end
    end

    def unassign
      user = User.find_by_name(params[:user_name].to_s)
      if user.nil?
        return redirect_to moderator_badges_path, notice: "User not found."
      end

      assignment = @badge.user_badges.find_by(user_id: user.id)
      if assignment
        assignment.destroy
        redirect_to moderator_badges_path, notice: "Badge removed from #{user.name}."
      else
        redirect_to moderator_badges_path, notice: "That user doesn't have this badge."
      end
    end

    private

    def set_badge
      @badge = Badge.find(params[:id])
    end

    def badge_params
      params.require(:badge).permit(:name, :description, :color, :active)
    end
  end
end
