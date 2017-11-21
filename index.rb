#require 'awesome_print'
require './base'
require './attack'
require './attack_nuclear_strike'
require './defence_nuclear_strike'
require './initial_defence'
require './action_state_type'
require './const'
require './initial'
require './move_type'
require './squad_builder'
require './squad_type'
require './my_world'

module Strategies
  class Index
    def call(me, world, game, move)
      @my_world ||= MyWorld.new(me, world)
      @my_world.reinitialize(me, world, game, move)

      return if me.remaining_action_cooldown_ticks > 0
      action = linked_action(@my_world) ||
        continious_action(@my_world) ||
        delayed_action(@my_world) ||
        initial_actions(@my_world)

      return if action.nil? 

      result = action.(@my_world)
      return if result.nil?

      if result[:state] != Strategies::ActionStateType::ENDED
        add_delayed_action(result)
      else
        @my_world.ended_task.push(result[:name])
      end
      #if move.action
      #  ap move
      #end
      if result[:next_action]
        next_action = Strategies::Actions::ActionWrapper.new(
          AVAILABLE_ACTIONS[result[:next_action]],
          result
        )
        next_action[:ticks] = 0
        add_delayed_action(next_action)
      end
    end

    private

    def linked_action(my_world)
      return if my_world.actions.empty?
      action = my_world.actions.first
      my_world.actions.delete(action)
#      ap action
      action
    end

    def continious_action(my_world)
      @continious_action ||= [
        Strategies::Actions::DefenceNuclearStrike.new,
        #Strategies::Actions::AttackNuclearStrike.new,
        #Strategies::Actions::InitialDefence.new(my_world, Strategies::SquadType::AIR),
        Strategies::Actions::InitialDefence.new(my_world, Strategies::SquadType::FIGHTER),
        Strategies::Actions::InitialDefence.new(my_world, Strategies::SquadType::HELICOPTER),
        #Strategies::Actions::InitialDefence.new(my_world, Strategies::SquadType::AIR),
        
      ]

      @continious_action.find { |v| v.need_run?(my_world) }
    end

    def init_continious_action my_world
      squads = Strategies::SquadBuilder.new.get(my_world)
      [
        #Strategies::Actions::AttackNuclearStrike,
        #Strategies::Actions::DefenceNuclearStrike,
        Strategies::Actions::Attack,
      ].each {|s| @continious_action.push(s.new(squads))}
    end

    def initial_actions(my_world)
      @initial_actions ||= Strategies::Initial.new(@my_world).get(
        ->() {init_continious_action(my_world) }
      )
      action = @initial_actions.first
      if action && action.need_run?(my_world)
        @initial_actions.delete_at(0)
        action
      end
    end

    def add_delayed_action action
      @delayed_actions << action
    end

    def delayed_action my_world
      @delayed_actions ||= []
      @delayed_actions.each { |v| v[:ticks] -= 1 }
      actions = @delayed_actions.select do |v|
        v[:ticks] <= 0 && v.need_run?(my_world)
      end

      return if actions.empty?
      action = actions.sort_by{ |v| v[:ticks] }.first
      @delayed_actions.delete action
      action
    end
  end
end
