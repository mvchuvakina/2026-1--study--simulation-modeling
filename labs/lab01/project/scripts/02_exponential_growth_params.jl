# Параметрическое исследование экспоненциального роста
using DrWatson
@quickactivate "project"
using DifferentialEquations
using DataFrames
using Plots

function exponential_growth!(du, u, p, t)
    α = p
    du[1] = α * u[1]
end

alpha_values = [0.1, 0.3, 0.5, 0.8, 1.0]
results = []

for α in alpha_values
    prob = ODEProblem(exponential_growth!, [1.0], (0.0, 10.0), α)
    sol = solve(prob, Tsit5(), saveat=0.1)
    
    final_pop = last(sol.u)[1]
    doubling = log(2) / α
    
    push!(results, (α=α, final=final_pop, doubling=doubling))
    
    plot(sol, label="α=$α", lw=2)
end

plot!(xlabel="Время t", ylabel="Популяция u", 
      title="Сравнение разных α")
savefig("parametric_comparison.png")

results_df = DataFrame(results)
println(results_df)
