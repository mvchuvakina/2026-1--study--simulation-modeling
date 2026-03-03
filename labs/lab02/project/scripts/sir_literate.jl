# # Модель SIR (Susceptible-Infectious-Recovered)
#
# **Цель работы:** Исследовать динамику эпидемиологического процесса
# с помощью компартментальной модели SIR.
#
# ## Описание модели
#
# Модель SIR делит популяцию на три группы:
# - **S** (Susceptible) — восприимчивые к инфекции
# - **I** (Infectious) — заразные больные
# - **R** (Recovered) — выздоровевшие с иммунитетом
#
# ### Система дифференциальных уравнений:
#
# $$
# \begin{cases}
# \frac{dS}{dt} = -\beta \cdot c \cdot \frac{I}{N} \cdot S \\
# \frac{dI}{dt} = \beta \cdot c \cdot \frac{I}{N} \cdot S - \gamma I \\
# \frac{dR}{dt} = \gamma I
# \end{cases}
# $$
#
# Где:
# - $\beta$ — вероятность передачи инфекции при контакте
# - $c$ — среднее число контактов в день
# - $\gamma$ — скорость выздоровления ($1/\gamma$ — средняя длительность болезни)
# - $N = S + I + R$ — общая численность популяции
#
# Базовое репродуктивное число:
# $$R_0 = \frac{c \cdot \beta}{\gamma}$$
#
# ## Инициализация проекта и загрузка пакетов

using DrWatson
@quickactivate "project"

using DifferentialEquations
using DataFrames
using StatsPlots
using LaTeXStrings
using Plots
using BenchmarkTools

# Создание директорий для сохранения результатов
script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

# ## Определение модели
#
# Функция, описывающая правые части системы ДУ

function sir_ode!(du, u, p, t)
    (S, I, R) = u
    (β, c, γ) = p
    N = S + I + R
    @inbounds begin
        du[1] = -β * c * I / N * S   # dS/dt
        du[2] = β * c * I / N * S - γ * I  # dI/dt
        du[3] = γ * I                  # dR/dt
    end
    nothing
end

# ## Задание параметров модели

δt = 0.1              # шаг интегрирования
tmax = 40.0           # максимальное время моделирования (дни)
tspan = (0.0, tmax)   # интервал времени

# Начальные условия
u0 = [990.0, 10.0, 0.0]  # [S0, I0, R0]

# Параметры модели
p = [0.05, 10.0, 0.25]    # [β, c, γ]

# Расчет базового репродуктивного числа
R0 = (p[2] * p[1]) / p[3]  # R0 = (c * β) / γ

println("📊 Параметры модели SIR:")
println("   β (вероятность заражения) = ", p[1])
println("   c (среднее число контактов) = ", p[2])
println("   γ (скорость выздоровления) = ", p[3])
println("   R0 = c * β / γ = ", round(R0, digits=3))
println("   Средняя продолжительность болезни = ", round(1/p[3], digits=2), " дней")
println("   Начальные условия: S0 = ", u0[1], " I0 = ", u0[2], " R0 = ", u0[3])

# ## Решение системы ДУ

prob_ode = ODEProblem(sir_ode!, u0, tspan, p)
sol_ode = solve(prob_ode, dt = δt)

# ## Обработка результатов

df_ode = DataFrame(Tables.table(sol_ode'))
rename!(df_ode, ["S", "I", "R"])
df_ode[!, :t] = sol_ode.t
df_ode[!, :N] = df_ode.S + df_ode.I + df_ode.R

# ## Визуализация результатов

# ### 1. Динамика всех трех групп

plt1 = @df df_ode plot(:t, [:S :I :R],
    label=[L"S(t)" L"I(t)" L"R(t)"],
    xlabel="Время, дни",
    ylabel="Количество людей",
    title="Модель SIR: Динамика эпидемии",
    linewidth=2,
    legend=:right,
    grid=true,
    size=(800, 500))

# Добавление аннотации с параметрами
annotate!(plt1, maximum(df_ode.t) * 0.7, maximum(df_ode.N) * 0.8,
    text("Параметры:\nβ = $(p[1])\nc = $(p[2])\nγ = $(p[3])\nR0 = $(round(R0, digits=2))", 8, :left))

savefig(plt1, plotsdir(script_name, "sir_main.png"))

println("\n✅ Графики сохранены в каталоге: ", plotsdir(script_name))
