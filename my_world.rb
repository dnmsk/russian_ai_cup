require './model/action_type'
require './vehicle_map'

module Strategies
  class MyWorld
    def initialize me, world
      @me = me
      @vehicle_map = VehicleMap.new(me, world)
      @ended_task = []
      @actions = []
    end

    def reinitialize me, world, game, move
      @me, @world, @game, @move = me, world, game, move

      @vehicle_map.read_updates(world)
    end

    def vehicle_map
      @vehicle_map
    end

    def game
      @game
    end

    def me
      @me
    end

    def enemy
      @world.opponent_player
    end

    def world
      @world
    end

    def ended_task
      @ended_task
    end

    def add_action action_base
      @actions.push(action_base)
    end

    def clear_and_add_action action_base
      @actions = []
      @actions.push(action_base)
    end

    def actions
      @actions
    end

    def apply_to_move data, defaults
      defaults.each { |k, v| @move.send("#{k}=".to_s, data[k] || v) }
      if @move.action == ActionType::CLEAR_AND_SELECT
        @last_selection = {
          group: @move.group,
          left: @move.left,
          top: @move.top,
          right: @move.right,
          bottom: @move.bottom,
          vehicle_type: @move.vehicle_type,
          facility_id: @move.facility_id,
          vehicle_id: @move.vehicle_id
        }
      end
    end

    def last_selection
      @last_selection
    end

#      {
#        action: nil,
#        group: 0,
#        left: 0.0,
#        top: 0.0,
#        right: 0.0,
#        bottom: 0.0,
#        x: 0.0,
#        y: 0.0,
#        angle: 0.0,
#        factor: 0.0,
#        max_speed: 0.0,
#        max_angular_speed: 0.0,
#        vehicle_type: nil,
#        facility_id: -1,
#        vehicle_id: -1
#      }
  end
end
