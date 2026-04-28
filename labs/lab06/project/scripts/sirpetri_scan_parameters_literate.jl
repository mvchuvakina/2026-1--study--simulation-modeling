# # Анимация детерминированной динамики SIR
# 
# **Цель:** Создать анимацию, наглядно демонстрирующую распространение
# эпидемии во времени.
# 
# **Автор:** Чувакина Мария Владимировна
# **Дата:** 2026-04-21
# 
# ## Теоретическое введение
# 
# Анимация показывает, как меняется количество людей в каждой из трёх групп
# (S, I, R) с течением времени. На первых кадрах I растёт, S падает.
# В момент пика I достигает максимума, затем снижается, а R растёт.
# 
# ## Параметры анимации

using DrWatson
@quickactivate

using Plots
using DataFrames

include(srcdir("SIRPetri.jl"))
using .SIRPetri

β = 0.3
γ = 0.1
tmax = 100.0

println("="^60)
println("АНИМАЦИЯ ДИНАМИКИ SIR")
println("="^60)
println("β = $β, γ = $γ, tmax = $tmax")
println()

# ## Получение данных

net, u0, states = build_sir_network(β, γ)
df = simulate_deterministic(net, u0, (0.0, tmax), saveat = 0.2, rates = [β, γ])

# ## Создание анимации
# 
# Каждый кадр — столбчатая диаграмма численности S, I, R.

anim = @animate for i in 1:length(df.time)
    bar(
        ["S", "I", "R"],
        [df.S[i], df.I[i], df.R[i]],
        ylims = (0, 1000),
        title = "Время = $(round(df.time[i], digits=1))",
        ylabel = "Численность",
        color = [:blue, :red, :green],
        legend = false,
    )
end

# ## Сохранение анимации

gif(anim, plotsdir("sir_animation.gif"), fps = 10)
println("Анимация сохранена: plots/sir_animation.gif")

# ## Выводы
# 
# Анимация наглядно показывает:
# - Рост числа инфицированных в начале эпидемии
# - Пик заболеваемости
# - Последующее снижение I и рост R

println()
println("="^60)
println("АНИМАЦИЯ ЗАВЕРШЕНА")
println("="^60)
