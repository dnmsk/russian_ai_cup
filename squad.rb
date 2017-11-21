require './base'
require './point'
require './vehicle'

module Strategies
  class Squad
    def initialize my_world, group, angle
      @my_world, @group, @angle = my_world, group, angle
    end

    def group
      @group
    end

    def move_to_point point
      actions = [
        { name: :select, act: ->(rectangle) { nil } },
        { name: :move, act: ->(p) { @in_progress = false; point }, ticks: rnd, delayed: :vehicle_stops},
      ]
      execute_strategy(actions)
    end

    def attack_vehicles vehicles
      point = enemy_point(vehicles)
      if point.nil?
        return Strategies::Actions::ActionWrapper.new(self, {
          state: Strategies::ActionStateType::ENDED,
          name: "Squad_#{@group}"
        })
      end
      move_to_point(point)
    end

    def in_progress?
      @in_progress || ((@last_tick ||0) + 40) > @my_world.world.tick_index
    end

    def forces
      @my_world.vehicle_map.my_vehicle(nil, @group)
    end

    private

    def execute_strategy actions
      @last_tick = @my_world.world.tick_index
      @call_id = (@call_id || 0) + 1
      @in_progress = true

      actions.insert(1, { name: :scale, act: ->(point) { {factor: 0.1} }, ticks: rnd })
      if ((@call_id += 1) % 5 == 1)
        actions.insert(1, { name: :rotate, act: ->() { 0.25 }, ticks: rnd })
      end

      @my_world.add_action(Strategies::Actions::Base.
        new("SquadMove_#{@group}", actions, {group: @group}, false))
      return nil
#      Strategies::Actions::Base.
#        new("SquadMove_#{@group}", actions, {group: @group}, false).
#        call(@my_world)
    end

    def my_vehicles
      m = @my_world.vehicle_map.my_vehicle(nil, @group)
      if m.vehicles.empty?
        @in_progress = true
      end
      m
    end

    def enemy_point enemy_vehicles
      mine = my_vehicles
      return nil if enemy_vehicles.empty? || mine.vehicles.empty?
      enemy_rectangle = Strategies::Vehicle.new(enemy_vehicles).rectangle
      enemy_position = Strategies::Vehicle.new(enemy_vehicles).position
      my_rectangle = mine.rectangle
      my_position = mine.position
      Strategies::Point.new(
        enemy_rectangle[0].x + (my_rectangle[1].x - my_rectangle[0].x)/2, 
        enemy_rectangle[0].y + (my_rectangle[1].y - my_rectangle[0].y)/2, 
      )
    end

    def rnd
      #-999999
      @rnd ||= -(Random.rand*10000000).to_i
    end
  end
end
