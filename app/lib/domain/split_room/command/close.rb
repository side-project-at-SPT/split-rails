module Domain
  module SplitRoom
    module Command
      class Close
        def initialize(params = {})
          @room = params[:room]
          @user = Visitor.find_by(id: params.dig(:user_request, :sub))
          @gaas_auth0_token = params.dig(:user_request, :gaas_auth0_token)
          @error = nil
        end

        attr_reader :room, :user, :gaas_auth0_token
        attr_accessor :error

        def call
          validate!
          return self unless error.nil?

          # TODO: Refactor the integration with GAAS
          room.call_gaas_end_game(gaas_auth0_token)
          room.close

          Domain::CloseRoomEvent.new(room_id: room.id).dispatch

          self
        end

        private

        def validate!
          self.error = RoomIsRequired.new and return if room.nil?
          self.error = UserIsRequired.new and return if user.nil?
          self.error = UserIsNotOwner.new and return unless can_close_the_room?
        end

        def can_close_the_room?
          room.owner_id == user.id || user.role_admin?
        end
      end

      class RoomIsRequired < StandardError; end
      class UserIsRequired < StandardError; end
      class UserIsNotOwner < StandardError; end
    end
  end
end
