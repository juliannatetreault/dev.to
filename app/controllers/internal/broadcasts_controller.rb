module Internal
  class BroadcastsController < Internal::ApplicationController
    layout "internal"

    def index
      @broadcasts = if params[:broadcastable_type]
                      Broadcast.where(broadcastable_type: params[:broadcastable_type].capitalize)
                    else
                      Broadcast.all
                    end.order(title: :asc)
    end

    def show
      @broadcast = Broadcast.find(params[:id])
    end

    def new
      @broadcast = Broadcast.new
    end

    def edit
      @broadcast = Broadcast.find(params[:id])
    end

    def create
      @broadcast = Broadcast.new(broadcast_params)
      broadcastable_type = broadcast_params[:broadcastable_type]

      @broadcast.broadcastable = create_broadcastable(broadcastable_type)

      if @broadcast.save
        flash[:success] = "Broadcast has been created!"
        redirect_to internal_broadcast_path(@broadcast)
      else
        flash[:danger] = @broadcast.errors.full_messages.to_sentence
        render new_internal_broadcast_path
      end
    end

    def update
      @broadcast = Broadcast.find(params[:id])
      broadcastable = @broadcast.broadcastable

      broadcastable_type = broadcast_params[:broadcastable_type]

      if broadcastable.class.name == broadcastable_type
        broadcastable.update(banner_style: broadcast_params[:banner_style]) if broadcastable_type == "Announcement"
      else
        @broadcast.update(broadcastable: create_broadcastable(broadcastable_type))
      end

      if @broadcast.update(broadcast_params)
        flash[:success] = "Broadcast has been updated!"
        redirect_to internal_broadcast_path(@broadcast)
      else
        flash[:danger] = @broadcast.errors.full_messages.to_sentence
        render :edit
      end
    end

    def destroy
      @broadcast = Broadcast.find(params[:id])

      if @broadcast.destroy
        flash[:success] = "Broadcast has been deleted!"
        redirect_to internal_broadcasts_path
      else
        flash[:danger] = "Something went wrong with deleting the broadcast."
        render :edit
      end
    end

    private

    def create_broadcastable(broadcastable_type)
      broadcastable = broadcastable_type.constantize.new
      broadcastable.banner_style = broadcast_params[:banner_style] if broadcastable_type == "Announcement"
      broadcastable.save!
      broadcastable
    end

    def broadcast_params
      params.permit(:title, :processed_html, :broadcastable_type, :broadcastable_id, :banner_style, :active)
    end

    def authorize_admin
      authorize Broadcast, :access?, policy_class: InternalPolicy
    end
  end
end
