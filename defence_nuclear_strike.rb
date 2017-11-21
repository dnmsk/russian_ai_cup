module Strategies::Actions
  class DefenceNuclearStrike
    def call(my_world, params = {})
      return if @in_progress
      @in_progress = true
      strike_point = Strategies::Point.new(
        my_world.world.opponent_player.next_nuclear_strike_x,
        my_world.world.opponent_player.next_nuclear_strike_y
      )  
      actions = [
        { name: :select, act: ->(rectangle) {
            [Strategies::Point.new(strike_point.x-100, strike_point.y-100),
              Strategies::Point.new(strike_point.x+100, strike_point.y+100)] } },
        { name: :scale, act: ->(p) { {factor: 10, point: strike_point } }, ticks: -99999999, delayed: :vehicle_stops},
        { name: :wait, act: ->() { my_world.world.opponent_player.remaining_action_cooldown_ticks <= 0 }, ticks: -99999999 },
        { name: :scale, act: ->(p) { {factor: 0.1, point: strike_point } }, ticks: -99999999},
      ]

      Strategies::Actions::Base.
        new("SquadMove_#{@group}", actions, {vehicle_type: 0}).call()
    end

    def need_run?(my_world, params = {})
      my_world.world.opponent_player.remaining_action_cooldown_ticks > 0
    end
  end
end
