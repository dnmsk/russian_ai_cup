require './base'
require './point'
require './vehicle'

module Strategies
  class Squad
    def initialize my_world, group, angle, squad_speed=0
      @my_world, @group, @angle, @squad_speed = my_world, group, angle, squad_speed
    end

    def group
      @group
    end

    def move_to_point point, mine_vehicles=nil
      actions = [
        { name: :select, act: ->(rectangle) { nil } },
        { name: :move, act: ->(p) { @in_progress = false; point }, ticks: rnd, delayed: :vehicle_stops, speed: @squad_speed},
      ]
      execute_strategy(actions, mine_vehicles)
    end

    def attack_vehicles vehicles
      mine_vehicles = my_vehicles
      point = enemy_point(mine_vehicles, vehicles)
      if point.nil?
        return Strategies::Actions::ActionWrapper.new(self, {
          state: Strategies::ActionStateType::ENDED,
          name: "Squad_#{@group}"
        })
      end
      move_to_point(point, mine_vehicles)
    end

    def in_progress?
      @in_progress || ((@last_tick ||0) + 40) > @my_world.world.tick_index
    end

    def vehicles
      @my_world.vehicle_map.my_vehicle(nil, @group)
    end

    private

    def execute_strategy actions, mine_vehicles
      mine_vehicles = mine_vehicles || my_vehicles
      @last_tick = @my_world.world.tick_index
      @last_vehicles_count ||= mine_vehicles.vehicles.count
      @in_progress = true

      
      if (mine_vehicles.vehicles.count/@last_vehicles_count.to_f) < 0.9
        actions.insert(1, { name: :scale, act: ->(point) { {factor: 0.1} }, delayed: :vehicle_stops, ticks: rnd })
        actions.insert(1, { name: :rotate, act: ->() { 0.25 }, ticks: rnd })
        @last_vehicles_count = mine_vehicles.vehicles.count
      else
        actions.insert(1, { name: :scale, act: ->(point) { {factor: 0.1} }, ticks: rnd })
      end

      @my_world.add_action(Strategies::Actions::Base.
        new("SquadMove_#{@group}", actions, {group: @group}, false))
      return nil
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
      my_rectangle = mine.rectangle
      my_position = mine.position
      Strategies::Point.new(
        enemy_rectangle[0].x + (my_rectangle[1].x - my_rectangle[0].x), 
        enemy_rectangle[0].y + (my_rectangle[1].y - my_rectangle[0].y), 
      )
    end

    def rnd
      #-999999
      @rnd ||= -(Random.rand*10000000).to_i
    end
  end
end
