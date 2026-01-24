module Admin
  class ThoughtsController < BaseController
    def index
      @thoughts = Thought.recent.page(params[:page])
    end
  end
end
