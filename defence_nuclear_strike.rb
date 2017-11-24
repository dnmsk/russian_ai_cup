module Strategies::Actions
  class DefenceNuclearStrike
    def initialize my_world
      @my_world = my_world
    end
    def call(params = {})
      my_vehicles = @my_world.vehicle_map.my_vehicle
      my_position = @my_world.vehicle_map.my_vehicle.position
      strike_player = player_with_strike
      return if strike_player.nil?
      strike_point = Strategies::Point.new(
#        my_position.x, my_position.y
        strike_player.next_nuclear_strike_x,
        strike_player.next_nuclear_strike_y
      )
      return unless strike_point.in_reactangle? my_vehicles.rectangle
      return if @in_progress
      @in_progress = true

      move_at_index = nil
      move_length = nil
      back_move_index = nil
      actions = [
        { name: :select, act: ->(rectangle) { nil }},
        { name: :scale, act: ->(p) {
#          move_length = 40
          move_length = strike_player.next_nuclear_strike_tick_index - @my_world.world.tick_index
          back_move_index = @my_world.world.tick_index + move_length
          { factor: 10, point: strike_point }
        }},
        { name: :scale, act: ->(p) {
          {factor: 0.1, point: strike_point }
        }, delayed: :wait, can_move: ->() {
            @my_world.world.tick_index > back_move_index
        }},
        { name: :empty, delayed: :wait, can_move: ->() {
            @in_progress = false; 
            @my_world.world.tick_index > back_move_index + move_length
        }},
      ]

      Strategies::Actions::Base.new(
        @my_world, :DefenceNuclearStrike, actions,
        { group: Strategies::SquadType::OLOLO_TROLOLO, blocking_action: true }
      ).call()
    end

    def need_run?(params = {})
      #@call_id ||= 0
      #return true if (@call_id += 1) % 800 == 0 && @my_world.ended_task.include?(:initial_complete)
      !@in_progress && player_with_strike != nil
    end

    def player_with_strike
      @my_world.world.players.find do |player|
        player.next_nuclear_strike_tick_index > 0 &&
        player.next_nuclear_strike_x > 0 &&
        player.next_nuclear_strike_y > 0
      end
    end
  end
end
