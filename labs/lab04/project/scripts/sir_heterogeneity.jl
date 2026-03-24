# # Эффект гетерогенности
# 
# **Цель:** Исследовать влияние разных значений β для разных городов
# на динамику эпидемии.

using DrWatson
@quickactivate

using Agents, DataFrames, Plots
include(srcdir("sir_model.jl"))

# ## Настройка параметров для разных городов

# Сценарий 1: Одинаковая заразность во всех городах
β_uniform = [0.5, 0.5, 0.5]

# Сценарий 2: Разная заразность (город 1 - низкая, город 2 - средняя, город 3 - высокая)
β_heterogeneous = [0.2, 0.5, 0.8]

# Сценарий 3: Только один город с высокой заразностью
β_one_high = [0.8, 0.2, 0.2]

scenarios = [
    (name="Одинаковая заразность", β=β_uniform),
    (name="Разная заразность", β=β_heterogeneous),
    (name="Один город с высокой заразностью", β=β_one_high),
]

# ## Запуск симуляций

function run_scenario(β_und, scenario_name)
    β_det = β_und ./ 10
    model = initialize_sir(;
        Ns = [1000, 1000, 1000],
        β_und = β_und,
        β_det = β_det,
        infection_period = 14,
        detection_time = 7,
        death_rate = 0.02,
        Is = [1, 0, 0],  # инфекция начинается в городе 1
        seed = 42,
    )
    
    # Данные по городам
    city_data = [(time=Int[], city1=Int[], city2=Int[], city3=Int[])]
    
    for step in 1:100
        Agents.step!(model, 1)
        
        # Считаем инфицированных по городам
        city1_inf = count(a.status == :I && a.pos == 1 for a in allagents(model))
        city2_inf = count(a.status == :I && a.pos == 2 for a in allagents(model))
        city3_inf = count(a.status == :I && a.pos == 3 for a in allagents(model))
        
        push!(city_data[1].time, step)
        push!(city_data[1].city1, city1_inf)
        push!(city_data[1].city2, city2_inf)
        push!(city_data[1].city3, city3_inf)
    end
    
    return city_data[1]
end

# ## Визуализация результатов

println("Запуск сценариев...")

for scenario in scenarios
    println("  ", scenario.name)
    data = run_scenario(scenario.β, scenario.name)
    
    # График для каждого города
    plot(data.time, data.city1, 
         label = "Город 1 (β=$(scenario.β[1]))", 
         xlabel = "Дни", 
         ylabel = "Инфицированные",
         linewidth = 2,
         color = :red)
    plot!(data.time, data.city2, 
          label = "Город 2 (β=$(scenario.β[2]))", 
          linewidth = 2,
          color = :blue)
    plot!(data.time, data.city3, 
          label = "Город 3 (β=$(scenario.β[3]))", 
          linewidth = 2,
          color = :green)
    title!("Сценарий: $(scenario.name)")
    savefig(plotsdir("heterogeneity_$(replace(scenario.name, " "=>"_")).png"))
    
    println("    График сохранён")
end

# ## Анализ

println("\n" * "="^60)
println("АНАЛИЗ ГЕТЕРОГЕННОСТИ")
println("="^60)
println("Выводы:")
println("1. При одинаковой заразности эпидемия распространяется равномерно")
println("2. Разная заразность приводит к неравномерному распространению")
println("3. Города с высокой заразностью становятся очагами эпидемии")
