module Strategies
  class MoveProcessor
    def initialize my_world
      @my_world = my_world
      @moves = []
      @blocking_moves = []
      @delayed_moves = []
      #@moves = [{ name: 'Any_move', moves:
        #[{ get_move: ->(){}, can_run: ->(){} }]
      #@delayed_moves = [ {position: X, delayed_moves: [{ can_run: ->(){true/false}},}], ]
      #@continious = []
    end

    def add_blocking_move moves
      @blocking_moves.push(moves)
    end

    def add_move moves
      @moves.push(moves)
    end

    def call(move)
      run_blocking(move) || run_delayed(move) || run_current(move)
    end

    private

    def run_blocking(move)
      if !@current_blocking_move
        if (@blocking_moves.empty?)
          return false
        end
        @current_blocking_move = @blocking_moves.first
        @blocking_move_position = 0
      end
      
      current_action = @current_blocking_move[:moves][@blocking_move_position]
 
      if current_action[:can_move] && !current_action[:can_move].()
        return true
      end
      
      apply_to_move(move, current_action[:get_move].(), @current_blocking_move)
      @blocking_move_position+=1
      if (@current_blocking_move[:moves].count <= @blocking_move_position)
        @blocking_moves.delete(@current_blocking_move)
        @my_world.ended_task.push(@current_blocking_move[:name])
        @current_blocking_move = nil
      end
      return true
    end

    def run_delayed(move)
      delayed_move = @delayed_moves.find do |d|
        d[:delayed_moves][:moves][d[:position]][:can_move].()
      end
      return false if delayed_move.nil?
      delayed_actions = delayed_move[:delayed_moves][:moves]
      action = delayed_actions[delayed_move[:position]]
      if delayed_move[:delayed_moves][:last_selection] != @last_selection
        action_select = delayed_actions.find{ |a| a[:name] == :select }
        apply_to_move(move, action_select[:get_move].(), delayed_move[:delayed_moves])
        return true
      end

      delayed_move[:position] += 1
      if delayed_actions[delayed_move[:position]].nil?
        @delayed_moves.delete(delayed_move)
        @my_world.ended_task.push(delayed_move[:delayed_moves][:name])
      end
      apply_to_move(move, action[:get_move].(), delayed_move[:delayed_moves])
      return true
    end

    def run_current(move)
      if !@current_move
        if (@moves.empty?)
          return false
        end
        @current_move = @moves.first
        @move_position = 0
      end
      
      current_action = @current_move[:moves][@move_position]
 
      if current_action[:can_move] && !current_action[:can_move].() ||
        @current_move[:last_selection] != @last_selection &&
          current_action[:name] != :select && @move_position > 0
        @delayed_moves.push({ position: @move_position, delayed_moves: @current_move })
        @moves.delete(@current_move)
        @current_move = nil
        return call(move)
      end
      
      apply_to_move(move, current_action[:get_move].(), @current_move)
      @move_position+=1
      if (@current_move[:moves].count <= @move_position)
        @moves.delete(@current_move)
        @my_world.ended_task.push(@current_move[:name])
        @current_move = nil
      end
      return true
    end

    def apply_to_move move, data, action
      return false if data.nil?
      data.each { |k, v| move.send("#{k}=".to_s, v) }
#ap "apply_to_move #{action[:name]}"
      if move.action == ActionType::CLEAR_AND_SELECT
        @last_selection = action[:last_selection] = {
          group: move.group,
          left: move.left,
          top: move.top,
          right: move.right,
          bottom: move.bottom,
          vehicle_type: move.vehicle_type,
          facility_id: move.facility_id,
          vehicle_id: move.vehicle_id
        }
      end
      true
    end

#      {
#        action: nil,
#        group: 0,
#        left: 0.0,
#        top: 0.0,
#        right: 0.0,
#        bottom: 0.0,
#        x: 0.0,
#        y: 0.0,
#        angle: 0.0,
#        factor: 0.0,
#        max_speed: 0.0,
#        max_angular_speed: 0.0,
#        vehicle_type: nil,
#        facility_id: -1,
#        vehicle_id: -1
#      }

  end
end
