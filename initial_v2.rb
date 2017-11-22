module Strategies
  class InitialV2
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
      scaled_rect = Strategies::Point.new(scale * rectangle[1].x, scale * rectangle[1].y)
      meeting_point_gn = Strategies::Point.new(
        (1.5 * scale * rectangle[1].x).to_i, (1.5 * scale * rectangle[1].y).to_i)

      meeting_point_air = Strategies::Point.new(
        (2 * scale * rectangle[1].x).to_i, (2 * scale * rectangle[1].y).to_i)

      gvp = ground_vehicles.map{|(k, v)| [k, v.position]}
      avp = air_vehicles.map{|(k, v)| [k, v.position]}

      avg_ground_point = Strategies::Point.new(
        sum(gvp.map{|v| v[1].x}) / gvp.count,
        sum(gvp.map{|v| v[1].y}) / gvp.count)

      gvp = gvp.sort_by{|v| v[1].distance_to(0, 0) }
      first_right_gn = gvp[0][1].x >= gvp[1][1].x && gvp[0][1].y <= gvp[1][1].y
      first_right_air = avp[0][1].x >= avp[1][1].x && avp[0][1].y <= avp[1][1].y
#      ap first_right_gn
      [
        Strategies::Actions::Base.new(@my_world, "init_#{gvp[2][0]}".to_sym, [
          { name: :select, act: ->(rectangle) { rectangle }},
          { name: :move, act: ->(point) { meeting_point_gn } },
          { name: :group, act: -> { Strategies::SquadType::FIGHTERS }, delayed: :vehicle_stops},
          { name: :group, act: -> { gvp[2][0]+1 }},
        ], vehicle_type: gvp[2][0]),
        Strategies::Actions::Base.new(@my_world, "init_#{gvp[0][0]}".to_sym, [
          { name: :select, act: ->(rectangle) { rectangle }},
          { name: :move, act: ->(point) { 
            first_right_gn ?
              Strategies::Point.new(point.x, rectangle[1].y-1) :
              Strategies::Point.new(rectangle[1].x-1, point.y) } },
          { name: :group, act: -> { gvp[0][0]+1 }, delayed: :vehicle_stops},
          { name: :move, act: ->(point) { 
            first_right_gn ?
              Strategies::Point.new(meeting_point_gn.x + 5, scaled_rect.y / 2) :
              Strategies::Point.new(scaled_rect.x / 2, meeting_point_gn.y + 5) } },
          { name: :group, act: -> { Strategies::SquadType::FIGHTERS }, delayed: :vehicle_stops},
        ], vehicle_type: gvp[0][0]),
        Strategies::Actions::Base.new(@my_world, "init_#{gvp[1][0]}".to_sym, [
          { name: :select, act: ->(rectangle) { rectangle }},
          { name: :move, act: ->(point) { 
            !first_right_gn ?
              Strategies::Point.new(point.x, rectangle[1].y-1) :
              Strategies::Point.new(rectangle[1].x-1, point.y) }},
          { name: :group, act: -> { gvp[1][0]+1 }, delayed: :vehicle_stops},
          { name: :move, act: ->(point) { 
            !first_right_gn ?
              Strategies::Point.new(meeting_point_gn.x + 5, scaled_rect.y / 2) :
              Strategies::Point.new(scaled_rect.x / 2, meeting_point_gn.y + 5) } },
          { name: :group, act: -> { Strategies::SquadType::FIGHTERS }, delayed: :vehicle_stops},
        ], vehicle_type: gvp[1][0]),

        Strategies::Actions::Base.new(@my_world, :scale_1, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :scale, act: ->(point) { {factor: scale} }},
        ], group: gvp[2][0]+1, after: ["init_#{gvp[2][0]}".to_sym]),
        Strategies::Actions::Base.new(@my_world, :scale_2, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :scale, act: ->(point) { {factor: scale} }},
        ], group: gvp[0][0]+1, after: ["init_#{gvp[0][0]}".to_sym]),
        Strategies::Actions::Base.new(@my_world, :scale_3, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :scale, act: ->(point) { {factor: scale} }},
        ], group: gvp[1][0]+1, after: ["init_#{gvp[1][0]}".to_sym]),

        Strategies::Actions::Base.new(@my_world, :moving_1, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :move, act: ->(point) {
            first_right_gn ?
              Strategies::Point.new(point.x, meeting_point_gn.y) :
              Strategies::Point.new(meeting_point_gn.x, point.y) }},
        ], group: gvp[0][0]+1, after: [:scale_1, :scale_2]),
        Strategies::Actions::Base.new(@my_world, :moving_2, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :move, act: ->(point) {
            first_right_gn ?
              Strategies::Point.new(meeting_point_gn.x - 5, point.y) :
              Strategies::Point.new(point.x, meeting_point_gn.y - 5)}},
          { name: :move, act: ->(point) {
            first_right_gn ?
              Strategies::Point.new(point.x, point.y - 5) :
              Strategies::Point.new(point.x - 5, point.y)}, delayed: :vehicle_stops},
        ], group: gvp[1][0]+1, after: [:scale_1, :scale_3, :moving_1]),

          Strategies::Actions::Base.new(@my_world, :compacting_move_1, [
            { name: :select, act: ->(rectangle) {
              first_right_gn ?
                [rectangle[0], Strategies::Point.new(rectangle[1].x, (rectangle[0].y+rectangle[1].y)/2)] :
                [rectangle[0], Strategies::Point.new((rectangle[0].x+rectangle[1].x)/2, rectangle[1].y)]}},
            { name: :move, act: ->(point) {
              first_right_gn ?
                Strategies::Point.new(point.x, point.y + scale * rectangle[1].y) :
                Strategies::Point.new(point.x + scale * rectangle[1].x, point.y) }}
          ], group: Strategies::SquadType::FIGHTERS, after: [:moving_2]),

          Strategies::Actions::Base.new(@my_world, :compacting_move_2, [
            { name: :select, act: ->(rectangle) {
              first_right_gn ?
                [Strategies::Point.new(rectangle[0].x, (rectangle[0].y+rectangle[1].y)/2), rectangle[1]] :
                [Strategies::Point.new((rectangle[0].x+rectangle[1].x)/2, rectangle[0].y), rectangle[1]]}},
            { name: :move, act: ->(point) {
              first_right_gn ?
                Strategies::Point.new(point.x, point.y - scale * rectangle[1].y) :
                Strategies::Point.new(point.x - scale * rectangle[1].x, point.y) }}
          ], group: Strategies::SquadType::FIGHTERS, after: [:moving_2]),

          Strategies::Actions::Base.new(@my_world, :rotate, [
            { name: :select, act: ->(rectangle) { nil }},
            { name: :rotate, act: ->() { first_right_gn ? -Math::PI/4 : Math::PI/4 }, delayed: :vehicle_stops},
            { name: :scale, act: ->(point) { {factor: 0.1} }, delayed: :vehicle_stops},
          ], group: Strategies::SquadType::FIGHTERS, after: [:compacting_move_1, :compacting_move_2]),

      ] +
      [
        Strategies::Actions::Base.new(@my_world, :init_air_1, [
          { name: :select, act: ->(rectangle) { rectangle }},
          { name: :move, act: ->(point) {
            first_right_air ?
              Strategies::Point.new(meeting_point_air.x - 5, point.y) :
              Strategies::Point.new(point.x, meeting_point_air.y - 5)}},
          { name: :group, act: -> { Strategies::SquadType::AIR }, delayed: :vehicle_stops},
          { name: :group, act: -> { VehicleType::FIGHTER+1 }},
          { name: :scale, act: ->(point) { {factor: 0.1} }},
          { name: :move, act: ->(point) {
            first_right_air ?
              Strategies::Point.new(point.x, meeting_point_air.y) :
              Strategies::Point.new(meeting_point_air.x, point.y) }, delayed: :vehicle_stops },
        ], vehicle_type: VehicleType::FIGHTER),
        Strategies::Actions::Base.new(@my_world, :init_air_2, [
          { name: :select, act: ->(rectangle) { rectangle }},
          { name: :move, act: ->(point) {
            !first_right_air ?
              Strategies::Point.new(meeting_point_air.x, point.y) :
              Strategies::Point.new(point.x, meeting_point_air.y)}},
          { name: :group, act: -> { Strategies::SquadType::AIR }, delayed: :vehicle_stops},
          { name: :group, act: -> { VehicleType::HELICOPTER+1 }},
          { name: :scale, act: ->(point) { {factor: 0.1} }},
          { name: :move, act: ->(point) { 
            !first_right_air ?
              Strategies::Point.new(point.x, meeting_point_air.y) :
              Strategies::Point.new(meeting_point_air.x, point.y)  }, delayed: :vehicle_stops },
        ], vehicle_type: VehicleType::HELICOPTER),

        Strategies::Actions::Base.new(@my_world, :scale_air, [
          { name: :select, act: ->(rectangle) { nil }},
          { name: :scale, act: ->(point) { {factor: 0.1} }, delayed: :vehicle_stops},
        ], group: Strategies::SquadType::AIR, after: [:init_air_1, :init_air_2]),

        Strategies::Actions::Base.new(@my_world, :initial_complete, [
          { name: :empty, act: on_complete }
        ], group: Strategies::SquadType::FIGHTERS, after: [:rotate])
      ]
    end

    private

    def sum(array)
      return 0 if array.empty?
      array.inject(0) { |sum, x| sum + x }
    end
  end
end
