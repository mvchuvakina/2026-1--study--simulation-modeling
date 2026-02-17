# # Модель экспоненциального роста
#
# ## Введение
# Экспоненциальный рост описывается уравнением:
#
# $$ \frac{du}{dt} = \alpha u, \quad u(0) = u_0 $$

# ## Подготовка окружения
using DrWatson
@quickactivate "project"
using DifferentialEquations
using Plots
using DataFrames
using JLD2

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

# ## Определение модели
function exponential_growth!(du, u, p, t)
    α = p
    du[1] = α * u[1]
end

# ## Параметры
u0 = [1.0]      # начальная популяция
α = 0.3         # скорость роста
tspan = (0.0, 10.0)  # интервал времени

# ## Решение
prob = ODEProblem(exponential_growth!, u0, tspan, α)
sol = solve(prob, Tsit5(), saveat=0.1)

# ## График
plot(sol, label="u(t)", xlabel="Время t", ylabel="Популяция u",
     title="Экспоненциальный рост (α = $α)", lw=2, legend=:topleft)
savefig(plotsdir(script_name, "exponential_growth_α=$α.png"))

# ## Анализ
df = DataFrame(t=sol.t, u=first.(sol.u))
println("Первые 5 строк:")
println(first(df, 5))

doubling_time = log(2) / α
println("Время удвоения: ", round(doubling_time; digits=2))

# ## Сохранение
@save datadir(script_name, "results.jld2") df
