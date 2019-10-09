# frozen_string_literal: true

require_relative "validation"

class CargoTrain < Train
  include Validation

  def initialize(number)
    super(number, :cargo)
  end

  validate :number, :presence
  validate :number, :format, TRAIN_NUM_FORMAT

  def attachable_wagon?(wagon)
    wagon.is_a?(CargoWagon)
  end
end
