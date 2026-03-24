# # Оптимизация с ограничением
# 
# **Цель:** Найти параметры, минимизирующие число умерших
# при условии, что пик заболеваемости ниже 30%.

using DrWatson
@quickactivate

using BlackBoxOptim, Random, Statistics, JLD2, DataFrames, CSV
include(srcdir("sir_model.jl"))

# ## Целевая функция с ограничением

function cost_with_constraint(x)
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
    
    mean_peak = mean(peak_vals)
    mean_deaths = mean(dead_vals)
    
    # Штраф за превышение порога 30%
    penalty = 0.0
    if mean_peak > 0.3
        penalty = (mean_peak - 0.3) * 10000  # большой штраф
    end
    
    return mean_deaths + penalty  # минимизируем число умерших со штрафом
end

# ## Запуск оптимизации

println("="^60)
println("ОПТИМИЗАЦИЯ С ОГРАНИЧЕНИЕМ (пик < 30%)")
println("="^60)
println("\nИщем параметры, минимизирующие число умерших")
println("при условии, что пик заболеваемости < 30%")
println("\nПараметры для оптимизации:")
println("  β_und        ∈ [0.1, 1.0]")
println("  detection_time ∈ [3, 14] дней")
println("  death_rate   ∈ [0.01, 0.1]")
println("\nЗапуск оптимизации...")

result = bboptimize(
    cost_with_constraint,
    Method = :adaptive_de_rand_1_bin,
    SearchRange = [
        (0.1, 1.0),      # β_und
        (3.0, 14.0),     # detection_time
        (0.01, 0.1),     # death_rate
    ],
    NumDimensions = 3,
    MaxTime = 60,
    TraceMode = :compact,
)

best = best_candidate(result)
best_fitness_value = best_fitness(result)

# ## Проверка ограничения

# Проверяем, что найденные параметры удовлетворяют ограничению
function verify_constraint(x)
    β_und = fill(x[1], 3)
    β_det = fill(x[1]/10, 3)
    peaks = []
    
    for rep in 1:3
        model = initialize_sir(;
            Ns = [1000, 1000, 1000],
            β_und = β_und,
            β_det = β_det,
            infection_period = 14,
            detection_time = round(Int, x[2]),
            death_rate = x[3],
            Is = [0, 0, 1],
            seed = 42 + rep,
        )
        
        peak = 0.0
        for step in 1:100
            Agents.step!(model, 1)
            frac = count(a.status == :I for a in allagents(model)) / nagents(model)
            if frac > peak
                peak = frac
            end
        end
        push!(peaks, peak)
    end
    
    return mean(peaks)
end

mean_peak = verify_constraint(best)

println("\n" * "="^60)
println("РЕЗУЛЬТАТЫ ОПТИМИЗАЦИИ")
println("="^60)
println("\n📊 Оптимальные параметры:")
println("  β_und = ", round(best[1], digits=3))
println("  Время выявления = ", round(Int, best[2]), " дней")
println("  Смертность = ", round(best[3]*100, digits=1), "%")
println("\n📈 Достигнутые показатели:")
println("  Пик заболеваемости: ", round(mean_peak*100, digits=1), "%")
println("  Число умерших: ", round(best_fitness_value, digits=0))
println("\n✅ Ограничение (пик < 30%): ", mean_peak < 0.3 ? "Выполнено" : "Не выполнено")

# Сохранение результатов
results_dict = Dict(
    "best_params" => Dict(
        "β_und" => best[1],
        "detection_time" => round(Int, best[2]),
        "death_rate" => best[3],
    ),
    "fitness" => Dict(
        "deaths" => best_fitness_value,
        "peak_infected" => mean_peak,
    ),
)

@save datadir("optimization_constrained_result.jld2") results_dict

# Сохранение в CSV
df_results = DataFrame(
    β_und = [best[1]],
    detection_time = [round(Int, best[2])],
    death_rate = [best[3]],
    peak_infected = [mean_peak],
    deaths = [best_fitness_value],
)
CSV.write(datadir("optimization_constrained_results.csv"), df_results)

println("\n💾 Результаты сохранены в:")
println("  - ", datadir("optimization_constrained_result.jld2"))
println("  - ", datadir("optimization_constrained_results.csv"))
