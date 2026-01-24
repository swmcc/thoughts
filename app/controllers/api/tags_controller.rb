module Api
  class TagsController < BaseController
    skip_before_action :authenticate_for_write

    def index
      # Get unique tags from all thoughts
      tags = Thought.pluck(:tags).flatten.uniq.compact.sort
      render json: { tags: tags }
    end
  end
end
