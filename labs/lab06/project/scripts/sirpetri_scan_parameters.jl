# ============================================================================
# Сканирование параметра β (коэффициента заражения)
# ============================================================================

using DrWatson
@quickactivate

using DataFrames, CSV, Plots

include(srcdir("SIRPetri.jl"))
using .SIRPetri

# Параметры
β_range = 0.1:0.05:0.8
γ_fixed = 0.1
tmax = 100.0

println("="^60)
println("СКАНИРОВАНИЕ ПАРАМЕТРА β")
println("="^60)
println("γ = $γ_fixed")
println("Диапазон β: $(minimum(β_range)) : $(step(β_range)) : $(maximum(β_range))")
println()

results = []

for β in β_range
    println("Исследование β = $β...")
    net, u0, _ = build_sir_network(β, γ_fixed)
    df = simulate_deterministic(net, u0, (0.0, tmax), saveat = 0.5, rates = [β, γ_fixed])
    
    peak_I = maximum(df.I)
    final_R = df.R[end]
    push!(results, (β = β, peak_I = peak_I, final_R = final_R))
    
    println("  Пик I: $(round(peak_I, digits=1)), Конечное R: $(round(final_R, digits=1))")
end

# Сохранение результатов
df_scan = DataFrame(results)
CSV.write(datadir("sir_scan.csv"), df_scan)
println()
println("Результаты сохранены: data/sir_scan.csv")

# График
p = plot(
    df_scan.β,
    [df_scan.peak_I df_scan.final_R],
    label = ["Peak I" "Final R"],
    marker = :circle,
    xlabel = "β (infection rate)",
    ylabel = "Population",
    linewidth = 2,
)
savefig(plotsdir("sir_scan.png"))
println("График сохранён: plots/sir_scan.png")

println()
println("="^60)
println("СКАНИРОВАНИЕ ЗАВЕРШЕНО")
println("="^60)
