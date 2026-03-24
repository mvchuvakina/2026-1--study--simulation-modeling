# # Исследование порога эпидемии
# 
# **Цель:** Найти минимальное значение β, при котором возникает эпидемия
# (пик I > 5% популяции) и сравнить с теоретическим порогом R₀ = 1.

using DrWatson
@quickactivate

using Agents, DataFrames, Plots, CSV
include(srcdir("sir_model.jl"))

# ## Функция для проверки, возникает ли эпидемия

function epidemic_occurs(β_und; threshold=0.05, n_steps=100, seed=42)
    β_det = β_und / 10
    γ = 1 / 14
    R₀ = β_und / γ
    
    model = initialize_sir(;
        Ns = [1000, 1000, 1000],
        β_und = fill(β_und, 3),
        β_det = fill(β_det, 3),
        infection_period = 14,
        detection_time = 7,
        death_rate = 0.02,
        Is = [0, 0, 1],
        seed = seed,
    )
    
    peak_infected = 0.0
    for step = 1:n_steps
        Agents.step!(model, 1)
        frac = count(a.status == :I for a in allagents(model)) / nagents(model)
        if frac > peak_infected
            peak_infected = frac
        end
    end
    
    return peak_infected > threshold, R₀, peak_infected
end

# ## Сканирование β для поиска порога

println("="^60)
println("ИССЛЕДОВАНИЕ ПОРОГА ЭПИДЕМИИ")
println("="^60)

β_range = 0.05:0.01:0.5
results = []

for β in β_range
    epidemic, R₀, peak = epidemic_occurs(β)
    push!(results, (β=β, R₀=R₀, epidemic=epidemic, peak=peak))
    status = epidemic ? "✓ Эпидемия" : "✗ Нет эпидемии"
    println("β = $(round(β, digits=3)), R₀ = $(round(R₀, digits=2)), $status (пик = $(round(peak*100, digits=1))%)")
end

# ## Находим пороговое значение

threshold_β = first(r.β for r in results if r.epidemic)
println("\n" * "="^60)
println("РЕЗУЛЬТАТЫ")
println("="^60)
println("Минимальное β для эпидемии: ", round(threshold_β, digits=3))
println("Соответствующее R₀: ", round(threshold_β / (1/14), digits=2))
println("Теоретический порог R₀ = 1 соответствует β = ", round(1/14, digits=3))

# ## Визуализация

df = DataFrame(results)
plot(df.β, df.peak .* 100, 
     label = "Пик заболеваемости", 
     xlabel = "Коэффициент заразности β", 
     ylabel = "Пик I, %",
     marker = :circle,
     linewidth = 2)
vline!([threshold_β], label = "Порог β = $(round(threshold_β, digits=3))", linestyle = :dash, color = :red)
hline!([5], label = "Порог 5%", linestyle = :dash, color = :green)
title!("Определение порога эпидемии")
savefig(plotsdir("threshold_study.png"))

println("\nГрафик сохранён в: ", plotsdir("threshold_study.png"))
