# src/daisyworld.jl - Модель Daisyworld (Мир маргариток)
# Агентная модель для демонстрации саморегуляции климата

using Agents
import StatsBase
using Random

# -------------------------------------------------------------------
# 1. ОПРЕДЕЛЕНИЕ АГЕНТА
# -------------------------------------------------------------------
# Создаем структуру маргаритки. Наследуемся от GridAgent (агент на клеточной сетке).
@agent struct Daisy(GridAgent{2})
    breed::Symbol      # :black или :white
    age::Int           # возраст маргаритки
    albedo::Float64    # альбедо (отражающая способность) от 0 до 1
end

# -------------------------------------------------------------------
# 2. ФУНКЦИИ ДЛЯ РАСЧЕТА ТЕМПЕРАТУРЫ
# -------------------------------------------------------------------
# Функция обновления локальной температуры для клетки
function update_surface_temperature!(pos, model)
    # Если клетка пуста
    if isempty(pos, model)
        absorbed_luminosity = (1 - model.surface_albedo) * model.solar_luminosity
    else
        # Если в клетке есть маргаритка
        daisy = model[id_in_position(pos, model)]
        absorbed_luminosity = (1 - daisy.albedo) * model.solar_luminosity
    end
    
    # Расчет локального нагрева (эмпирическая формула из методички)
    local_heating = absorbed_luminosity > 0 ? 72 * log(absorbed_luminosity) + 80 : 80
    
    # Обновляем температуру клетки (среднее между текущей и новым нагревом)
    model.temperature[pos...] = (model.temperature[pos...] + local_heating) / 2
end

# Функция диффузии температуры между соседними клетками
function diffuse_temperature!(pos, model)
    ratio = model.ratio  # коэффициент диффузии
    npos = nearby_positions(pos, model)  # соседние позиции
    
    # Рассчитываем новую температуру с учетом диффузии
    model.temperature[pos...] = (1 - ratio) * model.temperature[pos...] +
                                 sum(model.temperature[p...] for p in npos) * 0.125 * ratio
end

# -------------------------------------------------------------------
# 3. ФУНКЦИЯ РАЗМНОЖЕНИЯ
# -------------------------------------------------------------------
function propagate!(pos, model)
    # Если клетка не пуста, ничего не делаем
    isempty(pos, model) && return
    
    daisy = model[id_in_position(pos, model)]
    temperature = model.temperature[pos...]
    
    # Вероятность размножения зависит от температуры (формула из методички)
    seed_threshold = (0.1457 * temperature - 0.0032 * temperature^2) - 0.6443
    
    # Если вероятность превышает случайное число, пробуем размножиться
    if rand(abmrng(model)) < seed_threshold
        # Ищем случайную пустую соседнюю клетку
        empty_near_pos = random_nearby_position(pos, model, 1, npos -> isempty(npos, model))
        
        if !isnothing(empty_near_pos)
            # Добавляем новую маргаритку того же цвета с возрастом 0
            add_agent!(empty_near_pos, model, daisy.breed, 0, daisy.albedo)
        end
    end
end

# -------------------------------------------------------------------
# 4. ФУНКЦИИ ШАГА МОДЕЛИ
# -------------------------------------------------------------------
# Функция шага для маргаритки (вызывается для каждого агента)
function daisy_step!(agent::Daisy, model)
    # Увеличиваем возраст
    agent.age += 1
    
    # Если возраст превысил максимальный, маргаритка умирает
    if agent.age >= model.max_age
        remove_agent!(agent, model)
    end
end

# Функция шага для модели (глобальные процессы)
function daisyworld_step!(model)
    # Проходим по всем позициям сетки
    for p in positions(model)
        update_surface_temperature!(p, model)
        diffuse_temperature!(p, model)
        propagate!(p, model)
    end
    
    # Увеличиваем счетчик времени
    model.tick = model.tick + 1
    
    # Изменяем солнечную активность в зависимости от сценария
    solar_activity!(model)
end

# -------------------------------------------------------------------
# 5. ФУНКЦИЯ ИЗМЕНЕНИЯ СОЛНЕЧНОЙ АКТИВНОСТИ
# -------------------------------------------------------------------
function solar_activity!(model)
    if model.scenario == :ramp
        # Сценарий "ramp" - солнечная активность сначала растет, потом падает
        if model.tick > 200 && model.tick ≤ 400
            model.solar_luminosity += model.solar_change
        end
        if model.tick > 500 && model.tick ≤ 750
            model.solar_luminosity -= model.solar_change / 2
        end
    elseif model.scenario == :change
        # Сценарий "change" - постоянный рост солнечной активности
        model.solar_luminosity += model.solar_change
    end
end

# -------------------------------------------------------------------
# 6. ФУНКЦИЯ ИНИЦИАЛИЗАЦИИ МОДЕЛИ
# -------------------------------------------------------------------
function daisyworld(;
    griddim = (30, 30),
    max_age = 25,
    init_white = 0.2,        # доля белых маргариток при старте
    init_black = 0.2,        # доля черных маргариток при старте
    albedo_white = 0.75,
    albedo_black = 0.25,
    surface_albedo = 0.4,
    solar_change = 0.005,
    solar_luminosity = 1.0,
    scenario = :default,
    seed = 165
)
    # Создаем генератор случайных чисел для воспроизводимости
    rng = MersenneTwister(seed)
    
    # Создаем пространство - квадратная сетка с периодическими границами
    space = GridSpaceSingle(griddim)
    
    # Свойства модели
    properties = Dict(
        :max_age => max_age,
        :surface_albedo => surface_albedo,
        :solar_luminosity => solar_luminosity,
        :solar_change => solar_change,
        :scenario => scenario,
        :tick => 0,
        :ratio => 0.5,
        :temperature => zeros(griddim)
    )
    
    # Создаем модель
    model = StandardABM(Daisy, space;
        properties = properties,
        rng = rng,
        agent_step! = daisy_step!,
        model_step! = daisyworld_step!
    )
    
    # Получаем все позиции сетки
    grid = collect(positions(model))
    num_positions = prod(griddim)
    
    # Размещаем белые маргаритки
    white_positions = StatsBase.sample(grid, Int(init_white * num_positions); replace = false)
    for wp in white_positions
        add_agent!(wp, model, :white, rand(abmrng(model), 0:max_age), albedo_white)
    end
    
    # Размещаем черные маргаритки (на оставшихся свободных местах)
    allowed = setdiff(grid, white_positions)
    black_positions = StatsBase.sample(allowed, Int(init_black * num_positions); replace = false)
    for bp in black_positions
        add_agent!(bp, model, :black, rand(abmrng(model), 0:max_age), albedo_black)
    end
    
    # Инициализируем температуру поверхности
    for p in positions(model)
        update_surface_temperature!(p, model)
    end
    
    return model
end
