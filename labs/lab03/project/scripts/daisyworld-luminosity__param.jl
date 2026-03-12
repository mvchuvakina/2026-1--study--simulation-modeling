using DrWatson
@quickactivate "project"

using Agents
using CairoMakie
using DataFrames
using Statistics
using DrWatson: dict_list, savename

include(srcdir("daisyworld.jl"))

# -------------------------------------------------------------------
# ФУНКЦИИ ДЛЯ СБОРА ДАННЫХ
# -------------------------------------------------------------------
black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]

# Функция для средней температуры
temperature(model) = Statistics.mean(model.temperature)
mdata = [temperature, :solar_luminosity]

# -------------------------------------------------------------------
# ПАРАМЕТРЫ ЭКСПЕРИМЕНТА
# -------------------------------------------------------------------
param_dict = Dict(
    :griddim => (30, 30),
    :max_age => [25, 40],           # два варианта максимального возраста
    :init_white => [0.2, 0.8],       # два варианта начальной доли белых
    :init_black => 0.2,
    :albedo_white => 0.75,
    :albedo_black => 0.25,
    :surface_albedo => 0.4,
    :solar_change => 0.005,
    :solar_luminosity => 1.0,
    :scenario => :ramp,               # важно: используем сценарий с изменением активности
    :seed => 165,
)

# Создаём список всех комбинаций параметров
params_list = dict_list(param_dict)

println("="^60)
println("КОМПЛЕКСНОЕ ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ DAISYWORLD")
println("="^60)
println("\n📊 Всего комбинаций параметров: ", length(params_list))
println("🔄 Сценарий: :ramp (солнечная активность меняется)")
println("\nИсследуемые комбинации:")
for (i, params) in enumerate(params_list)
    println("   $i. max_age = $(params[:max_age]), init_white = $(params[:init_white])")
end

# -------------------------------------------------------------------
# ЗАПУСК ДЛЯ ВСЕХ КОМБИНАЦИЙ
# -------------------------------------------------------------------
for params in params_list
    println("\n" * "-"^60)
    println("🔄 Запуск с параметрами: max_age=$(params[:max_age]), init_white=$(params[:init_white])")
    
    # Создаём модель с текущими параметрами
    model = daisyworld(; params...)
    
    # Запускаем симуляцию на 1000 шагов
    agent_df, model_df = run!(model, 1000; adata = adata, mdata = mdata)
    
    # Создаём комплексный график
    figure = CairoMakie.Figure(size = (600, 600))
    
    # График 1: Численность маргариток
    ax1 = figure[1, 1] = Axis(figure,
        ylabel = "Количество маргариток",
        title = "Динамика численности"
    )
    
    blackl = lines!(ax1, agent_df[!, :time], agent_df[!, :count_black],
        color = :red, linewidth = 2, label = "Черные")
    whitel = lines!(ax1, agent_df[!, :time], agent_df[!, :count_white],
        color = :blue, linewidth = 2, label = "Белые")
    
    figure[1, 2] = Legend(figure, [blackl, whitel], ["Черные", "Белые"])
    
    # График 2: Температура
    ax2 = figure[2, 1] = Axis(figure,
        ylabel = "Средняя температура, °C",
        title = "Изменение температуры"
    )
    lines!(ax2, model_df[!, :time], model_df[!, :temperature],
        color = :red, linewidth = 2)
    
    # График 3: Солнечная активность
    ax3 = figure[3, 1] = Axis(figure,
        xlabel = "Время, шаги",
        ylabel = "Солнечная активность",
        title = "Изменение солнечной активности"
    )
    lines!(ax3, model_df[!, :time], model_df[!, :solar_luminosity],
        color = :red, linewidth = 2)
    
    # Скрываем подписи на верхних графиках
    for ax in (ax1, ax2)
        ax.xticklabelsvisible = false
    end
    
    # Сохраняем график
    plt_name = savename("daisy-luminosity", params, "png", digits=5)
    save(plotsdir(plt_name), figure)
    println("   ✅ Комплексный график сохранён: ", plotsdir(plt_name))
end

println("\n" * "="^60)
println("✅ КОМПЛЕКСНОЕ ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ ЗАВЕРШЕНО!")
println("="^60)
