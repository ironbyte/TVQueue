require 'open-uri'
class QueuedEpisodesController < ApplicationController
  before_action :authenticate_user!

  def toggle_viewed_status
     queued_episode = current_user.queued_episodes.find_by(id: toggle_viewed_status_params["queued_episode_id"])
     queued_episode.viewed = !queued_episode.viewed
     queued_episode.save

     respond_to do |format|
       format.html { redirect_to root_url, notice: " " }
     end


  end

  def index
    @user = current_user
    @complete_queue = @user.queued_episodes.joins(:episode).order('episodes.airdate desc')
    @next_episode = @complete_queue.where(viewed: false).last || @complete_queue.first
    cqe = Episode.where(id: @complete_queue.map(&:episode_id))
    cqt = TvShow.where(id: cqe.map(&:tv_show_id).uniq)

    cqt.each do |show|
      add_or_update_show(show)
      add_or_update_episodes(show)
    end

    respond_to do |format|
      format.html { queued_episodes_index_path(:anchor => 'next-episode') }
    end
  end

  private

  def toggle_viewed_status_params
    params.permit(:queued_episode_id)
  end

end
