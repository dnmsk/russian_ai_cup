module Strategies
  class FuckThemAll
    def initialize
      @cache = []
      @my_world = nil
    end

    def call me, world, game, move
      return @my_world if @my_world

      if world.tick_index > 190
        @my_world = MyWorld.new(me, @cache[0])
        @cache.each do |w|
          @my_world.reinitialize(me, w, game, move)
        end
        @cache = nil
        return @my_world
      end
      @cache.push(world)
      return nil
    end
  end
end
