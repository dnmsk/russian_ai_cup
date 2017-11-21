require './model/action_type'
require './move_processor'
require './vehicle_map'

module Strategies
  class MyWorld
    def initialize me, world
      @me = me
      @vehicle_map = VehicleMap.new(me, world)
      @ended_task = []
      @actions = []
      @move_processor = Strategies::MoveProcessor.new(self)
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

    def move_processor
      @move_processor
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
