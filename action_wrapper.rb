module Strategies::Actions
  class ActionWrapper
    def initialize action, state
      @action, @state = action, state
    end

    def call(my_world, params = {})
      @action.(my_world, @state)
    end

    def need_run?(my_world, params = {})
      @action.need_run?(my_world, @state)
    end

    def [](key)
      @state[key]
    end

    def []=(key, value)
      @state[key] = value
    end

    def state
      @state
    end
  end
end
