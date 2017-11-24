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

    def self.is_intersected? r1, r2
      [distance_to_rect(r2, r1[0].x, r1[0].y) == 0,
        distance_to_rect(r2, r1[1].x, r1[0].y) == 0,
        distance_to_rect(r2, r1[1].x, r1[1].y) == 0,
        distance_to_rect(r2, r1[0].x, r1[1].y) == 0
      ].select {|v| v}.count > 1 
    end

    def self.to_point_with_limit my_position, point, limit
      return point unless limit
      my_distance = my_position.distance_to(point.x, point.y)
      distance_limit = my_distance > limit ? limit : my_distance 
      k = distance_limit/my_distance
      p = Strategies::Point.new(
        my_position.x + k * (point.x - my_position.x),
        my_position.y + k * (point.y - my_position.y))
    end

    def self.nearest_point_from_rect rectangle, point
      lu, dr = rectangle[0], rectangle[1]
      x, y = point.x, point.y
      if lu.x<=x && dr.x>=x && lu.y<=y && dr.y>=y
        return point
      end
      if lu.x>=x
        if dr.y<y
          return self.new(lu.x, dr.y)
        elsif lu.y>y
          return self.new(lu.x, lu.y)
        else
          return self.new(lu.x, (lu.y+dr.y)/2)
        end
      end
      if dr.x<=x
        if dr.y<y
          return self.new(dr.x, dr.y)
        elsif lu.y>y
          return self.new(dr.x, lu.y)
        else
          return self.new(dr.x, (lu.y+dr.y)/2)
        end
      end
      if dr.y<=y
        return self.new((dr.x+lu.x)/2, dr.y)
      else
        return self.new((dr.x+lu.x)/2, lu.y)
      end
    end

    def self.distance_to_rect rectangle, x, y
      self.nearest_point_from_rect(rectangle, self.new(x, y)).distance_to(x, y)
    end

    def self.rectange_square rect
      (rect[1].x - rect[0].x) * (rect[1].y - rect[0].y)
    end

    def self.distance_to_point p1, p2
      self.distance_to_p p1.x, p1.y, p1.x, p2.y
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
      rect
    end
  end
end
