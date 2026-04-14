# # Параметрическое исследование: влияние времени симуляции на deadlock
# 
# **Цель:** Исследовать, как время симуляции tmax влияет на обнаружение
# deadlock в классической сети Петри для задачи «Обедающие философы».
# 
# **Автор:** Чувакина Мария Владимировна
# **Дата:** 2026-04-14
# 
# ## Теоретическое введение
# 
# В классической постановке задачи deadlock возникает случайным образом
# в зависимости от порядка срабатывания переходов. Чем больше время
# симуляции, тем выше вероятность обнаружить deadlock.
# 
# ### Почему deadlock возникает не всегда?
# 
# Алгоритм Гиллеспи вносит случайность в последовательность срабатывания
# переходов. При разных seed deadlock может наступить в разное время или
# не наступить вовсе за ограниченное время симуляции.
# 
# ### Цель исследования
# 
# Определить, как вероятность обнаружения deadlock зависит от времени
# симуляции tmax.
# 
# ## Подключение пакетов

using DrWatson
@quickactivate

using DataFrames, CSV, Plots
include(srcdir("DiningPhilosophers.jl"))
using .DiningPhilosophers

# ## Параметры исследования
# 
# - `N = 5` — количество философов (фиксировано)
# - `tmax_values` — массив значений времени симуляции
# - `replicates = 5` — количество повторных прогонов для каждого tmax

N = 5
tmax_values = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 80.0, 100.0]
replicates = 5

results = []

println("="^60)
println("ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ")
println("Влияние времени симуляции tmax на deadlock")
println("="^60)
println("N = $N, replicates = $replicates")
println()

# ## Запуск экспериментов
# 
# Для каждого значения tmax запускаем `replicates` симуляций
# и подсчитываем, в скольких из них обнаружен deadlock.

for tmax in tmax_values
    println("Исследование tmax = $tmax...")
    deadlock_count = 0
    
    for rep in 1:replicates
        net, u0, _ = build_classical_network(N)
        df = simulate_stochastic(net, u0, tmax)
        dead = detect_deadlock(df, net)
        
        if dead
            deadlock_count += 1
        end
    end
    
    deadlock_prob = deadlock_count / replicates
    push!(results, (tmax=tmax, deadlock_prob=deadlock_prob))
    println("  Вероятность deadlock: $deadlock_prob ($deadlock_count/$replicates)")
end

# ## Сохранение результатов

df_results = DataFrame(results)
CSV.write(datadir("parametric_tmax_results.csv"), df_results)

# ## Визуализация
# 
# Строим график зависимости вероятности deadlock от времени симуляции.

plot(df_results.tmax, df_results.deadlock_prob,
     marker=:circle, linewidth=2, markersize=8,
     xlabel="Время симуляции tmax",
     ylabel="Вероятность deadlock",
     title="Зависимость вероятности deadlock от времени симуляции",
     ylims=(0, 1))
savefig(plotsdir("parametric_tmax.png"))

# ## Анализ результатов

println()
println("="^60)
println("РЕЗУЛЬТАТЫ")
println("="^60)

for row in eachrow(df_results)
    println("tmax = $(row.tmax): вероятность deadlock = $(round(row.deadlock_prob * 100, digits=1))%")
end

# ## Выводы
# 
# - При малых tmax (10-20) deadlock может не обнаружиться
# - При tmax = 50 вероятность deadlock близка к 100%
# - С увеличением времени симуляции вероятность обнаружения deadlock стремится к 1
# - Это подтверждает, что deadlock в классической сети — неизбежное явление

println()
println("Вывод: с увеличением времени симуляции вероятность")
println("обнаружения deadlock стремится к 1.")
println()
println("Результаты сохранены:")
println("  - data/parametric_tmax_results.csv")
println("  - plots/parametric_tmax.png")
