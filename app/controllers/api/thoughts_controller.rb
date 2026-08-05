module Api
  class ThoughtsController < BaseController
    include SourceDetectable

    before_action :set_thought, only: [ :show, :update, :destroy, :thread ]

    # GET /api/thoughts
    def index
      @thoughts = Thought.top_level.recent.page(params[:page]).per(params[:per_page] || 20)

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

      render json: { thought: thought_json(@thought, include_replies: true) }
    end

    # GET /api/thoughts/:id/thread
    def thread
      root = @thought.thread_root

      render json: { thought: thought_json(root, include_replies: true) }
    end

    # POST /api/thoughts
    def create
      @thought = Thought.new(thought_params)
      @thought.source = detect_source

      if params[:thought][:parent_id].present?
        parent = Thought.find_by(public_id: params[:thought][:parent_id])

        if parent.nil?
          render json: { errors: { parent_id: [ "does not exist" ] } }, status: :unprocessable_entity
          return
        end

        @thought.parent = parent
      end

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

    def thought_json(thought, include_replies: false)
      json = {
        id: thought.public_id,
        content: thought.content,
        tags: thought.tags,
        source: thought.source,
        parent_id: thought.parent&.public_id,
        reply_count: thought.reply_count,
        created_at: thought.created_at.iso8601
      }

      if thought.link_previews.present?
        json[:link_previews] = thought.link_previews.map do |preview|
          {
            url: preview["url"],
            title: preview["title"],
            description: preview["description"],
            image: preview["image"]
          }
        end
        # Keep legacy single link_preview for backwards compatibility
        first = thought.link_previews.first
        json[:link_preview] = {
          url: first["url"],
          title: first["title"],
          description: first["description"],
          image: first["image"]
        }
      end

      if include_replies
        json[:replies] = thought.replies.map { |reply| thought_json(reply, include_replies: true) }
      end

      json
    end
  end
end
