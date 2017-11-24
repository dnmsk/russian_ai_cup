require './base'
require './point'
require './vehicle'

module Strategies
  class Squad
    def initialize my_world, group, angle, squad_speed, distance_limit = 30
      @my_world, @group, @angle, @squad_speed, @distance_limit =
        my_world, group, angle, squad_speed, distance_limit
    end

    def group
      @group
    end

    def move_to_point point, on_complete=nil
      actions = [
        { name: :select, act: ->(rectangle) { nil } },
        { name: :scale, act: ->(point) { {factor: 0.1} }},
        { name: :move, act: ->(p) { to_point(p, point) }, speed: @squad_speed, delayed: :vehicle_stops },
        { name: :empty, act: ->() { @in_progress = false; on_complete && on_complete.() }, delayed: :vehicle_stops }
      ]
      execute_strategy(actions, my_vehicles)
    end

    def attack_vehicles vehicles
      mine_vehicles = my_vehicles
      point = enemy_point(mine_vehicles, vehicles)
      if point.nil?
        return nil
      end

      actions = [
        { name: :select, act: ->(rectangle) { nil } },
        { name: :scale, act: ->(point) { {factor: 0.1} }},
        { name: :move, act: ->(p) {
          to_point(p, enemy_point(my_vehicles, vehicles) || p)
        }, speed: @squad_speed, delayed: :vehicle_stops},
        { name: :empty, act: ->() { @in_progress = false }, delayed: :vehicle_stops }
      ]
      execute_strategy(actions, mine_vehicles)
    end

    def in_progress?
      @in_progress || ((@last_tick ||0) + 40) > @my_world.world.tick_index
    end

    def vehicles
      @my_world.vehicle_map.my_vehicle(nil, @group)
    end

    private

    def to_point my_position, point
      Strategies::Point.to_point_with_limit(my_position, point, @distance_limit)
    end

    def execute_strategy actions, mine_vehicles
      mine_vehicles = mine_vehicles || my_vehicles
      @last_tick = @my_world.world.tick_index
      @last_vehicles_count ||= mine_vehicles.vehicles.count
      @in_progress = true
      @call_id ||= 0

      #if (@call_id += 1) % 2 == 0
      #  actions.insert(1, { name: :rotate, act: ->() { Math::PI/4 } })
      #  actions.insert(2, { name: :scale, act: ->(vehicles) { {factor: 0.1 } }, delayed: :ticks, sleep: 15 })
      #  actions.insert(3, { name: :scale, act: ->(vehicles) { {factor: 0.1 } }, delayed: :vehicle_stops })
      #end

      Strategies::Actions::Base.
        new(@my_world, "SquadMove_#{@group}", actions, {group: @group}, false).()
    end

    def my_vehicles
      m = @my_world.vehicle_map.my_vehicle(nil, @group)
      if m.vehicles.empty?
        @in_progress = true
      end
      m
    end

    def enemy_point mine, enemy_vehicles
      return nil if enemy_vehicles.empty? || mine.vehicles.empty?
      enemy_rectangle = Strategies::Vehicle.new(enemy_vehicles).rectangle
      enemy_position = Strategies::Vehicle.new(enemy_vehicles).position
      return nil if enemy_rectangle.nil? || enemy_position.nil?
      my_rectangle = mine.rectangle
      my_position = mine.position
      Strategies::Point.new(
        (enemy_rectangle[0].x + enemy_position.x)/2, 
        (enemy_rectangle[0].y + enemy_position.y)/2, 
      )
    end
  end
end
