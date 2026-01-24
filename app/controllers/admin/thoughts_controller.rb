module Admin
  class ThoughtsController < BaseController
    before_action :set_thought, only: [ :show, :edit, :update, :destroy ]

    def index
      @thoughts = Thought.recent.page(params[:page]).per(20)
    end

    def show
    end

    def new
      @thought = Thought.new
    end

    def create
      @thought = Thought.new(thought_params)
      if @thought.save
        redirect_to admin_thoughts_path, notice: "Thought was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @thought.update(thought_params)
        redirect_to admin_thoughts_path, notice: "Thought was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @thought.destroy
      redirect_to admin_thoughts_path, notice: "Thought was successfully deleted."
    end

    private

    def set_thought
      @thought = Thought.find_by!(public_id: params[:id])
    end

    def thought_params
      params.require(:thought).permit(:content, :created_at, tags: [])
    end
  end
end
