#require 'awesome_print'
require './base'
require './attack'
require './attack'
require './attack_nuclear_strike'
require './defence_nuclear_strike'
require './initial_defence'
require './fuck_them_all'
require './action_state_type'
require './const'
require './initial'
require './initial_v2'
require './squad_builder'
require './squad_type'
require './my_world'

module Strategies
  class Index
    def call(me, world, game, move)
      #return
      #@time ||= 0
      #start = Time.now
      
      #@fuck_them_all ||= Strategies::FuckThemAll.new
      #my_world = @fuck_them_all.(me, world, game, move)
      #return if my_world.nil?
      #@my_world ||= my_world
      @my_world ||= MyWorld.new(me, world)
      @my_world.reinitialize(me, world, game, move)

      if me.remaining_action_cooldown_ticks == 0
        action = continious_action ||
          initial_actions
        action.() if action

        was_move = @my_world.move_processor.(move)
#        if was_move && move.action
#          ap world.tick_index
#          ap move
#        end
      end
      #ellapsed = Time.now - start
      #@time += ellapsed
      #profile("#{world.tick_index} #{ellapsed} #{@time}")
    end

    private

    def continious_action
      @continious_action ||= [
        Strategies::Actions::DefenceNuclearStrike.new(@my_world),

        #Strategies::Actions::AttackNuclearStrike.new(my_world),
        #Strategies::Actions::InitialDefence.new(my_world, Strategies::SquadType::AIR),
        #Strategies::Actions::InitialDefence.new(@my_world, Strategies::SquadType::FIGHTER),
        #Strategies::Actions::InitialDefence.new(@my_world, Strategies::SquadType::HELICOPTER),
        #Strategies::Actions::InitialDefence.new(my_world, Strategies::SquadType::AIR),
      ]

      @continious_action.find { |v| v.need_run?(@my_world) }
    end

    def init_continious_action
      squads = Strategies::SquadBuilder.new.get(@my_world)
      [
        Strategies::Actions::Attack,
      ].each {|s| @continious_action.push(s.new(@my_world, squads))}

      squads.each do |(k, squad)|
        @continious_action.push(
          Strategies::AttackNuclearStrike.new(@my_world, squad))
      end
    end

    def initial_actions
      @initial_actions ||= Strategies::InitialV2.new(@my_world).get(
        ->() { init_continious_action },
        ->() {
            @continious_action.push(
              Strategies::Actions::InitialDefence.new(@my_world, Strategies::SquadType::AIR))
          },
      )
      action = @initial_actions.find { |act| act.need_run?(@my_world)}
      if action
        @initial_actions.delete(action)
        action
      end
    end

    def profile msg = ''
      #STDOUT.puts "#{Time.now} #{msg}"
      #puts "#{Time.now} #{msg}"
    end
  end
end
