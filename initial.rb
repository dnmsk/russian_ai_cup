require './base'
require './point'

module Strategies
  class Initial
    def initialize my_world
      @my_world = my_world
    end

    def get on_complete
      ground_vehicles = {
        VehicleType::ARRV => @my_world.vehicle_map.my_vehicle(VehicleType::ARRV),
        VehicleType::TANK => @my_world.vehicle_map.my_vehicle(VehicleType::TANK),
        VehicleType::IFV => @my_world.vehicle_map.my_vehicle(VehicleType::IFV),
      }
      air_vehicles = {
        VehicleType::FIGHTER => @my_world.vehicle_map.my_vehicle(VehicleType::FIGHTER),
        VehicleType::HELICOPTER => @my_world.vehicle_map.my_vehicle(VehicleType::HELICOPTER),
      }
      rectangle = ground_vehicles.first[1].rectangle
      rectangle = [Strategies::Point.new(0, 0), Strategies::Point.new(
        rectangle[1].x - rectangle[0].x + 6, rectangle[1].y - rectangle[0].y + 6)]

      scale = 2.5
      meeteing_poing = Strategies::Point.new(
        (scale + 1.1) * rectangle[1].x, (scale + 1.1) * rectangle[1].y)
      ground_vehicles = ground_vehicles.map{|(k, v)| [k, v.position]}
#ap ground_vehicles.map{|(k, v)| [k, v.position]}
      avg_ground_point = Strategies::Point.new(
        sum(ground_vehicles.map{|v| v[1].x}) / ground_vehicles.count,
        sum(ground_vehicles.map{|v| v[1].y}) / ground_vehicles.count)
      avg_air_point_x = sum(air_vehicles.map{|v| v[1].position.x}) / air_vehicles.count

      ground_vehicles = ground_vehicles.sort_by{|v| v[1].y }.
        sort_by{|v| v[1].x > avg_ground_point.x ? 0 : 1}
#ap ground_vehicles
      ground_vehicles = [
        [ground_vehicles[0][0], Strategies::Point.new(meeteing_poing.x, meeteing_poing.y - rectangle[1].y), ground_vehicles[0][1].x > avg_ground_point.x && ground_vehicles[0][1].y < avg_ground_point.y],
        [ground_vehicles[1][0], Strategies::Point.new(meeteing_poing.x, meeteing_poing.y), ground_vehicles[1][1].x > avg_ground_point.x && ground_vehicles[1][1].y < avg_ground_point.y],
        [ground_vehicles[2][0], Strategies::Point.new(meeteing_poing.x, meeteing_poing.y + rectangle[1].y), ground_vehicles[2][1].x > avg_ground_point.x && ground_vehicles[2][1].y < avg_ground_point.y],
      ]
