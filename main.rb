# frozen_string_literal: true

require_relative "train"
require_relative "passenger_train"
require_relative "cargo_train"
require_relative "wagon"
require_relative "passenger_wagon"
require_relative "cargo_wagon"
require_relative "station"
require_relative "route"

class Main
  INDEX_ERROR = "Вы ввели недопустимое значение. Попробуйте еще раз."
  NOT_DEFINED_ERROR = "Пока не созданы."
  TRAIN_TYPE_MENU = %w[Пассажирский Грузовой].freeze
  TRAIN_MOVE_MENU = %w[Вперед Назад].freeze
  MENU_ITEMS = %w[
    Создавать\ станции
    Создавать\ поезда
    Создавать\ вагоны
    Создавать\ маршруты
    Управлять\ станциями\ в\ маршруте\ (добавлять\ и\ удалять)
    Назначать\ маршрут\ поезду
    Добавлять\ вагоны\ к\ поезду
    Отцеплять\ вагоны\ от\ поезда
    Занять\ объем/место\ в\ вагоне
    Перемещать\ поезд\ по\ маршруту\ вперед\ и\ назад
    Просматривать\ список\ станций\ и\ список\ поездов\ на\ станции
    Посмотреть\ все\ станции,\ поезда\ и\ список\ созданных\ маршрутов
    generate\ random\ data
    Показать\ все\ станции\ как\ объекты\ (метод\ класса\ .all)
    Найти\ поезд\ по\ его\ номеру
    Выйти
  ].freeze

  MENU_METHODS = %i[
    create_station
    create_train
    create_wagon
    create_route
    route_menu
    set_route_to_train
    add_wagon_to_train
    remove_wagon_from_train
    occupy_wagon
    move_train
    browse_trains_in_station
    statistics
    generate_data
    show_all_stations
    find_train_by_number
    exit
  ].freeze

  attr_reader :trains
  attr_writer :wagons

  MenuItem = Struct.new(:text, :handler)

  def initialize
    @stations = []
    @trains = []
    @routes = []
    @wagons = []
  end

  def start
    puts_separator
    puts "Программа управления железной дороги:"
    show_main_menu
    print "Выберите пункт меню: "
    selected_menu = gets.to_i
    raise INDEX_ERROR unless selected_menu.between?(1, MENU_METHODS.size)
    puts_separator
    select_from_menu(selected_menu)
  rescue StandardError => e
    puts e
    retry
  end

  private

  def puts_separator
    puts "-----------------------------------------------"
  end

  def show_main_menu
    MENU_ITEMS.each.with_index(1) { |item, index| puts "#{index} - #{item}" }
  end

  def select_from_menu(menu_item)
    method_name = MENU_METHODS[menu_item - 1]
    send(method_name)
    start
  end

  def show_train_type_menu
    TRAIN_TYPE_MENU.each.with_index(1) { |item, index| puts "#{index} - #{item}" }
  end

  def show_train_move_menu
    TRAIN_MOVE_MENU.each.with_index(1) { |item, index| puts "#{index} - #{item}" }
  end

  def puts_stations
    puts "Список станций:"
    puts NOT_DEFINED_ERROR if @stations.empty?
    @stations.each.with_index(1) { |station, index| puts "#{index} - #{station.name}" }
  end

  def puts_trains
    puts "Список поездов:"
    puts NOT_DEFINED_ERROR if @trains.empty?
    @trains.each.with_index(1) do |train, index|
      puts "#{index} - №#{train.number} - Тип: #{train.type} - "\
       	   "Вагоны: №№ #{train.wagons.map(&:number).join(',')}"
    end
  end

  def puts_routes
    puts "Список маршрутов:"
    puts NOT_DEFINED_ERROR if @routes.empty?
    @routes.each.with_index(1) do |route, index|
      route_stations = route.stations.map(&:name).join(" -> ")
      puts "#{index} - #{route_stations}"
    end
  end

  def puts_wagons
    puts "Список вагонов:"
    puts NOT_DEFINED_ERROR if @wagons.empty?
    @wagons.each.with_index(1) do |wagon, index|
      puts "#{index} - №#{wagon.number} - Тип: #{wagon.type} - "\
    	   "Объем: (free/total) #{wagon.free_volume}/#{wagon.capacity}"
    end
  end

  def statistics
    puts_routes
    puts_stations
    puts_trains
    puts_wagons
  end

  def show_all_stations
    puts "Созданы следующие объекты станций:"
    puts NOT_DEFINED_ERROR if Station.all.empty?
    puts Station.all.map(&:name).join(", ")
  end

  protected

  def create_station
    puts "Создать станцию:"
    print "Название: "
    station_name = gets.chomp
    @stations << Station.new(station_name)
    puts "Станция '#{station_name}' создана."
  rescue StandardError => e
    puts e
    retry
  end

  def create_train
    puts_separator
    show_train_type_menu
    print "Какой тип поезда хотите создать: "
    train_type = select_from_collection([PassengerTrain, CargoTrain])
    print "Номер поезда: "
    train_number = gets.chomp
    @trains << train_type.new(train_number)
    puts "Создан поезд №#{train_number}, Тип: #{train_type}"
  rescue StandardError => e
    puts e
    retry
  end

  def select_from_collection(collection)
    index = gets.to_i - 1
    raise INDEX_ERROR unless index.between?(0, collection.size - 1)
    collection[index]
  end

  def create_route
    if @stations.length >= 2
      puts_stations
      puts "Выберите начальную станцию"
      route_from = select_from_collection(@stations)
      puts "Выберите конечную станцию"
      route_to = select_from_collection(@stations)
      @routes << Route.new(route_from, route_to)
      puts "Создан маршрут: #{route_from.name} -> #{route_to.name}."
    else
      puts "Сначала создайте станции, чтобы создавать маршруты (не менее 2)"
    end
  rescue StandardError => e
    puts e
    retry
  end

  def create_wagon
    puts_separator
    show_train_type_menu
    print "Какой тип вагона хотите создать: "
    wagon_type = select_from_collection([PassengerWagon, CargoWagon])
    print "Номер вагона: "
    wagon_number = gets.chomp
    print "Задайте объем вагона: "
    wagon_capacity = gets.to_i
    @wagons << wagon_type.new(wagon_number, wagon_capacity)
    puts "Создан вагон №#{wagon_number}, Тип: #{wagon_type}, Свободный объем: #{wagon_capacity}"
  rescue StandardError => e
    puts e
    retry
  end

  def route_menu
    loop do
      puts "1 - Добавить промежуточную станцию"
      puts "2 - Удалить промежуточную станцию"
      puts "3 - Выйти"
      print "Выберите действие: "
      route_menu_choice = gets.to_i
      case route_menu_choice
      when 1 then add_extra_station
      when 2 then remove_extra_station
      when 3 then break
      else puts "Простите, я Вас не понял"
      end
      puts_separator
    end
  end

  def add_extra_station
    return if route_exist?
    puts "Выберите маршрут для редактирования"
    route = choose_route
    puts "Введите номер станции которую вы хотите добавить в маршрут"
    station = choose_station
    route.add_station(station)
    puts "Добавлена станция #{station.name} в маршрут: #{route.stations.map(&:name).join(' -> ')}"
  end

  def remove_extra_station
    return if route_exist?
    puts "Выберите маршрут для редактирования"
    route = choose_route
    puts "Введите номер станции которую вы хотите удалить из маршрута"
    station = choose_station
    route.remove_station(station)
    puts "Удалена станция #{station.name} из маршрута: #{route.stations.map(&:name).join(' -> ')}"
  end

  def set_route_to_train
    puts "Назначить маршрут:"
    return if train_exist?
    return if route_exist?
    train = choose_train
    puts "Выбран поезд '#{train.number}'"
    route = choose_route
    train.route = route
    puts "Поезду '#{train.number}' задан маршрут #{route.stations.map(&:name).join(' -> ')}."
  end

  def add_wagon_to_train
    return if train_exist?
    puts_separator
    puts "Выберите поезд для работы"
    train = choose_train
    puts "Выберите вагон для работы"
    wagon = choose_wagon
    raise INDEX_ERROR unless train.attachable_wagon?(wagon)
    train.add_wagon(wagon)
    puts "К поезду № #{train.number} добавлен вагон № #{wagon.number}."
  rescue StandardError => e
    puts e
    retry
  end

  def remove_wagon_from_train
    return if train_exist?
    puts "Выберите поезд для работы"
    train = choose_train
    wagon = train.wagons.last
    train.remove_wagon(wagon)
    puts "Отцеплен вагон от поезда № #{train.number}, Тип - #{train.type}"
    puts "Теперь у поезда #{train.wagons.size} вагон/ов"
  end

  def occupy_wagon
    puts "Выберите вагон для работы"
    wagon = choose_wagon
    occupy_passenger_wagon(wagon) if wagon.is_a?(PassengerWagon)
    occupy_cargo_wagon(wagon) if wagon.is_a?(CargoWagon)
  end

  def occupy_passenger_wagon(wagon)
    raise INDEX_ERROR unless wagon.has_free_volume?
    wagon.take_seat
    puts "Занято 1 место в вагоне №#{wagon.number}. Свободных мест: #{wagon.free_volume}"
  rescue StandardError => e
    puts e
  end

  def occupy_cargo_wagon(wagon)
    puts "Введите объем загрузки"
    volume = gets.to_i
    raise INDEX_ERROR unless volume <= wagon.free_volume
    wagon.take_volume(volume)
    puts "Загружен объем: #{volume} в вагон №#{wagon.number}. Свободный объем: #{wagon.free_volume}"
  rescue StandardError => e
    puts e
  end

  def move_train
    return if train_exist?
    puts "Переместить поезд по маршруту:"
    train = choose_train
    return if has_train_route?(train)
    show_train_move_menu
    print "Выберите действие: "
    train_action = select_from_collection(%i[move_to_next_station move_to_prev_station])
    train.send(train_action)
    puts "Поезд перемещен на следующую станцию"
  end

  def browse_trains_in_station
    puts "Список станций и список поездов на станции:"
    if @stations.empty?
      puts "Станции пока не заданы"
      return
    end
    station = choose_station
    puts "Список поездов на станции '#{station.name}':"
    station.each_train { |train| puts "#{train.number}, Тип - #{train.type}." }
  end

  def find_train_by_number
    puts "Введите номер поезда"
    number = gets.chomp
    desired_train = Train.find_by_number(number)
    if desired_train.nil?
      puts "Поезда с таким номером не существует"
    else
      puts "Поезд, который вы ищете:"
      puts "№ #{desired_train.number}, Тип: #{desired_train.type}"
      say_wagons(desired_train)
      say_route(desired_train)
    end
  end

  def say_route(train)
    if train.route.nil?
      puts "Маршрут поезду не задан"
    else
      puts "Поезд находится на станции: #{train.current_station.name}"
      puts "Маршрут следования: #{train.route.stations.map(&:name).join(' -> ')}"
    end
  end

  def say_wagons(train)
    if train.wagons.empty?
      puts "Прицепленных вагонов не имеет"
    else
      puts "Прицепленных вагонов: #{train.wagons.size}, Тип вагона: #{train.wagons.map(&:type)}"
    end
  end

  def train_exist?
    puts "Сначала создайте поезд!" if @trains.empty?
    @trains.empty?
  end

  def route_exist?
    puts "Сначала создайте маршрут!" if @routes.empty?
    @routes.empty?
  end

  def has_train_route?(train)
    puts "Поезду не присвоен маршрут!" if train.route.nil?
    train.route.nil?
  end

  def choose_station
    puts_stations
    print "Выберите станцию из списка: "
    select_from_collection(@stations)
  rescue StandardError => e
    puts e
    retry
  end

  def choose_train
    puts_trains
    print "Выберите поезд из списка: "
    select_from_collection(@trains)
  rescue StandardError => e
    puts e
    retry
  end

  def choose_route
    puts_routes
    print "Выберите маршрут из списка: "
    select_from_collection(@routes)
  rescue StandardError => e
    puts e
    retry
  end

  def choose_wagon
    puts_wagons
    print "Выберите вагон из списка: "
    select_from_collection(@wagons)
  rescue StandardError => e
    puts e
    retry
  end

  def generate_station
    @stations << Station.new("moscow")
    @stations << Station.new("samara")
    @stations << Station.new("penza")
    @stations << Station.new("s.petersburg")
    @stations << Station.new("pskov")
  end

  def generate_train
    @trains << PassengerTrain.new("999-PS")
    @trains << PassengerTrain.new("555-PS")
    @trains << CargoTrain.new("777-CG")
  end

  def generate_wagons
    @wagons << PassengerWagon.new("11-P", 3)
    @wagons << PassengerWagon.new("99-P", 5)
    @wagons << CargoWagon.new("22-C", 220)
    @wagons << CargoWagon.new("55-C", 550)
  end

  def generate_data
    generate_station
    generate_train
    generate_wagons
    puts "Trains, Wagons and Stations are randomly generated"
  end
end

rr = Main.new
rr.start
