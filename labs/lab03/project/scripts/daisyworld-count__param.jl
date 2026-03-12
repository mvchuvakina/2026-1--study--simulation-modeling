using DrWatson
@quickactivate "project"

using Agents
using CairoMakie
using DataFrames
using DrWatson: dict_list, savename

include(srcdir("daisyworld.jl"))

# -------------------------------------------------------------------
# ФУНКЦИИ ДЛЯ СБОРА ДАННЫХ
# -------------------------------------------------------------------
black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]

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
    :scenario => :default,
    :seed => 165,
)

# Создаём список всех комбинаций параметров
params_list = dict_list(param_dict)

println("="^60)
println("ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ ЧИСЛЕННОСТИ МАРГАРИТОК")
println("="^60)
println("\n📊 Всего комбинаций параметров: ", length(params_list))
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
    agent_df, model_df = run!(model, 1000; adata)
    
    # Создаём график
    figure = Figure(size = (600, 400))
    ax = Axis(figure[1, 1],
        xlabel = "Время, шаги",
        ylabel = "Количество маргариток",
        title = "Динамика численности (max_age=$(params[:max_age]), init_white=$(params[:init_white]))"
    )
    
    blackl = lines!(ax, agent_df[!, :time], agent_df[!, :count_black],
        color = :black, linewidth = 2, label = "Черные")
    whitel = lines!(ax, agent_df[!, :time], agent_df[!, :count_white],
        color = :orange, linewidth = 2, label = "Белые")
    
    Legend(figure[1, 2], [blackl, whitel], ["Черные", "Белые"], labelsize = 12)
    
    # Сохраняем график
    plt_name = savename("daisy-count", params, "png", digits=5)
    save(plotsdir(plt_name), figure)
    println("   ✅ График сохранён: ", plotsdir(plt_name))
end

println("\n" * "="^60)
println("✅ ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ ЧИСЛЕННОСТИ ЗАВЕРШЕНО!")
println("="^60)
