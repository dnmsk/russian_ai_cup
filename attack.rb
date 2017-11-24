require './attack_base'

module Strategies::Actions
  class Attack < Strategies::AttackBase
    def initialize my_world, squads
      @my_world, @squads = my_world, squads
    end

    def call(params = {})
      my_position = @squads[Strategies::SquadType::OLOLO_TROLOLO].vehicles.position
      enemies = enemies_by_distance my_position
      enemy = Strategies::Vehicle.new(enemies.first[1])
      enemy_position = enemy.position

      if enemy.durability_changed?
        return nil
        #@squads[Strategies::SquadType::FIGHTERS].attack_vehicles(enemy)
      else
        @squads[Strategies::SquadType::OLOLO_TROLOLO].move_to_point(enemy_position)
      end
    end

    def need_run?(params = {})
      @call_id ||= 0
      @need_run ||= @my_world.ended_task.include?(:initial_complete)
      @need_run && (@call_id += 1) % 150 == 0
    end

    private

    def my_vehicles_position
      @squads[Strategies::SquadType::OLOLO_TROLOLO].vehicles.position
    end
  end
end
