require './squad'

module Strategies::Actions
  class InitialDefence
    RANGE_FOR_DEFENCE = 550

    PRIORITIES = {
      VehicleType::FIGHTER => 1,
      VehicleType::HELICOPTER => 0,
      VehicleType::IFV => 2,
      VehicleType::TANK => 3,
      VehicleType::ARRV => 4,
    }

    def initialize my_world, group
      @squad = Strategies::Squad.new(my_world, group, 0)
      @check_index = 0
    end

    def call(my_world, params = {})
      @call_id ||= 0
      @squad.attack_vehicles(enemies(my_world).first[1])
    end

    def need_run?(my_world, params = {})
      @need_run ||= !my_world.ended_task.include?(:initial_complete)
      return false if !@need_run
      if (@check_index+=1) % (@call_id ? 5 : 20) == 0 && !@squad.in_progress?
        pos = Strategies::Vehicle.new(allowed_enemies(my_world)).rectangle
        return pos && pos[0].x < RANGE_FOR_DEFENCE && pos[0].y < RANGE_FOR_DEFENCE
      end
    end

    private

    def enemies my_world
      allowed_enemies(my_world).group_by{|v| v[:type]}.sort_by{|v| PRIORITIES[v[0]]}
    end

    def allowed_enemies my_world
      my_world.vehicle_map.enemy_vehicle.vehicles.select do |v|
        v[:x] < RANGE_FOR_DEFENCE &&
          v[:y] < RANGE_FOR_DEFENCE &&
          PRIORITIES.keys.include?(v[:type])
      end
    end
  end
end
