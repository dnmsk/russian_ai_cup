module Strategies::Actions
  class Attack
    def initialize squads
      @squads = squads
    end

    def call(my_world, params = {})
      enemies = enemies_by_distance(my_world)
      enemy = enemies.first[1]
      if attack?(my_world)
        @squads[Strategies::SquadType::AIR].attack_vehicles(enemy)
      else
        @squads[Strategies::SquadType::AIR].move_to_point(@squads[Strategies::SquadType::FIGHTERS].forces.position)
      end
      @squads[Strategies::SquadType::FIGHTERS].attack_vehicles(enemy)
    end

    def need_run?(my_world, params = {})
      @need_run ||= my_world.ended_task.include?(:initial_complete)
      @need_run && !@squads.select{|(k, v)| @squads[k].in_progress?}.any?
    end

    private

    def air_follow_ground
    end

    def attack? my_world
      enemies = enemy_groups my_world
      my_position = my_forces_position
#      ap my_position
#      ap enemies.map{|a| "#{a[0]} #{a[1].count}"}
      enemies_arr = enemies.
        sort{|e| Strategies::Point.distance_to_rect(e[0], my_position.x, my_position.y)}.
        first
      Strategies::Point.distance_to_rect(enemies_arr[0], my_position.x, my_position.y) < 40
    end

    def enemies_by_distance my_world
      enemies = enemy_groups my_world
      my_position = my_forces_position
      enemies_arr = enemies.
        sort{|e| Strategies::Point.distance_to_rect(e[0], my_position.x, my_position.y)}
    end

    def my_forces_position
      @squads[Strategies::SquadType::FIGHTERS].forces.position
    end

    def enemy_groups my_world
      point_class = Strategies::Point
      enemies = my_world.vehicle_map.enemy_vehicle.vehicles
      groups = []
      enemies.sort{|v|v[:x]}.sort{|v|v[:y]}.each do |v|
        found = false
        groups.each do |g|
          rectangle = g[:rectangle]
          if point_class.distance_to_rect(rectangle, v[:x], v[:y]) < 20
            found = true
            g[:vehicles].push(v)
            point_class.expand_rect(rectangle, v[:x], v[:y])
            break
          end
        end
        unless found
          groups << {
            rectangle:[point_class.new(v[:x], v[:y]), point_class.new(v[:x], v[:y])],
            vehicles: [v]
          }
        end
      end
      groups.map{|g| [g[:rectangle], g[:vehicles]]}
    end
  end
end
