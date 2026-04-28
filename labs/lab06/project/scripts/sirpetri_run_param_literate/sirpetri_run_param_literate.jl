using DrWatson
@quickactivate

using Random
using DataFrames, CSV, Plots

include(srcdir("SIRPetri.jl"))
using .SIRPetri

β_values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]
γ_values = [0.05, 0.1, 0.15, 0.2]
tmax = 100.0

println("="^60)
println("ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ МОДЕЛИ SIR")
println("="^60)
println("β = $β_values")
println("γ = $γ_values")
println("Всего комбинаций: $(length(β_values) * length(γ_values))")
println()

results = []

for β in β_values
    for γ in γ_values
        println("Исследование β = $β, γ = $γ...")

        net, u0, states = build_sir_network(β, γ)

        df_det = simulate_deterministic(net, u0, (0.0, tmax), saveat = 0.5, rates = [β, γ])

        Random.seed!(123)
        df_stoch = simulate_stochastic(net, u0, (0.0, tmax), rates = [β, γ])

        peak_I_det = maximum(df_det.I)
        peak_I_stoch = maximum(df_stoch.I)
        final_R_det = df_det.R[end]
        final_R_stoch = df_stoch.R[end]
        peak_time_det = df_det.time[argmax(df_det.I)]

        push!(results, (
            β = β, γ = γ,
            peak_I_det = peak_I_det, peak_I_stoch = peak_I_stoch,
            final_R_det = final_R_det, final_R_stoch = final_R_stoch,
            peak_time_det = peak_time_det,
        ))

        println("    Пик I: $(round(peak_I_det, digits=1)) (детерм.), $(round(peak_I_stoch, digits=1)) (стохаст.)")
    end
end

df_results = DataFrame(results)
CSV.write(datadir("sir_parametric_results.csv"), df_results)

p1 = heatmap(
    β_values, γ_values,
    [df_results[df_results.β .== b .&& df_results.γ .== g, :peak_I_det][1] for b in β_values, g in γ_values]',
    xlabel = "β", ylabel = "γ", title = "Peak I (детерм.)",
)
savefig(plotsdir("sir_parametric_heatmap.png"))

p2 = plot(xlabel = "β", ylabel = "Peak I", title = "Зависимость пика I от β", legend = :topleft)
for γ in γ_values
    df_subset = df_results[df_results.γ .== γ, :]
    plot!(p2, df_subset.β, df_subset.peak_I_det, label = "γ = $γ", marker = :circle)
end
savefig(plotsdir("sir_parametric_beta_dependence.png"))

p3 = plot(xlabel = "γ", ylabel = "Peak I", title = "Зависимость пика I от γ", legend = :topright)
for β in β_values
    df_subset = df_results[df_results.β .== β, :]
    plot!(p3, df_subset.γ, df_subset.peak_I_det, label = "β = $β", marker = :circle)
end
savefig(plotsdir("sir_parametric_gamma_dependence.png"))

p4 = plot(xlabel = "β", ylabel = "Peak I", title = "Сравнение (γ = 0.1)", legend = :topleft)
df_subset = df_results[df_results.γ .== 0.1, :]
plot!(p4, df_subset.β, df_subset.peak_I_det, label = "Детерминированная", marker = :circle)
plot!(p4, df_subset.β, df_subset.peak_I_stoch, label = "Стохастическая", marker = :square, linestyle = :dash)
savefig(plotsdir("sir_parametric_comparison.png"))

println()
println("Параметрическое исследование завершено!")
