# frozen_string_literal: true

require_relative "manufacturer"

class Wagon
  include Manufacturer

  attr_accessor :capacity, :taken_volume
  attr_reader :number, :type

  WAGON_CAPACITY_ERROR = "Не задан объем вагона!"
  WAGON_NUMBER_ERROR = "Номер вагона введен в неверном формате (99-С)."
  WAGON_NUM_FORMAT = /^[0-9]{2}-?[a-zа-я]{1}$/i

  def initialize(number, capacity, type)
    @type = type
    @capacity = capacity
    @number = number
    validate!
    @taken_volume = 0
  end

  def take_volume(volume)
    @taken_volume += volume
  end

  def free_volume
    @capacity - @taken_volume
  end

  def has_free_volume?
    free_volume.positive?
  end

  protected

  def validate!
    raise WAGON_NUMBER_ERROR if number !~ WAGON_NUM_FORMAT
    raise WAGON_CAPACITY_ERROR if capacity <= 0
  end
end
