module Api
  module V1
    class PreferencesController < BaseController
      before_action :set_user

      # GET /api/v1/preferences
      def show
        ret = {}
        ret[:id] = @user.id
        ret.merge!(@user.read_preferences)

        render json: ret, status: :ok
      end

      # PUT /api/v1/preferences
      # PATCH /api/v1/preferences
      def update
        @user.preferences = @user.read_preferences.merge!(params.require(:preference).permit(Visitor::ALLOW_PREFERENCES))
        head :not_modified and return if @user.changes.empty?

        if @user.save
          # Broadcast to lobby_channel
          message = {
            event: 'user_preferences_updated',
            user_id: @user.id,
            preferences: @user.read_preferences
          }
          ActionCable.server.broadcast 'lobby_channel', message

          render json: @user.read_preferences, status: :ok
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = Visitor.find(@jwt_request['sub'])
      end
    end
  end
end
