module Strategies::Actions
  class Attack
    def initialize my_world, squads
      @my_world, @squads = my_world, squads
    end

    def call(params = {})
      enemies = enemies_by_distance
      enemy = enemies.first[1]

      my_position = @squads[Strategies::SquadType::OLOLO_TROLOLO].vehicles.position
      enemy_position = Strategies::Vehicle.new(enemy).position

#ap my_position
#ap enemies.map{|e| [e[0], e[1].count] }
      if attack?
        @squads[Strategies::SquadType::OLOLO_TROLOLO].attack_vehicles(enemy)
        #@squads[Strategies::SquadType::FIGHTERS].attack_vehicles(enemy)
      else
        next_position = Strategies::Point.new(
          (my_position.x+enemy_position.x)/2,
          (my_position.y+enemy_position.y)/2
        )
        @squads[Strategies::SquadType::OLOLO_TROLOLO].move_to_point(next_position)
        #@squads[Strategies::SquadType::FIGHTERS].move_to_point(next_position)
      end
    end

    def need_run?(params = {})
      @call_id ||= 0
      @need_run ||= @my_world.ended_task.include?(:initial_complete)
      @need_run && (@call_id += 1) % 150 == 0
    end

    private

    def attack?
      enemies = enemy_groups
      my_position = my_vehicles_position
#      ap my_position
#      ap enemies.map{|a| "#{a[0]} #{a[1].count}"}
      enemies_arr = enemies.
        sort{|e| Strategies::Point.distance_to_rect(e[0], my_position.x, my_position.y)}.
        first
      Strategies::Point.distance_to_rect(enemies_arr[0], my_position.x, my_position.y) < 50
    end

    def enemies_by_distance
      enemies = enemy_groups
      my_position = my_vehicles_position
      enemies_arr = enemies.
        sort{|e| Strategies::Point.distance_to_rect(e[0], my_position.x, my_position.y)}
    end

    def my_vehicles_position
      @squads[Strategies::SquadType::OLOLO_TROLOLO].vehicles.position
    end

    def enemy_groups
      point_class = Strategies::Point
      enemies = @my_world.vehicle_map.enemy_vehicle.vehicles
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
