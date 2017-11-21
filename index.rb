#require 'awesome_print'
require './base'
require './attack'
require './attack_nuclear_strike'
require './defence_nuclear_strike'
require './initial_defence'
require './action_state_type'
require './const'
require './initial'
require './squad_builder'
require './squad_type'
require './my_world'

module Strategies
  class Index
    def call(me, world, game, move)
      @my_world ||= MyWorld.new(me, world)
      @my_world.reinitialize(me, world, game, move)

      return if me.remaining_action_cooldown_ticks > 0

      action = continious_action ||
        initial_actions
      action.() if action

      was_move = @my_world.move_processor.run_delayed(move) ||
        @my_world.move_processor.(move)
#      if was_move
#        ap world.tick_index
#        ap move 
#      end
    end

    private

    def continious_action
      @continious_action ||= [
        Strategies::Actions::DefenceNuclearStrike.new(@my_world),
        #Strategies::Actions::AttackNuclearStrike.new(my_world),
        #Strategies::Actions::InitialDefence.new(my_world, Strategies::SquadType::AIR),
        Strategies::Actions::InitialDefence.new(@my_world, Strategies::SquadType::FIGHTER),
        Strategies::Actions::InitialDefence.new(@my_world, Strategies::SquadType::HELICOPTER),
        #Strategies::Actions::InitialDefence.new(my_world, Strategies::SquadType::AIR),
      ]

      @continious_action.find { |v| v.need_run?(@my_world) }
    end

    def init_continious_action 
      squads = Strategies::SquadBuilder.new.get(@my_world)
      [
        #Strategies::Actions::AttackNuclearStrike,
        #Strategies::Actions::DefenceNuclearStrike,
        Strategies::Actions::Attack,
      ].each {|s| @continious_action.push(s.new(@my_world, squads))}
    end

    def initial_actions
      @initial_actions ||= Strategies::Initial.new(@my_world).get(
        ->() {
          init_continious_action }
      )
      action = @initial_actions.first
      if action && action.need_run?(@my_world)
        @initial_actions.delete_at(0)
        action
      end
    end
  end
end
