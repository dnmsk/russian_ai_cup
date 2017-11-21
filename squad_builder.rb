require './squad'
require './squad_type'

module Strategies
  class SquadBuilder
    def get my_world
      memo = {}
      [
        [Strategies::SquadType::FIGHTERS, Math::PI/2, 0.3],
        [Strategies::SquadType::AIR, 0],
        #[Strategies::SquadType::FIGHTER, 0],
        #[Strategies::SquadType::HELICOPTER, 0]
      ].each{ |val| memo[val[0]] = Strategies::Squad.new(my_world, val[0], val[1], val[2]) }
      memo
    end
  end
end
