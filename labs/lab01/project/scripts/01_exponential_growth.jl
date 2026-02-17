# Модель экспоненциального роста
using DrWatson
@quickactivate "project"
using DifferentialEquations
using Plots
using DataFrames

function exponential_growth!(du, u, p, t)
    α = p
    du[1] = α * u[1]
end

u0 = [1.0]
α = 0.3
tspan = (0.0, 10.0)

prob = ODEProblem(exponential_growth!, u0, tspan, α)
sol = solve(prob, Tsit5(), saveat=0.1)

plot(sol, label="u(t)", xlabel="Время t", ylabel="Популяция u",
     title="Экспоненциальный рост (α = $α)", lw=2, legend=:topleft)
savefig("exponential_growth_α=$α.png")

df = DataFrame(t=sol.t, u=first.(sol.u))
println("Первые 5 строк:")
println(first(df, 5))

doubling_time = log(2) / α
println("Время удвоения: ", round(doubling_time; digits=2))
