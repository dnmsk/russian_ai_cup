module Strategies::Actions
  class DefenceNuclearStrike
    def initialize my_world
      @my_world = my_world
    end
    def call(params = {})
      return if @in_progress
      @in_progress = true
      my_position = @my_world.vehicle_map.my_vehicle.position
      strike_point = Strategies::Point.new(
        #my_position.x, my_position.y
        @my_world.world.opponent_player.next_nuclear_strike_x,
        @my_world.world.opponent_player.next_nuclear_strike_y
      )
#      ap "DefenceNuclearStrike #{strike_point.x} #{strike_point.y}"
#      ap "DefenceNuclearStrike 1"; 
      actions = [
        { name: :select, act: ->(rectangle) {
#          ap("DefenceNuclearStrike 1"); 
            [Strategies::Point.new(strike_point.x-100, strike_point.y-100),
              Strategies::Point.new(strike_point.x+100, strike_point.y+100)] } },
        { name: :scale, act: ->(p) { {factor: 10, point: strike_point } }},
        { name: :wait, act: ->() { @my_world.world.opponent_player.remaining_action_cooldown_ticks <= 0 } },
        { name: :scale, act: ->(p) { @in_progress = false; {factor: 0.1, point: strike_point } } },
      ]

      Strategies::Actions::Base.
        new(@my_world, "SquadMove_#{@group}", actions, {vehicle_type: 0}).call()
    end

    def need_run?(params = {})
      @call_id ||= 0
      #return true if (@call_id += 1) % 50 == 0 && @my_world.ended_task.include?(:initial_complete)
      !@in_progress && @my_world.world.opponent_player.remaining_action_cooldown_ticks > 0
    end
  end
end
