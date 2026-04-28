using DrWatson
@quickactivate

using DataFrames, CSV, Plots

println("="^60)
println("ИТОГОВЫЙ ОТЧЁТ")
println("="^60)

df_det = CSV.read(datadir("sir_det.csv"), DataFrame)
df_stoch = CSV.read(datadir("sir_stoch.csv"), DataFrame)
df_scan = CSV.read(datadir("sir_scan.csv"), DataFrame)

p1 = plot(
    df_det.time,
    df_det.I,
    label = "Deterministic I",
    xlabel = "Time",
    ylabel = "Infected",
    title = "Comparison: Deterministic vs Stochastic",
    linewidth = 2,
    color = :blue,
)
plot!(p1, df_stoch.time, df_stoch.I, label = "Stochastic I", linewidth = 1, color = :red, alpha = 0.7)
savefig(plotsdir("comparison.png"))
println("  График сравнения: plots/comparison.png")

p2 = plot(
    df_scan.β,
    df_scan.peak_I,
    marker = :circle,
    xlabel = "β",
    ylabel = "Peak I",
    title = "Sensitivity: Peak I vs β",
    linewidth = 2,
)
savefig(plotsdir("sensitivity.png"))
println("  График чувствительности: plots/sensitivity.png")

println()
println("="^60)
println("ОТЧЁТ ЗАВЕРШЁН")
println("="^60)
