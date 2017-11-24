require './point'

module Strategies
  class Vehicle
    def initialize vehicles
      @vehicles = vehicles
    end

    def rectangle
      return nil if vehicles.empty?
      point = Strategies::Point
      [
        point.new(vehicles.map{|v| v[:x]}.min, vehicles.map{|v| v[:y]}.min),
        point.new(vehicles.map{|v| v[:x]}.max, vehicles.map{|v| v[:y]}.max)
      ]
    end

    def position
      return nil if vehicles.empty?
      Strategies::Point.new(
        avg(vehicles.map { |v| v[:x] }),
        avg(vehicles.map { |v| v[:y] })
      )
    end

    def vehicles
      @vehicles.select{ |v| v[:durability] > 0 }
    end

    def health
      avg(live.map{ |v| v[:durability]})
    end

    def durability_changed?
      vehicles.any?{ |v| v[:durability_changed]}
    end

    private

    def avg(array)
      return nil if array.empty?
      sum(array) / array.count
    end

    def sum(array)
      return nil if array.empty?
      array.inject(0) { |sum, x| sum + x }
    end
  end
end
