module Api
  class ThoughtsController < BaseController
    include SourceDetectable

    before_action :set_thought, only: [ :show, :update, :destroy ]

    # GET /api/thoughts
    def index
      @thoughts = Thought.recent.page(params[:page]).per(params[:per_page] || 20)

      if params[:tag].present?
        @thoughts = @thoughts.with_tag(params[:tag])
      end

      # Increment view count for public (unauthenticated) requests
      @thoughts.each(&:increment_view_count!) unless authenticated?

      render json: {
        thoughts: @thoughts.map { |t| thought_json(t) },
        meta: {
          total: @thoughts.total_count,
          page: @thoughts.current_page,
          per_page: @thoughts.limit_value
        }
      }
    end

    # GET /api/thoughts/:id
    def show
      # Increment view count for public (unauthenticated) requests
      @thought.increment_view_count! unless authenticated?

      render json: { thought: thought_json(@thought) }
    end

    # POST /api/thoughts
    def create
      @thought = Thought.new(thought_params)
      @thought.source = detect_source

      if @thought.save
        render json: { thought: thought_json(@thought) }, status: :created
      else
        render json: { errors: @thought.errors.messages }, status: :unprocessable_entity
      end
    end

    # PATCH /api/thoughts/:id
    def update
      if @thought.update(thought_params)
        render json: { thought: thought_json(@thought) }
      else
        render json: { errors: @thought.errors.messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/thoughts/:id
    def destroy
      @thought.destroy
      head :no_content
    end

    private

    def set_thought
      @thought = Thought.find_by!(public_id: params[:id])
    end

    def thought_params
      params.require(:thought).permit(:content, tags: [])
    end

    def thought_json(thought)
      json = {
        id: thought.public_id,
        content: thought.content,
        tags: thought.tags,
        source: thought.source,
        created_at: thought.created_at.iso8601
      }

      if thought.link_url.present?
        json[:link_preview] = {
          url: thought.link_url,
          title: thought.link_title,
          description: thought.link_description,
          image: thought.link_image
        }
      end

      json
    end
  end
end
