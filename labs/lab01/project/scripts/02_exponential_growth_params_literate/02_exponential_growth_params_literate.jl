using DrWatson
@quickactivate "project"
using DifferentialEquations
using DataFrames
using Plots
using JLD2

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

function exponential_growth!(du, u, p, t)
    α = p
    du[1] = α * u[1]
end

alpha_values = [0.1, 0.3, 0.5, 0.8, 1.0]
results = []

println("Параметрическое исследование:")
println(repeat("-", 40))

for α in alpha_values
    println("Вычисляем для α = $α")
    prob = ODEProblem(exponential_growth!, [1.0], (0.0, 10.0), α)
    sol = solve(prob, Tsit5(), saveat=0.1)

    final_pop = last(sol.u)[1]
    doubling = log(2) / α

    push!(results, (α=α, final_population=final_pop, doubling_time=doubling))

    println("  u(10) = $(round(final_pop, digits=2)), T₂ = $(round(doubling, digits=2))")

    plot(sol, label="α=$α", lw=2)
end  # <- ВАЖНО: закрываем цикл!

plot!(xlabel="Время t", ylabel="Популяция u",
      title="Сравнение траекторий при разных α",
      legend=:topleft)
savefig(plotsdir(script_name, "comparison.png"))

results_df = DataFrame(results)
println("\nСводная таблица:")
println(results_df)

p2 = scatter(results_df.α, results_df.doubling_time,
             label="Численное решение",
             xlabel="Скорость роста α",
             ylabel="Время удвоения T₂",
             title="Зависимость времени удвоения от α",
             markersize=8, markercolor=:red)

α_range = 0.1:0.01:1.0
plot!(p2, α_range, log.(2) ./ α_range,
      label="Теория: T₂ = ln(2)/α",
      lw=2, linestyle=:dash, linecolor=:blue)
savefig(plotsdir(script_name, "doubling_time_vs_alpha.png"))

@save datadir(script_name, "param_results.jld2") results_df

println("\nГотово! Результаты сохранены в data/$(script_name)")
