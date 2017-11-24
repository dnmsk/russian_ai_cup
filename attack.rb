require './attack_base'

module Strategies::Actions
  class Attack < Strategies::AttackBase
    def initialize my_world, squads
      @my_world, @squads = my_world, squads
    end

    def call(params = {})
      my_position = @squads[Strategies::SquadType::OLOLO_TROLOLO].vehicles.position
      enemies = enemies_by_distance my_position
      enemy = enemies.first[1]
      enemy_position = Strategies::Vehicle.new(enemy).position

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
      my_position = @squads[Strategies::SquadType::OLOLO_TROLOLO].vehicles.position
      enemies_arr = enemies_by_distance(my_vehicles_position).first
      Strategies::Point.distance_to_rect(enemies_arr[0], my_position.x, my_position.y) < 50
    end

    def my_vehicles_position
      @squads[Strategies::SquadType::OLOLO_TROLOLO].vehicles.position
    end
  end
end
