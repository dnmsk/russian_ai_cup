require './model/action_type'
require './action_state_type'
require './action_wrapper'
require './point'

module Strategies::Actions
  class Base
    def initialize my_world, name, actions, params, need_delay = true
      @my_world, @name, @actions, @params = my_world, name, actions, params
      if need_delay && @actions.find{|a| [:scale, :move].include?(a[:name])}
        @actions.push({name: :empty, delayed: :vehicle_stops})
      end
    end

    def call
      prepared = @actions.map do |action|
        {
          name: action[:name],
          get_move: ->(){
            @last_execution = @my_world.world.tick_index
            @last_selection = @my_world.world.tick_index if action[:name] == :select
            move = apply_move(@my_world, action)
          },
          can_move: ->(){
            can = true
            return can if action[:delayed].nil?
            case action[:delayed]
            when :vehicle_stops
              can = (@last_selection + 1 == @my_world.world.tick_index) || !was_vehicle_move?
            when :ticks
              can = (@my_world.world.tick_index - @last_execution) > (action[:sleep] || 50) 
            end
            can
          }
        }
      end
      @my_world.move_processor.add_move({ name: @name, moves: prepared })
    end

    def need_run?(my_world, pars = {})
      if @params[:after] && (@params[:after] - @my_world.ended_task).any?
        return false
      end
      true
    end

    def vehicles
      @vehicles
    end

    private

    def apply_move my_world, current
      case current[:name]
      when :select
        return select_vehicle(@my_world, current[:act])
      when :move
        return move_vehicle(@my_world, current)
      when :group
        return {
          action: ActionType::ASSIGN,
          group: current[:act].()
        }
      when :scale
        vc = @vehicles
        pars = current[:act].(vc)
        vc = pars[:point] || vc.position
        if vc
          return {
            action: ActionType::SCALE,
            factor: pars[:factor],
            x: vc.x,
            y: vc.y
          }
        end
      when :rotate
        vc = @vehicles.position
        if vc
          return {
            action: ActionType::ROTATE,
            angle: current[:act].(),
            x: vc.x,
            y: vc.y
          }
        end
      when :empty
        current[:act] && current[:act].()
        return {}
      end
      #1/0
    end

    def was_vehicle_move?
      @my_world.vehicle_map.was_vehicle_move?(@vehicles)
    end

    def move_vehicle(my_world, action)
      current_vehicle_center = @vehicles.position
      return unless current_vehicle_center
      target = action[:act].(current_vehicle_center)
      {
        action: ActionType::MOVE,
        x: target.x - current_vehicle_center.x,
        y: target.y - current_vehicle_center.y,
        angle: 0.0,
        factor: 0.0,
        max_speed: action[:speed] || 0.0,
        max_angular_speed: 0.0
      }
    end

    def select_vehicle(my_world, act)
      if type = @params[:vehicle_type]
        @vehicles = @my_world.vehicle_map.my_vehicle(type)
        add_data = { vehicle_type: @params[:vehicle_type] }
      elsif group = @params[:group]
        @vehicles = @my_world.vehicle_map.my_vehicle(nil, group)
        add_data = { group: @params[:group] }
      elsif id = @params[:vehicle_id]
        @vehicles = @my_world.vehicle_map.vehicle_by_id(id)
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
      {
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
      }.merge(add_data)
    end
  end
end
