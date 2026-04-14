# # Моделирование обедающих философов на сетях Петри
# 
# **Цель:** Исследовать проблему взаимной блокировки (deadlock) в задаче
# «Обедающие философы» с использованием аппарата сетей Петри.
# 
# **Автор:** Чувакина Мария Владимировна
# **Дата:** 2026-04-14
# 
# ## Теоретическое введение
# 
# Задача «Обедающие философы» была сформулирована Эдгером Дейкстрой в 1965 году
# как иллюстрация проблемы синхронизации в параллельных системах.
# 
# ### Классическая постановка
# 
# - За круглым столом сидят **N философов**
# - Перед каждым философом — тарелка с едой
# - Между каждыми двумя соседними философами — **одна вилка**
# - Чтобы поесть, философу нужны **две вилки** (левая и правая)
# - После еды философ кладёт вилки обратно
# 
# ### Проблема взаимной блокировки (deadlock)
# 
# Если все философы одновременно возьмут левую вилку, каждый будет ждать правую,
# которая уже занята соседом. В результате никто не может поесть — система замирает.
# 
# ## Подключение пакетов

using DrWatson
@quickactivate

using DataFrames, CSV, Plots
include(srcdir("DiningPhilosophers.jl"))
using .DiningPhilosophers

# ## Параметры модели
# 
# - `N = 5` — количество философов
# - `tmax = 50.0` — время симуляции

N = 5
tmax = 50.0

# ## 1. Классическая сеть (без арбитра)
# 
# В классической сети нет ограничений на количество одновременно
# eat философов, что приводит к deadlock.

println("="^60)
println("КЛАССИЧЕСКАЯ СЕТЬ (без арбитра)")
println("="^60)

# Построение сети
net_classic, u0_classic, _ = build_classical_network(N)

# Стохастическая симуляция
df_classic = simulate_stochastic(net_classic, u0_classic, tmax)

# Сохранение данных
CSV.write(datadir("dining_classic.csv"), df_classic)

# Проверка deadlock
dead = detect_deadlock(df_classic, net_classic)
println("Deadlock обнаружен: $dead")

# Визуализация
plot_classic = plot_marking_evolution(df_classic, N)
savefig(plotsdir("classic_simulation.png"))

# ## 2. Сеть с арбитром
# 
# Добавление арбитра (позиции с N-1 фишками) ограничивает количество
# одновременно eat философов до N-1, что предотвращает deadlock.

println()
println("="^60)
println("СЕТЬ С АРБИТРОМ")
println("="^60)

# Построение сети
net_arb, u0_arb, _ = build_arbiter_network(N)

# Стохастическая симуляция
df_arb = simulate_stochastic(net_arb, u0_arb, tmax)

# Сохранение данных
CSV.write(datadir("dining_arbiter.csv"), df_arb)

# Проверка deadlock
dead_arb = detect_deadlock(df_arb, net_arb)
println("Deadlock обнаружен: $dead_arb")

# Визуализация
plot_arb = plot_marking_evolution(df_arb, N)
savefig(plotsdir("arbiter_simulation.png"))

# ## Выводы
# 
# - Классическая сеть приводит к deadlock
# - Сеть с арбитром предотвращает deadlock

println()
println("="^60)
println("ЭКСПЕРИМЕНТ ЗАВЕРШЁН")
println("="^60)
