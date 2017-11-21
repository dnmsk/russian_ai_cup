require './model/action_type'
require './action_state_type'
require './action_wrapper'
require './point'

module Strategies::Actions
  class Base
    def initialize name, actions, params, need_delay = true
      @name, @actions, @params = name, actions, params
      if need_delay && @actions.find{|a| [:scale, :move].include?(a[:name])}
        @actions.push({name: :delay, delayed: :vehicle_stops})
      end
    end

    def call(my_world, params = {})
      @current_action ||= 0
      if @current_action > 0 && @my_selection != my_world.last_selection
        current = @actions.find { |v| v[:name] == :select }
        @current_action -= 1
      else
        current = @actions[@current_action]
      end
# ap "#{my_world.world.tick_index} #{@name} #{current[:name]} #{@current_action}"
      if current[:delayed] != nil && was_vehicle_move?(my_world)
        return Strategies::Actions::ActionWrapper.new(self, {
          state: Strategies::ActionStateType::DELAYED,
          ticks: current[:ticks] || 60,
          name: @name
        })
      end

      case current[:name]
      when :select
        select_vehicle(my_world, current[:act])
        @my_selection = my_world.last_selection
      when :move
        move_vehicle(my_world, current)
      when :group
        my_world.apply_to_move({}, {
          action: ActionType::ASSIGN,
          group: current[:act].()
        })
      when :scale
        vc = @vehicles.position
        pars = current[:act].(vc)
        vc = pars[:point] || vc
        if vc
          my_world.apply_to_move({}, {
            action: ActionType::SCALE,
            factor: pars[:factor],
            x: vc.x,
            y: vc.y
          })
        end
      when :rotate
        vc = @vehicles.position
        if vc
          my_world.apply_to_move({}, {
            action: ActionType::ROTATE,
            angle: current[:act].(),
            x: vc.x,
            y: vc.y
          })
        end
      when :wait
        if current[:act].()
          Strategies::Actions::ActionWrapper.new(self, {
            state: Strategies::ActionStateType::DELAYED,
            ticks: current[:ticks] || 60,
            name: @name
          })
        end
      when :delay
        current[:act] && current[:act].()
      end
      if @actions.count > (@current_action += 1)
        ticks = current[:name] == :select ? -my_world.world.tick_index : 0
        ticks = current[:ticks] || ticks
        return Strategies::Actions::ActionWrapper.new(self, {
          state: Strategies::ActionStateType::CONTINUE,
          ticks: ticks,
          name: @name
        })
      end
      #ap "ENDED #{@name}"
      Strategies::Actions::ActionWrapper.new(self, {
        state: Strategies::ActionStateType::ENDED,
        name: @name
      })
    end

    def need_run?(my_world, pars = {})
      if @current_action
        current = @actions[@current_action]
        if current[:delayed] == :vehicle_stops && was_vehicle_move?(my_world)
          return false
        end
      end
      if @params[:after] && (@params[:after] - my_world.ended_task).any?
        return false
      end
      true
    end

    def vehicles
      @vehicles
    end

    private

    def was_vehicle_move? my_world
      my_world.vehicle_map.was_vehicle_move?(@vehicles)
    end

    def move_vehicle(my_world, action)
      current_vehicle_center = @vehicles.position
      return unless current_vehicle_center
      target = action[:act].(current_vehicle_center)
      my_world.apply_to_move({}, {
        action: ActionType::MOVE,
        x: target.x - current_vehicle_center.x,
        y: target.y - current_vehicle_center.y,
        angle: 0.0,
        factor: 0.0,
        max_speed: action[:speed] || 0.0,
        max_angular_speed: 0.0
      })
    end

    def select_vehicle(my_world, act)
      if type = @params[:vehicle_type]
        @vehicles = my_world.vehicle_map.my_vehicle(type)
        add_data = { vehicle_type: @params[:vehicle_type] }
      elsif group = @params[:group]
        @vehicles = my_world.vehicle_map.my_vehicle(nil, group)
        add_data = { group: @params[:group] }
      elsif id = @params[:vehicle_id]
        @vehicles = my_world.vehicle_map.vehicle_by_id(id)
        add_data = { vehicle_id: @params[:vehicle_id] }
      end

      if act && rectangle = act.(@vehicles.rectangle)
        add_data = (@params[:group] ? {} : add_data).merge({
          left: rectangle[0].x - 2,
          top: rectangle[0].y - 2,
          right: rectangle[1].x + 2,
          bottom: rectangle[1].y + 2,
        })
      end
      my_world.apply_to_move(add_data, {
        action: ActionType::CLEAR_AND_SELECT,
        group: 0,
        left: 0.0,
        top: 0.0,
        right: 0.0,
        bottom: 0.0,
        max_speed: 0.0,
        vehicle_type: nil,
        facility_id: -1,
        vehicle_id: -1
      })
    end
  end
end
