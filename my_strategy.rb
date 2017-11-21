require './model/game'
require './model/move'
require './model/player'
require './model/world'
require './index'

class MyStrategy
  # @param [Player] me
  # @param [World] world
  # @param [Game] game
  # @param [Move] move
  def move(me, world, game, move)
    (@strategy ||= Strategies::Index.new).(me, world, game, move)
  end
end
