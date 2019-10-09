# frozen_string_literal: true

class PassengerWagon < Wagon
  def initialize(number, capacity)
    super(number, capacity, :passenger)
  end

  def take_volume
    super(1)
  end

  alias take_seat take_volume
end
