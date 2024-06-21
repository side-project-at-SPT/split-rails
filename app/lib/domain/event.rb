module Domain
  class Event
    def initialize(params = {})
      @params = params
    end

    attr_reader :params

    def identifier=
      raise 'Not implemented'
    end

    def event_type=
      raise 'Not implemented'
    end

    def dispatch
      ActionCable
        .server
        .broadcast(
          identifier,
          { event: event_type }.merge(params)
        )
    end
  end
end
