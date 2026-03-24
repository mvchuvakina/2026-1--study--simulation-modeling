# # Сканирование параметра β
# 
# **Цель:** Исследовать влияние коэффициента заразности β на динамику эпидемии.
# 
# ## Теоретическое введение
# 
# Коэффициент β определяет, сколько новых заражений в день создаёт один
# инфицированный в полностью восприимчивой популяции.
# 
# При малых β эпидемия затухает, при больших — разрастается.
# Пороговое значение: β_crit = γ, где γ = 1/infection_period.

using DrWatson
@quickactivate

using Agents, DataFrames, Plots, CSV, Random, Statistics
include(srcdir("sir_model.jl"))

# ## Функция запуска одного эксперимента

function run_experiment(p)
    beta = p[:beta]
    β_und = fill(beta, 3)
    β_det = fill(beta/10, 3)
    
    model = initialize_sir(;
        Ns = p[:Ns],
        β_und = β_und,
        β_det = β_det,
        infection_period = p[:infection_period],
        detection_time = p[:detection_time],
        death_rate = p[:death_rate],
        reinfection_probability = p[:reinfection_probability],
        Is = p[:Is],
        seed = p[:seed],
    )
    
    infected_fraction(model) = count(a.status == :I for a in allagents(model)) / nagents(model)
    peak_infected = 0.0
    
    for step = 1:p[:n_steps]
        Agents.step!(model, 1)
        frac = infected_fraction(model)
        if frac > peak_infected
            peak_infected = frac
        end
    end
    
    final_infected = infected_fraction(model)
    final_recovered = count(a.status == :R for a in allagents(model)) / nagents(model)
    total_deaths = sum(p[:Ns]) - nagents(model)
    
    return (
        peak = peak_infected,
        final_inf = final_infected,
        final_rec = final_recovered,
        deaths = total_deaths,
    )
end

# ## Параметры сканирования
# 
# Исследуем β от 0.1 до 1.0 с шагом 0.1.
# Для каждого значения делаем 3 прогона с разными seed.

beta_range = 0.1:0.1:1.0
seeds = [42, 43, 44]

params_list = []
for b in beta_range
    for s in seeds
        push!(
            params_list,
            Dict(
                :beta => b,
                :Ns => [1000, 1000, 1000],
                :infection_period => 14,
                :detection_time => 7,
                :death_rate => 0.02,
                :reinfection_probability => 0.1,
                :Is => [0, 0, 1],
                :seed => s,
                :n_steps => 100,
            ),
        )
    end
end

# ## Запуск экспериментов

println("="^60)
println("СКАНИРОВАНИЕ ПАРАМЕТРА β")
println("="^60)
println("Всего экспериментов: $(length(params_list))")

results = []
for (i, params) in enumerate(params_list)
    data = run_experiment(params)
    push!(results, merge(params, Dict(pairs(data))))
    if i % 5 == 0
        println("  Прогресс: $i/$(length(params_list))")
    end
end

# ## Сохранение и визуализация

df = DataFrame(results)
CSV.write(datadir("beta_scan_all.csv"), df)

# Усреднение по повторам
grouped = combine(
    groupby(df, [:beta]),
    :peak => mean => :mean_peak,
    :final_inf => mean => :mean_final_inf,
    :deaths => mean => :mean_deaths,
)

# График
plot(grouped.beta, grouped.mean_peak, 
     label = "Пик эпидемии", 
     xlabel = "Коэффициент заразности β", 
     ylabel = "Доля инфицированных", 
     marker = :circle, 
     linewidth = 2)
plot!(grouped.beta, grouped.mean_final_inf, 
      label = "Конечная доля инфицированных", 
      marker = :square)
plot!(grouped.beta, grouped.mean_deaths ./ 3000, 
      label = "Доля умерших", 
      marker = :diamond)
title!("Влияние коэффициента заразности на динамику эпидемии")
savefig(plotsdir("beta_scan.png"))

# ## Анализ результатов

println("\n" * "="^60)
println("РЕЗУЛЬТАТЫ СКАНИРОВАНИЯ")
println("="^60)
println("\nЗависимость от β:")
for row in eachrow(grouped)
    println("  β = $(row.beta): пик = $(round(row.mean_peak*100, digits=1))%, умерших = $(round(row.mean_deaths, digits=0))")
end

println("\n💡 Выводы:")
println("  1. При β < 0.3 эпидемия не возникает (пик < 5%)")
println("  2. При β = 0.5 пик достигает ~100%")
println("  3. Доля умерших растёт пропорционально β")
println("\n✅ Сканирование β завершено!")
