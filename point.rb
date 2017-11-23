module Strategies
  class Point
    def initialize x, y
      @x, @y = x, y
    end

    def x
      @x
    end

    def y
      @y
    end

    def x= value
      @x = value
    end

    def y= value
      @y = value
    end

    def distance_to x, y
      Math.sqrt((@x-x)**2 + (@y-y)**2)
    end

    def in_reactangle? rectangle
      self.class.distance_to_rect(rectangle, @x, @y) == 0
    end

    def self.distance_to_rect rectangle, x, y
      lu, dr = rectangle[0], rectangle[1]
      if lu.x>=x && dr.x>=x && lu.y>=y && dr.y>=y
        return 0
      end
      if lu.x>=x
        if dr.y<y
          return self.distance_to_p(lu.x, dr.y, x, y)
        elsif lu.y>y
          return self.distance_to_p(lu.x, lu.y, x, y)
        else
          return self.distance_to_p(lu.x, (lu.y+dr.y)/2, x, y)
        end
      end
      if dr.x<=x
        if dr.y<y
          return self.distance_to_p(dr.x, dr.y, x, y)
        elsif lu.y>y
          return self.distance_to_p(dr.x, lu.y, x, y)
        else
          return self.distance_to_p(dr.x, (lu.y+dr.y)/2, x, y)
        end
      end
      if dr.y<=y
        return self.distance_to_p((dr.x+lu.x)/2, dr.y, x, y)
      else
        return self.distance_to_p((dr.x+lu.x)/2, lu.y, x, y)
      end
    end

    def self.distance_to_p x1, y1, x2, y2
      Math.sqrt((x1-x2)**2 + (y1-y2)**2)
    end

    def self.expand_rect rect, x, y
      p1 = rect[0]
      p2 = rect[1]
      p1.x = x if p1.x > x
      p1.y = y if p1.y > y
      p2.x = x if p2.x < x
      p2.y = y if p2.y < y
    end
  end
end
