# # Анимация сети Петри для задачи «Обедающие философы»
# 
# **Цель:** Создать анимацию, наглядно демонстрирующую перемещение фишек
# в сети Петри для задачи «Обедающие философы».
# 
# **Автор:** Чувакина Мария Владимировна
# **Дата:** 2026-04-14
# 
# ## Подключение пакетов

using DrWatson
@quickactivate

using Plots, Random
include(srcdir("DiningPhilosophers.jl"))
using .DiningPhilosophers

# ## Параметры анимации
# 
# - `N = 3` — количество философов (для упрощения визуализации)
# - `tmax = 30.0` — время симуляции

N = 3
tmax = 30.0

# ## Построение классической сети
# 
# Используем классическую сеть для демонстрации deadlock.

net, u0, names = build_classical_network(N)

# ## Стохастическая симуляция
# 
# Устанавливаем seed для воспроизводимости результатов.

Random.seed!(123)
df = simulate_stochastic(net, u0, tmax)

# ## Создание анимации
# 
# Анимация показывает, как меняется маркировка сети во времени.
# Каждый кадр — столбчатая диаграмма текущей маркировки.

anim = @animate for row in eachrow(df)
    u = [row[col] for col in propertynames(row) if col != :time]
    bar(1:length(u), u,
        legend=false,
        ylims=(0, maximum(u0) + 1),
        xlabel="Позиция",
        ylabel="Фишки",
        title="Время = $(round(row.time, digits=2))")
    xticks!(1:length(u), string.(names), rotation=45)
end

# ## Сохранение анимации
# 
# Сохраняем анимацию в формате GIF с частотой 5 кадров в секунду.

gif(anim, plotsdir("philosophers_simulation.gif"), fps=5)
println("Анимация сохранена: plots/philosophers_simulation.gif")
