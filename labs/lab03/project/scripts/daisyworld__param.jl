using DrWatson
@quickactivate "project"

using Agents
using CairoMakie
using DrWatson: dict_list, savename

include(srcdir("daisyworld.jl"))

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
println("ПАРАМЕТРИЧЕСКАЯ ВИЗУАЛИЗАЦИЯ DAISYWORLD")
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
    
    # Функция для определения цвета маргаритки
    daisycolor(a::Daisy) = a.breed == :white ? :white : :black
    
    # Настройки визуализации
    plotkwargs = (
        agent_color = daisycolor,
        agent_size = 20,
        agent_marker = '✿',
        heatarray = :temperature,
        heatkwargs = (colorrange = (-20, 60),)
    )
    
    # Визуализация на разных шагах
    plt1, _ = abmplot(model; plotkwargs...)
    
    step!(model, 5)
    plt2, _ = abmplot(model; plotkwargs...)
    
    step!(model, 40)
    plt3, _ = abmplot(model; plotkwargs...)
    
    # Формируем имена файлов с параметрами
    base_name = savename("daisyworld", params, digits=5)
    plt1_name = base_name * "_step01.png"
    plt2_name = base_name * "_step04.png"
    plt3_name = base_name * "_step40.png"
    
    # Сохраняем графики
    save(plotsdir(plt1_name), plt1)
    save(plotsdir(plt2_name), plt2)
    save(plotsdir(plt3_name), plt3)
    
    println("   ✅ Графики сохранены:")
    println("      - ", plotsdir(plt1_name))
    println("      - ", plotsdir(plt2_name))
    println("      - ", plotsdir(plt3_name))
end

println("\n" * "="^60)
println("✅ ПАРАМЕТРИЧЕСКАЯ ВИЗУАЛИЗАЦИЯ ЗАВЕРШЕНА!")
println("="^60)
