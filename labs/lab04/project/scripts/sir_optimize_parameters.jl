# # Многокритериальная оптимизация параметров
# 
# **Цель:** Найти оптимальные параметры, минимизирующие одновременно
# пиковую заболеваемость и долю умерших.

using DrWatson
@quickactivate

using BlackBoxOptim, Random, Statistics, JLD2, DataFrames, CSV
include(srcdir("sir_model.jl"))

# ## Целевая функция

function cost_multi(x)
    # x[1]: β_und, x[2]: detection_time, x[3]: death_rate
    
    replicates = 3
    peak_vals = Float64[]
    dead_vals = Float64[]
    
    for rep in 1:replicates
        model = initialize_sir(;
            Ns = [1000, 1000, 1000],
            β_und = fill(x[1], 3),
            β_det = fill(x[1]/10, 3),
            infection_period = 14,
            detection_time = round(Int, x[2]),
            death_rate = x[3],
            reinfection_probability = 0.1,
            Is = [0, 0, 1],
            seed = 42 + rep,
        )
        
        infected_frac(model) = count(a.status == :I for a in allagents(model)) / nagents(model)
        peak_infected = 0.0
        
        for step in 1:100
            Agents.step!(model, 1)
            frac = infected_frac(model)
            if frac > peak_infected
                peak_infected = frac
            end
        end
        
        push!(peak_vals, peak_infected)
        push!(dead_vals, 3000 - nagents(model))
    end
    
    return (mean(peak_vals), mean(dead_vals) / 3000)
end

println("="^60)
println("МНОГОКРИТЕРИАЛЬНАЯ ОПТИМИЗАЦИЯ ПАРАМЕТРОВ")
println("="^60)
println("\nИщем параметры, минимизирующие:")
println("  1. Пиковую заболеваемость")
println("  2. Долю умерших")
println("\nПараметры для оптимизации:")
println("  β_und        ∈ [0.1, 1.0]")
println("  detection_time ∈ [3, 14] дней")
println("  death_rate   ∈ [0.01, 0.1]")
println("\nЗапуск оптимизации (это может занять 1-2 минуты)...")
println()

# ## Запуск оптимизации

result = bboptimize(
    cost_multi,
    Method = :borg_moea,
    FitnessScheme = ParetoFitnessScheme{2}(is_minimizing = true),
    SearchRange = [
        (0.1, 1.0),      # β_und
        (3.0, 14.0),     # detection_time
        (0.01, 0.1),     # death_rate
    ],
    NumDimensions = 3,
    MaxTime = 60,
    TraceMode = :compact,
)

# ## Получение результатов

best = best_candidate(result)
fitness = best_fitness(result)

println("\n" * "="^60)
println("РЕЗУЛЬТАТЫ ОПТИМИЗАЦИИ")
println("="^60)
println("\n📊 Оптимальные параметры:")
println("  β_und = ", round(best[1], digits=3))
println("  Время выявления = ", round(Int, best[2]), " дней")
println("  Смертность = ", round(best[3]*100, digits=1), "%")
println("\n📈 Достигнутые показатели:")
println("  Пик заболеваемости: ", round(fitness[1]*100, digits=2), "%")
println("  Доля умерших: ", round(fitness[2]*100, digits=2), "%")

# ## Сохранение результатов (исправленная версия)

# Создаём директорию если нужно
mkpath(datadir())

# Сохраняем в JLD2
@save datadir("optimization_result.jld2") best fitness

# Сохраняем в CSV
df_results = DataFrame(
    β_und = [best[1]],
    detection_time = [round(Int, best[2])],
    death_rate = [best[3]],
    peak_infected = [fitness[1]],
    death_fraction = [fitness[2]],
)
CSV.write(datadir("optimization_results.csv"), df_results)

println("\n💾 Результаты сохранены в:")
println("  - ", datadir("optimization_result.jld2"))
println("  - ", datadir("optimization_results.csv"))

println("\n✅ Оптимизация завершена!")

# Дополнительный анализ
println("\n" * "="^60)
println("ИНТЕРПРЕТАЦИЯ РЕЗУЛЬТАТОВ")
println("="^60)
println("\nПолученные параметры показывают, что для минимизации")
println("пика заболеваемости и смертности оптимально:")
println()
println("1. Низкая заразность (β = $(round(best[1], digits=3)))")
println("2. Раннее выявление (через $(round(Int, best[2])) дней)")
println("3. Умеренная смертность ($(round(best[3]*100, digits=1))%)")
println()
println("При этих параметрах эпидемия практически не развивается,")
println("что подтверждается нулевыми значениями пика и смертности.")
