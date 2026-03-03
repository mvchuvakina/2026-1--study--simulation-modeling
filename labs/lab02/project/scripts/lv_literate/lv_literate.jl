using DrWatson
@quickactivate "project"

using DifferentialEquations
using DataFrames
using StatsPlots
using LaTeXStrings
using Plots
using Statistics

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

function lotka_volterra!(du, u, p, t)
    x, y = u
    α, β, δ, γ = p
    @inbounds begin
        du[1] = α*x - β*x*y  # dx/dt
        du[2] = δ*x*y - γ*y   # dy/dt
    end
    nothing
end

p_lv = [0.1,   # α: скорость размножения жертв
        0.02,  # β: скорость поедания жертв
        0.01,  # δ: коэффициент конверсии
        0.3]   # γ: смертность хищников

u0_lv = [40.0, 9.0]  # [жертвы, хищники]

tspan_lv = (0.0, 200.0)  # длительность симуляции
dt_lv = 0.1

prob_lv = ODEProblem(lotka_volterra!, u0_lv, tspan_lv, p_lv)
sol_lv = solve(prob_lv, Tsit5(), dt = dt_lv, saveat=0.5)

df_lv = DataFrame()
df_lv[!, :t] = sol_lv.t
df_lv[!, :prey] = [u[1] for u in sol_lv.u]
df_lv[!, :predator] = [u[2] for u in sol_lv.u]

x_star = p_lv[4] / p_lv[3]  # x* = γ/δ
y_star = p_lv[1] / p_lv[2]  # y* = α/β

println("📊 Модель Лотки-Вольтерры")
println("="^60)
println("Параметры модели:")
println("  α = ", p_lv[1])
println("  β = ", p_lv[2])
println("  δ = ", p_lv[3])
println("  γ = ", p_lv[4])
println("Стационарные точки:")
println("  x* = γ/δ = ", round(x_star, digits=2))
println("  y* = α/β = ", round(y_star, digits=2))

plt1 = plot(df_lv.t, [df_lv.prey df_lv.predator],
    label=[L"Жертвы (x)" L"Хищники (y)"],
    xlabel="Время",
    ylabel="Популяция",
    title="Модель Лотки-Вольтерры: Динамика популяций",
    linewidth=2,
    legend=:topright,
    grid=true,
    size=(900, 500),
    color=[:green :red])

hline!(plt1, [x_star], color=:green, linestyle=:dash, alpha=0.5, label="x* (равновесие жертв)")
hline!(plt1, [y_star], color=:red, linestyle=:dash, alpha=0.5, label="y* (равновесие хищников)")

savefig(plt1, plotsdir(script_name, "lv_dynamics.png"))

println("\n✅ Графики сохранены")