#ap ground_vehicles
      fighter_meet_point = Strategies::Point.new(6*rectangle[1].x, 5*rectangle[1].y)
      helicopter_meet_point = Strategies::Point.new(4.5*rectangle[1].x, 5*rectangle[1].y)

      ground_vehicles.map do |v|
        Strategies::Actions::Base.new("init_#{v[0]}".to_sym, [
          { name: :select, act: ->(rectangle) { rectangle }},
          { name: :move, act: ->(point) { move_down_or_right(point, v[1], v[2]) }, speed: 0.3 },
          { name: :group, act: -> { Strategies::SquadType::FIGHTERS }},
          { name: :group, act: -> { v[0]+1 }},
          { name: :move, act: ->(point) { move_down_or_right(point, v[1], !v[2]) }, delayed: :vehicle_stops },
        ], vehicle_type: v[0])
      end + 
      [
        Strategies::Actions::Base.new(:init_1, [
          { name: :select, act: ->(rectangle) { rectangle }},
          { name: :move, act: ->(point) { move_down_or_right(point, fighter_meet_point, point.x > avg_air_point_x) }},
          { name: :group, act: -> { Strategies::SquadType::AIR }},
          { name: :group, act: -> { VehicleType::FIGHTER+1 }},
          { name: :move, act: ->(point) { fighter_meet_point }, delayed: :vehicle_stops },
        ], vehicle_type: VehicleType::FIGHTER),
        Strategies::Actions::Base.new(:init_2, [
          { name: :select, act: ->(rectangle) { rectangle }},
          { name: :move, act: ->(point) { move_down_or_right(point, helicopter_meet_point, point.x > avg_air_point_x) }},
          { name: :group, act: -> { Strategies::SquadType::AIR }},
          { name: :group, act: -> { VehicleType::HELICOPTER+1 }},
          { name: :move, act: ->(point) { helicopter_meet_point }, delayed: :vehicle_stops },
        ], vehicle_type: VehicleType::HELICOPTER),
      ] +
      [
        Strategies::Actions::Base.new(:grouping_1, [
          { name: :select, act: ->(rectangle) { [rectangle[0], Strategies::Point.new((rectangle[0].x+rectangle[1].x)/2, rectangle[1].y)] }},
          { name: :group, act: -> { Strategies::SquadType::FIGHTERS_1 }},
        ], group: Strategies::SquadType::FIGHTERS, after: [:init_0, :init_3, :init_4]),
        Strategies::Actions::Base.new(:grouping_2, [
          { name: :select, act: ->(rectangle) { [Strategies::Point.new((rectangle[0].x+rectangle[1].x)/2, rectangle[0].y), rectangle[1]] }},
          { name: :group, act: -> { Strategies::SquadType::FIGHTERS_2 }},
        ], group: Strategies::SquadType::FIGHTERS, after: [:init_0, :init_3, :init_4]),

        Strategies::Actions::Base.new(:scaling, [
          { name: :select, act: ->(rectangle) { rectangle }},
          { name: :scale, act: ->(point) { {factor: scale} }, delayed: :vehicle_stops},
        ], group: Strategies::SquadType::FIGHTERS, after: [:grouping_1, :grouping_2]),

        Strategies::Actions::Base.new(:moving_1, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :move, act: ->(point) { Strategies::Point.new(point.x-5, point.y) }},
        ], group: VehicleType::ARRV + 1, after: [:scaling]),
        Strategies::Actions::Base.new(:moving_2, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :move, act: ->(point) { Strategies::Point.new(point.x+5, point.y) }},
        ], group: VehicleType::TANK + 1, after: [:scaling]),

        Strategies::Actions::Base.new(:compacting_1, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :move, act: ->(point) { Strategies::Point.new(point.x, point.y + scale * rectangle[1].y) }},
        ], group: ground_vehicles[0][0] + 1, after: [:moving_1]),
        Strategies::Actions::Base.new(:compacting_2, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :move, act: ->(point) { Strategies::Point.new(point.x, point.y - scale * rectangle[1].y) }},
        ], group: ground_vehicles[2][0] + 1, after: [:moving_2]),

        Strategies::Actions::Base.new(:compacting_move_1, [
          { name: :select, act: ->(rectangle) { [rectangle[0], Strategies::Point.new(rectangle[1].x, (rectangle[0].y+rectangle[1].y)/2)] }},
          { name: :move, act: ->(point) { Strategies::Point.new(point.x, point.y + scale * rectangle[1].y) }},
        ], group: Strategies::SquadType::FIGHTERS, after: [:compacting_1, :compacting_2]),
        Strategies::Actions::Base.new(:compacting_move_2, [
          { name: :select, act: ->(rectangle) { [Strategies::Point.new(rectangle[0].x, (rectangle[0].y+rectangle[1].y)/2), rectangle[1]] }},
          { name: :move, act: ->(point) { Strategies::Point.new(point.x, point.y - scale * rectangle[1].y) }},
        ], group: Strategies::SquadType::FIGHTERS, after: [:compacting_1, :compacting_2]),

        #Strategies::Actions::Base.new(:move_before_rotate, [
        #  { name: :select, act: ->(rectangle) { nil }},
        #  { name: :move, act: ->(point) { Strategies::Point.new(point.x - 50, point.y) }},
        #], group: Strategies::SquadType::FIGHTERS_1, after: [:compacting_move_1, :compacting_move_2]),

        Strategies::Actions::Base.new(:rotate, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :rotate, act: ->() { -Math::PI/4 }, delayed: :vehicle_stops},
          { name: :scale, act: ->(point) { {factor: 0.1} }, delayed: :vehicle_stops},
        ], group: Strategies::SquadType::FIGHTERS, after: [:compacting_1, :compacting_2]),

        #Strategies::Actions::Base.new(:rotate_1, [
        #  { name: :select, act: ->(rectangle) { nil }},
        #  { name: :rotate, act: ->() { Math::PI/2 }, delayed: :vehicle_stops},
        #  { name: :scale, act: ->(point) { {factor: 0.1} }, delayed: :vehicle_stops},
        #], group: Strategies::SquadType::FIGHTERS_1, after: [:rotate]),

        #Strategies::Actions::Base.new(:rotate_2, [
        #  { name: :select, act: ->(rectangle) { nil }},
        #  { name: :rotate, act: ->() { Math::PI/2 }, delayed: :vehicle_stops},
        #  { name: :scale, act: ->(point) { {factor: 0.1} }, delayed: :vehicle_stops},
        #], group: Strategies::SquadType::FIGHTERS_2, after: [:rotate]),

        Strategies::Actions::Base.new(:initial_complete, [
          { name: :delay, act: on_complete }
        ], group: Strategies::SquadType::FIGHTERS_1, after: [:rotate]),
      ]
    end

    private

    def move_down_or_right start_point, end_point, to_right_first = false
      if to_right_first
        return Strategies::Point.new(end_point.x, start_point.y)
      else
        return Strategies::Point.new(start_point.x, end_point.y)
      end
    end

    def sum(array)
      return 0 if array.empty?
      array.inject(0) { |sum, x| sum + x }
    end
  end
end
