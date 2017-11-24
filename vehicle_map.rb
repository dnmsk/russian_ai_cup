require './vehicle'

module Strategies
  class VehicleMap
    UPDATED_FIELDS = [:x, :y, :durability, :groups].freeze
    ALL_FIELDS = [:id, :remaining_attack_cooldown_ticks, :selected,
      :player_id, :type] + UPDATED_FIELDS

    def initialize me, my_world
      @me, @my_world = me, my_world
      @map = [{}]
      my_world.world.new_vehicles.each do |v|
        @map[v.id] = ALL_FIELDS.each_with_object(Hash.new) do |key, memo|
          memo[key] = v.send(key)
        end
      end
    end

    def read_updates
      @map.each { |v| v && v[:was_move] = false }
      @my_world.world.vehicle_updates.each do |v|
        vehicle = @map[v.id]
        vehicle[:was_move] = vehicle[:x] != v.x || vehicle[:y] != v.y
        #UPDATED_FIELDS.each { |f| vehicle[f] = v.send(f) }
        vehicle[:x] = v.x
        vehicle[:y] = v.y
        vehicle[:durability] = v.durability
        vehicle[:groups] = v.groups
      end
    end

    def all
      Strategies::Vehicle.new(all_vehicles)
    end

    def my_vehicle type = nil, group = nil
      Strategies::Vehicle.new(filter_by_type_group(
        all_vehicles.select { |v| v && v[:player_id] == @me.id },
        type, group)
      )
    end

    def enemy_vehicle
      return @enemy_vehicle if @my_world.world.tick_index == @tick_last_scan
      @tick_last_scan = @my_world.world.tick_index
      @enemy_vehicle = Strategies::Vehicle.new(filter_by_type_group(
        all_vehicles.select { |v| v && v[:player_id] && v[:player_id] != @me.id })
      )
    end

    def vehicle_by_id id
      Strategies::Vehicle.new(all_vehicles.find { |v| v && v[:id] != id })
    end

    def vehicle_by_ids ids
      Strategies::Vehicle.new(ids.map { |id| vehicle_by_id(id) })
    end

    def my_selected_vehicles
      Strategies::Vehicle.new(all_vehicles.select{ |v| v && v[:selected]})
    end

    def was_vehicle_move? vehicles
      vehicles.vehicles.select{ |v| v[:was_move] }.any?
    end

    private

    def all_vehicles
      @map.select{|v| v && v[:durability] && v[:durability] > 0}
    end

    def filter_by_type_group vs, type = nil, group = nil
      vs = vs.select{ |v| v[:type] == type } if type
      vs = vs.select{ |v| v[:groups].include? group } if group
      vs
    end
  end
end
