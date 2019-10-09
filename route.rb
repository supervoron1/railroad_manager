# frozen_string_literal: true

require_relative "instance_counter"

class Route
  FIRST_STATION_MISSING_ERROR = "Не задана начальная станция! Попробуйте еще раз."
  LAST_STATION_MISSING_ERROR = "Не задана конечная станция! Попробуйте еще раз."
  INVALID_STATIONS_INROUTE = "Начальная и конечная станции не должны быть одинаковыми."

  include InstanceCounter
  attr_reader :first_station, :last_station

  def initialize(first_station, last_station)
    @first_station = first_station
    @last_station = last_station
    validate!
    @stations = []
    register_instance
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  def add_station(station)
    return if [@first_station, @last_station].include?(station)
    @stations.push(station)
  end

  def remove_station(station)
    return if [@first_station, @last_station].include?(station)
    @stations.delete(station)
  end

  def stations
    [@first_station, *@stations, @last_station]
  end

  protected

  def validate!
    raise FIRST_STATION_MISSING_ERROR if first_station.nil?
    raise LAST_STATION_MISSING_ERROR if last_station.nil?
    raise INVALID_STATIONS_INROUTE if first_station == last_station
  end
end
