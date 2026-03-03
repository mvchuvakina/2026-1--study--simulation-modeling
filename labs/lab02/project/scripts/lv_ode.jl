using DrWatson
@quickactivate "project"

using DifferentialEquations
using DataFrames
using Plots
using LaTeXStrings

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

# Модель Лотки-Вольтерры (хищник-жертва)
# dx/dt = α*x - β*x*y
# dy/dt = δ*x*y - γ*y

function lotka_volterra!(du, u, p, t)
    x, y = u
    α, β, δ, γ = p
    du[1] = α*x - β*x*y  # жертвы
    du[2] = δ*x*y - γ*y   # хищники
    nothing
end

# Параметры модели
p = [0.1,   # α - скорость размножения жертв
     0.02,  # β - скорость поедания жертв
     0.01,  # δ - коэффициент конверсии
     0.3]   # γ - смертность хищников

# Начальные условия
u0 = [40.0, 9.0]  # [жертвы, хищники]

# Временной интервал
tspan = (0.0, 200.0)

# Создание и решение задачи
prob = ODEProblem(lotka_volterra!, u0, tspan, p)
sol = solve(prob, Tsit5(), saveat=0.5)

# Подготовка данных
df = DataFrame(t=sol.t, prey=[u[1] for u in sol.u], predator=[u[2] for u in sol.u])

# Стационарные точки
x_star = p[4] / p[3]  # x* = γ/δ
y_star = p[1] / p[2]  # y* = α/β

println("📊 Модель Лотки-Вольтерры (базовая версия)")
println("="^60)
println("Параметры:")
println("  α = ", p[1])
println("  β = ", p[2])
println("  δ = ", p[3])
println("  γ = ", p[4])
println("Стационарные точки:")
println("  x* (жертвы) = ", round(x_star, digits=2))
println("  y* (хищники) = ", round(y_star, digits=2))

# Построение графика динамики
plt = plot(df.t, [df.prey df.predator],
    label=[L"Жертвы (x)" L"Хищники (y)"],
    xlabel="Время",
    ylabel="Популяция",
    title="Модель Лотки-Вольтерры",
    linewidth=2,
    legend=:topright,
    grid=true,
    color=[:green :red])

# Добавление стационарных уровней
hline!(plt, [x_star], color=:green, linestyle=:dash, alpha=0.5, label="x* (равновесие жертв)")
hline!(plt, [y_star], color=:red, linestyle=:dash, alpha=0.5, label="y* (равновесие хищников)")

savefig(plt, plotsdir(script_name, "lv_dynamics.png"))
println("\n✅ График сохранён: ", plotsdir(script_name, "lv_dynamics.png"))
