require './attack_base'

module Strategies
  class AttackNuclearStrike < Strategies::AttackBase
    TYPES_TO_FIELD_MAP = {
      VehicleType::ARRV =>:arrv_vision_range,
      VehicleType::FIGHTER =>:fighter_vision_range,
      VehicleType::HELICOPTER =>:helicopter_vision_range,
      VehicleType::IFV =>:ifv_vision_range,
      VehicleType::TANK =>:tank_vision_range,
    }

    def initialize my_world, squad
      @my_world, @squad = my_world, squad
    end

    def call params = {}
      my_vehicles = Strategies::Vehicle.new(
        @squad.vehicles.vehicles.select{ |v| v[:type] == best_type_in_squad })
      enemy_group = best_enemy_group_for_squad my_vehicles

      if enemy_group.nil?
        return
      end

      targeting = unit_and_point my_vehicles, enemy_group 
      actions = [
        { name: :nuclear, act: -> {
          {
            x: targeting[1].x,
            y: targeting[1].y,
            vehicle_id: targeting[0][:id]
          }
        }}
      ]
#ap targeting
      Strategies::Actions::Base.new(
        @my_world, :DefenceNuclearStrike, actions,
        { vehicle_id: targeting[0][:id], blocking_action: true }
      ).call()
    end

    def need_run? params = {}
      @call_id ||= 0
      (@call_id += 1) % 20 == 0 &&
        @my_world.world.my_player.remaining_nuclear_strike_cooldown_ticks <= 0 &&
        @my_world.world.my_player.next_nuclear_strike_tick_index <= 0
    end

    private

    def unit_and_point my_vehicles, enemy_group
      enemy_position = Strategies::Vehicle.new(enemy_group[1]).position
      my_vehicles = my_vehicles.vehicles.sort_by do |v|
        enemy_position.distance_to(v[:x], v[:y]) * @my_world.k_for_weather(v[:x], v[:y], :view)
      end
      [my_vehicles.first, enemy_position]
    end

    def best_enemy_group_for_squad vehicles
      my_position = vehicles.position

      enemy = enemies_by_distance(my_position).select{|e| e[1].count > 25}.first
      if Strategies::Point.distance_to_rect(enemy[0], my_position.x, my_position.y) >
        @my_world.game.tactical_nuclear_strike_radius / 2
        return nil
      end
      enemy
    end

    def best_type_in_squad
      TYPES_TO_FIELD_MAP.keys.find do |t|
        @squad.vehicles.vehicles.any?{ |v| v[:type] == t }
      end
    end

    def view_range
      @view_range ||= @my_world.game.
        send(TYPES_TO_FIELD_MAP[@squad.vehicles.vehicles.first[:type]])-1
    end
  end
end
