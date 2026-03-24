# # Исследование влияния миграции
# 
# **Цель:** Изучить, как интенсивность миграции между городами влияет
# на скорость распространения инфекции.
# 
# ## Теоретическое введение
# 
# Миграция создаёт связи между городами, позволяя инфекции распространяться
# за пределы первоначального очага. При высокой миграции:
# - Инфекция быстрее достигает новых городов
# - Пик заболеваемости наступает раньше
# - Может увеличиться общее число заболевших

using DrWatson
@quickactivate

using Agents, DataFrames, Plots, CSV, Random, Statistics
include(srcdir("sir_model.jl"))

# ## Функция создания матрицы миграции

function create_migration_matrix(C, intensity)
    M = ones(C, C) .* intensity ./ (C-1)
    for i = 1:C
        M[i, i] = 1 - intensity
    end
    return M
end

# ## Функция измерения времени пика

function peak_time(p)
    migration_rates = create_migration_matrix(p[:C], p[:migration_intensity])
    
    model = initialize_sir(;
        Ns = p[:Ns],
        β_und = p[:β_und],
        β_det = p[:β_det],
        infection_period = p[:infection_period],
        detection_time = p[:detection_time],
        death_rate = p[:death_rate],
        reinfection_probability = p[:reinfection_probability],
        Is = p[:Is],
        seed = p[:seed],
        migration_rates = migration_rates,
    )
    
    infected_frac(model) = count(a.status == :I for a in allagents(model)) / nagents(model)
    peak = 0.0
    peak_step = 0
    
    for step = 1:p[:n_steps]
        Agents.step!(model, 1)
        frac = infected_frac(model)
        if frac > peak
            peak = frac
            peak_step = step
        end
    end
    
    return (peak_time = peak_step, peak_value = peak)
end

# ## Сканирование интенсивностей

migration_intensities = 0.0:0.1:0.5
seeds = [42, 43, 44]

params_list = []
for mig in migration_intensities
    for s in seeds
        push!(
            params_list,
            Dict(
                :migration_intensity => mig,
                :C => 3,
                :Ns => [1000, 1000, 1000],
                :β_und => [0.5, 0.5, 0.5],
                :β_det => [0.05, 0.05, 0.05],
                :infection_period => 14,
                :detection_time => 7,
                :death_rate => 0.02,
                :reinfection_probability => 0.1,
                :Is => [1, 0, 0],
                :seed => s,
                :n_steps => 150,
            ),
        )
    end
end

println("="^60)
println("ИССЛЕДОВАНИЕ ВЛИЯНИЯ МИГРАЦИИ")
println("="^60)
println("Всего экспериментов: $(length(params_list))")

results = []
for (i, params) in enumerate(params_list)
    data = peak_time(params)
    push!(results, merge(params, Dict(pairs(data))))
    if i % 5 == 0
        println("  Прогресс: $i/$(length(params_list))")
    end
end

# ## Сохранение и визуализация

df = DataFrame(results)
CSV.write(datadir("migration_scan_all.csv"), df)

grouped = combine(
    groupby(df, [:migration_intensity]),
    :peak_time => mean => :mean_peak_time,
    :peak_value => mean => :mean_peak_value,
)

# График времени пика
plot(grouped.migration_intensity, grouped.mean_peak_time,
     marker = :circle,
     xlabel = "Интенсивность миграции",
     ylabel = "Время до пика (дни)",
     label = "Время пика",
     linewidth = 2,
     color = :blue)
title!("Влияние миграции на время достижения пика")
savefig(plotsdir("migration_peak_time.png"))

# График пиковой заболеваемости
plot(grouped.migration_intensity, grouped.mean_peak_value .* 3000,
     marker = :square,
     xlabel = "Интенсивность миграции",
     ylabel = "Численность в пике",
     label = "Пиковая заболеваемость",
     linewidth = 2,
     color = :red)
title!("Влияние миграции на пик заболеваемости")
savefig(plotsdir("migration_peak_value.png"))

# ## Анализ

println("\n" * "="^60)
println("РЕЗУЛЬТАТЫ")
println("="^60)

min_time_row = grouped[argmin(grouped.mean_peak_time), :]
println("\n📊 Время пика от интенсивности:")
for row in eachrow(grouped)
    println("  intensity = $(row.migration_intensity): время = $(round(row.mean_peak_time, digits=1)) дней")
end

println("\n🎯 Оптимальная интенсивность для быстрого распространения:")
println("  Интенсивность = $(min_time_row.migration_intensity)")
println("  Время до пика = $(round(min_time_row.mean_peak_time, digits=1)) дней")

println("\n✅ Исследование миграции завершено!")
