require './model/terrain_type'
require './model/vehicle_type'
require './model/weather_type'
#module Strategies
#  class Const
#    VAHICLE_FEATURES = {
#      VehicleType::ARRV => build_features(      0.4, 60,   0,  0,   0,   0, 50, 20),
#      VehicleType::FIGHTER => build_features(   1.2, 120,  0, 20,   0, 100, 70, 70),
#      VehicleType::HELICOPTER => build_features(0.9, 100, 20, 18, 100,  80, 40, 40),
#      VehicleType::IFV => build_features(       0.4, 80,  18, 20,  90,  80, 60, 80),
#      VehicleType::TANK => build_features(      0.3, 80,  20, 18, 100,  60, 80, 60)
#    }.freeze
#    WEATHER_FACTOR = {
#      WeatherType::CLEAR => build_factor(1, 1, 1), 
#      WeatherType::CLOUD => build_factor(0.8, 0.8, 0.8), 
#      WeatherType::RAIN => build_factor(0.6, 0.6, 0.6), 
#    }.freeze
#    TERRAIN_FACTOR = {
#      TerrainType::PLAIN => build_factor(1, 1, 1),
#      TerrainType::SWAMP => build_factor(0.6, 1, 1),
#      TerrainType::FOREST => build_factor(0.8, 0.8, 0.6),
#    }.freeze
#
#    ARRV_REPAIR_DISTANCE = 10
#    TERRAIN_SIZE = 32
#    TERRAIN_FULL_SIZE = 1024
#    NUCLEAR_STRIKE_DISTANCE = 50
#  private
#
#  def build_features(speed, view_range, attack_range_ground, attack_range_air,
#    damage_for_ground, damage_for_air, defence_ground, defence_air)
#    {
#      speed: speed,
#      view_range: view_range,
#      attack_range_air: attack_range_air,
#      attack_range_ground: attack_range_ground,
#      damage_for_air: damage_for_air,
#      damage_for_ground: damage_for_ground,
#      defence_air: defence_air,
#      defence_ground: defence_ground
#    }
#  end
#
#  def build_factor(speed, view, stealth)
#    {
#      speed: speed,
#      view: view,
#      stealth: stealth
#    }
#  end
#end
