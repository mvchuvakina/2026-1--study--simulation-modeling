using DrWatson
@quickactivate "project"

using DifferentialEquations
using DataFrames
using StatsPlots
using LaTeXStrings
using Plots
using JLD2
using Statistics

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

function lotka_volterra!(du, u, p, t)
    x, y = u
    α, β, δ, γ = p
    du[1] = α*x - β*x*y
    du[2] = δ*x*y - γ*y
    nothing
end

function run_experiment(params::Dict)
    @unpack u0, α, β, δ, γ, tspan = params
    prob = ODEProblem(lotka_volterra!, u0, tspan, [α, β, δ, γ])
    sol = solve(prob, Tsit5(), saveat=0.5)

    df = DataFrame(t=sol.t, prey=[u[1] for u in sol.u],
                          predator=[u[2] for u in sol.u])

    return Dict(
        "solution" => sol,
        "df" => df,
        "mean_prey" => mean(df.prey),
        "mean_predator" => mean(df.predator),
        "max_prey" => maximum(df.prey),
        "max_predator" => maximum(df.predator)
    )
end

base_params = Dict(
    :u0 => [40.0, 9.0],
    :tspan => (0.0, 200.0)
)

alpha_values = [0.05, 0.1, 0.2, 0.3]
β_fixed = 0.02
δ_fixed = 0.01
γ_fixed = 0.3

println("📊 Параметрическое исследование Лотки-Вольтерры")
println("="^60)
println("1. Влияние α (скорости размножения жертв)")
println("   α = ", alpha_values)

results_alpha = []

for α in alpha_values
    params = Dict(
        :u0 => base_params[:u0],
        :tspan => base_params[:tspan],
        :α => α,
        :β => β_fixed,
        :δ => δ_fixed,
        :γ => γ_fixed
    )

    result = run_experiment(params)
    push!(results_alpha, (α=α,
                          mean_prey=result["mean_prey"],
                          mean_predator=result["mean_predator"],
                          max_prey=result["max_prey"],
                          max_predator=result["max_predator"]))

    plot(result["df"].t, result["df"].prey,
         label="α = $α", lw=2)
end

plt_alpha = plot(xlabel="Время",
                 ylabel="Популяция жертв",
                 title="Влияние α на численность жертв",
                 legend=:topright,
                 grid=true)
current()
savefig(plotsdir(script_name, "alpha_sensitivity_prey.png"))

for α in alpha_values
    params = Dict(
        :u0 => base_params[:u0],
        :tspan => base_params[:tspan],
        :α => α,
        :β => β_fixed,
        :δ => δ_fixed,
        :γ => γ_fixed
    )
    result = run_experiment(params)
    plot!(result["df"].t, result["df"].predator,
          label="α = $α", lw=2)
end

plt_alpha_pred = plot(xlabel="Время",
                      ylabel="Популяция хищников",
                      title="Влияние α на численность хищников",
                      legend=:topright,
                      grid=true)
savefig(plotsdir(script_name, "alpha_sensitivity_predator.png"))

gamma_values = [0.2, 0.3, 0.4, 0.5]
α_fixed = 0.1
β_fixed = 0.02
δ_fixed = 0.01

println("\n2. Влияние γ (смертности хищников)")
println("   γ = ", gamma_values)

results_gamma = []

for γ in gamma_values
    params = Dict(
        :u0 => base_params[:u0],
        :tspan => base_params[:tspan],
        :α => α_fixed,
        :β => β_fixed,
        :δ => δ_fixed,
        :γ => γ
    )

    result = run_experiment(params)
    push!(results_gamma, (γ=γ,
                          mean_prey=result["mean_prey"],
                          mean_predator=result["mean_predator"],
                          max_prey=result["max_prey"],
                          max_predator=result["max_predator"]))

    plot(result["df"].t, result["df"].predator,
         label="γ = $γ", lw=2)
end

plt_gamma = plot(xlabel="Время",
                 ylabel="Популяция хищников",
                 title="Влияние γ на численность хищников",
                 legend=:topright,
                 grid=true)
savefig(plotsdir(script_name, "gamma_sensitivity.png"))

println("\n📋 Результаты исследования α:")
for r in results_alpha
    println("  α = $(r.α): ср.жертвы = $(round(r.mean_prey, digits=1)), " *
            "ср.хищники = $(round(r.mean_predator, digits=1))")
end

println("\n📋 Результаты исследования γ:")
for r in results_gamma
    println("  γ = $(r.γ): ср.жертвы = $(round(r.mean_prey, digits=1)), " *
            "ср.хищники = $(round(r.mean_predator, digits=1))")
end

@save datadir(script_name, "results_alpha.jld2") results_alpha
@save datadir(script_name, "results_gamma.jld2") results_gamma

println("\n✅ Все графики сохранены в: ", plotsdir(script_name))
println("✅ Результаты сохранены в: ", datadir(script_name))
