# frozen_string_literal: true

require_relative "instance_counter"
require_relative "validation"

class Station
  EMPTY_NAME_ERROR = "Станции не присвоено имя"
  INVALID_NAME_ERROR = "Слишком короткое имя станции. Должно быть не менее 3 символов"
  STATION_NAME_FORMAT = /^.{3,}$/i

  include InstanceCounter
  include Validation

  attr_reader :name, :trains
  validate :name, :presence
  validate :name, :format, STATION_NAME_FORMAT

  @@stations = []

  def self.all
    @@stations
  end

  def initialize(name)
    @name = name
    validate!
    @trains = []
    @@stations.push(self)
    register_instance
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  def each_train
    @trains.each { |train| yield(train) } if block_given?
  end

  def add_train(train)
    @trains << train
  end

  def remove_train(train)
    @trains.delete(train)
  end

  def trains_by_type(type)
    trains.select { |train| train.type == type }.length
  end

  # protected

  # def validate!
  #   raise EMPTY_NAME_ERROR if name.empty?
  #   raise INVALID_NAME_ERROR if name.length < 3
  # end
end
