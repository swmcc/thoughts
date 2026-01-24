class ThoughtsController < ApplicationController
  def index
    @thoughts = Thought.recent.page(params[:page]).per(25)

    if params[:tag].present?
      @thoughts = @thoughts.with_tag(params[:tag])
      @current_tag = params[:tag]
    end

    if params[:q].present?
      @thoughts = @thoughts.search(params[:q])
      @search_query = params[:q]
    end

    @popular_tags = Thought.pluck(:tags).flatten.tally.sort_by { |_, count| -count }.first(10).map(&:first)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @thought = Thought.find_by!(public_id: params[:id])
    @thought.increment_view_count!
  end
end
