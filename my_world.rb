require './model/action_type'
require './move_processor'
require './vehicle_map'

module Strategies
  class MyWorld
    WEATHER_FACTOR = {
      WeatherType::CLEAR => { speed: 1, view: 1, stealth: 1 }, 
      WeatherType::CLOUD => { speed: 0.8, view: 0.8, stealth: 0.8 }, 
      WeatherType::RAIN => { speed: 0.6, view: 0.6, stealth: 0.6 }, 
    }.freeze
    TERRAIN_FACTOR = {
      TerrainType::PLAIN => { speed: 1, view: 1, stealth: 1 },
      TerrainType::SWAMP => { speed: 0.6, view: 1, stealth: 1 },
      TerrainType::FOREST => { speed: 0.8, view: 0.8, stealth: 0.6 },
    }.freeze

    def initialize me, world
      @me = me
      @world = world
      @weather = world.terrain_by_cell_x_y
      @terrain = world.weather_by_cell_x_y
      @vehicle_map = VehicleMap.new(me, self)
      @ended_task = []
      @actions = []
      @move_processor = Strategies::MoveProcessor.new(self)
    end

    def reinitialize me, world, game, move
      @me, @world, @game, @move = me, world, game, move

      @vehicle_map.read_updates
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

    def k_for_weather x, y, type
      WEATHER_FACTOR[@weather[(x/32).to_i][(y/32).to_i]][type]
    end

    def k_for_terrain x, y, type
      TERRAIN_FACTOR[@weather[(x/32).to_i][(y/32).to_i]][type]
    end

    def actions
      @actions
    end

    def build_factor(speed, view, stealth)
      {
        speed: speed,
        view: view,
        stealth: stealth
      }
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
