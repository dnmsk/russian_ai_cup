module Strategies
  class AttackBase
    private

    def enemies_by_distance my_position
      enemies = enemy_groups
      enemies_arr = enemies.sort_by do |e|
        dist = Strategies::Point.distance_to_rect(e[0], my_position.x, my_position.y)
        e[1].count > 20 ? dist : 999
      end
    end

    def enemy_groups
      point_class = Strategies::Point
      enemies = @my_world.vehicle_map.enemy_vehicle.vehicles
      groups = []
      enemies.sort_by{|v|v[:x]}.sort_by{|v|v[:y]}.each do |v|
        found = false
        groups.each do |g|
          rectangle = g[:rectangle]
          if point_class.distance_to_rect(rectangle, v[:x], v[:y]) < 25
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
      loop do
        group_joined = false
        groups.each do |group|
          near_group = groups.find do |g|
            group[:rectangle] != g[:rectangle] &&
              point_class.is_intersected?(g[:rectangle], group[:rectangle])
          end
          if near_group
            groups.delete(near_group)
            near_rect = near_group[:rectangle]
            group[:rectangle] = point_class.expand_rect(
              point_class.expand_rect(group[:rectangle], near_rect[0].x, near_rect[0].y),
              near_rect[1].x, near_rect[1].y
            )
            group_vehicles = group[:vehicles]
            near_group[:vehicles].each{|v| group_vehicles.push(v) }
            group_joined = true

            break
          end
        end
        break unless group_joined
      end

      groups.map{|g| [g[:rectangle], g[:vehicles]]}
    end
  end
end
