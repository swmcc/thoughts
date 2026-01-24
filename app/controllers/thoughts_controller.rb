class ThoughtsController < ApplicationController
  def index
    @thoughts = Thought.recent.page(params[:page]).per(20)

    if params[:tag].present?
      @thoughts = @thoughts.with_tag(params[:tag])
      @current_tag = params[:tag]
    end

    @popular_tags = Thought.pluck(:tags).flatten.tally.sort_by { |_, count| -count }.first(10).map(&:first)
  end

  def show
    @thought = Thought.find(params[:id])
    @thought.increment_view_count!
  end
end
