module Api
  module V1
    class BotsController < BaseController
      before_action :set_user
      before_action :set_bot, only: %i[show update destroy]

      def create
        @bot = Bot.new(bot_params)
        @bot.owner = @user
        @bot.save!

        render json: {
          id: @bot.id,
          name: @bot.name,
          webhook_url: @bot.webhook_url,
          concurrent_number: @bot.concurrent_number
        }, status: :created
      end

      def index
        @bots = Bot.where(owner: @user).select(:id, :name, :webhook_url, :concurrent_number).order(:id)
        render json: { bots: @bots }, status: :ok
      end

      def show
        render json: {
          id: @bot.id,
          name: @bot.name,
          webhook_url: @bot.webhook_url,
          concurrent_number: @bot.concurrent_number
        }, status: :ok
      end

      def update
        @bot.update!(bot_params)
        head :ok
      end

      def destroy
        @bot.destroy!
        head :no_content
      end

      private

      def bot_params
        params.require(:bot).permit(:name, :webhook_url, :concurrent_number)
      end

      def set_bot
        @bot = Bot.where(owner: @user).find(params[:id])
      end

      def set_user
        @user = Visitor.find_by(id: @jwt_request['sub'])

        render json: { error: 'Failed to authenticate' }, status: :unauthorized unless @user
      end
    end
  end
end
