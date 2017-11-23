module Strategies::Actions
  class DefenceNuclearStrike
    def initialize my_world
      @my_world = my_world
    end
    def call(params = {})
      my_vehicles = @my_world.vehicle_map.my_vehicle
      my_position = @my_world.vehicle_map.my_vehicle.position
      strike_point = Strategies::Point.new(
#        my_position.x, my_position.y
        @my_world.world.opponent_player.next_nuclear_strike_x,
        @my_world.world.opponent_player.next_nuclear_strike_y
      )
      return unless strike_point.in_reactangle? my_vehicles.rectangle
      return if @in_progress
      @in_progress = true

#      ap "DefenceNuclearStrike"
#      ap my_position
#      ap strike_point

      move_at_index = nil
      move_length = nil
      back_move_index = nil
      actions = [
        { name: :select, act: ->(rectangle) { nil }},
        { name: :scale, act: ->(p) {
          move_at_index = @my_world.world.tick_index
#          move_length = 40
          move_length = @my_world.world.opponent_player.remaining_action_cooldown_ticks
          { factor: 10, point: strike_point }
        }},
        { name: :scale, act: ->(p) {
          @in_progress = false; {factor: 0.1, point: strike_point }
        }, delayed: :wait, can_move: ->() {
            back_move_index = @my_world.world.tick_index
#            move_at_index + move_length < @my_world.world.tick_index
            @my_world.world.opponent_player.remaining_action_cooldown_ticks <= 0
        }},
        { name: :empty, delayed: :wait, can_move: ->() {
            @my_world.world.tick_index > back_move_index + move_length
        }},
      ]

      Strategies::Actions::Base.new(
        @my_world, :DefenceNuclearStrike, actions,
        { group: Strategies::SquadType::OLOLO_TROLOLO, blocking_action: true }
      ).call()
    end

    def need_run?(params = {})
      @call_id ||= 0
      return true if (@call_id += 1) % 800 == 0 && @my_world.ended_task.include?(:initial_complete)
      !@in_progress && @my_world.world.opponent_player.remaining_action_cooldown_ticks > 0
    end
  end
end
