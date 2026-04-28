# # Итоговый отчёт: сравнение детерминированной и стохастической динамики
# 
# **Цель:** Сравнить результаты детерминированного и стохастического
# моделирования модели SIR.
# 
# **Автор:** Чувакина Мария Владимировна
# **Дата:** 2026-04-21
# 
# ## Теоретическое введение
# 
# - **Детерминированная модель** (ОДУ) даёт плавную усреднённую динамику
# - **Стохастическая модель** (алгоритм Гиллеспи) учитывает случайные флуктуации
# 
# При большом размере популяции (990 восприимчивых) стохастическая траектория
# близка к детерминированной.

using DrWatson
@quickactivate

using DataFrames, CSV, Plots

println("="^60)
println("ИТОГОВЫЙ ОТЧЁТ")
println("="^60)

# ## Загрузка данных

df_det = CSV.read(datadir("sir_det.csv"), DataFrame)
df_stoch = CSV.read(datadir("sir_stoch.csv"), DataFrame)
df_scan = CSV.read(datadir("sir_scan.csv"), DataFrame)

# ## 1. Сравнение детерминированной и стохастической динамики
# 
# График показывает динамику инфицированных I(t) для обоих типов симуляции.

p1 = plot(
    df_det.time,
    df_det.I,
    label = "Deterministic I",
    xlabel = "Time",
    ylabel = "Infected",
    title = "Comparison: Deterministic vs Stochastic",
    linewidth = 2,
    color = :blue,
)
plot!(p1, df_stoch.time, df_stoch.I, label = "Stochastic I", linewidth = 1, color = :red, alpha = 0.7)
savefig(plotsdir("comparison.png"))
println("  График сравнения: plots/comparison.png")

# ## 2. Зависимость пика I от β
# 
# График чувствительности показывает, как изменение β влияет на пик эпидемии.

p2 = plot(
    df_scan.β,
    df_scan.peak_I,
    marker = :circle,
    xlabel = "β",
    ylabel = "Peak I",
    title = "Sensitivity: Peak I vs β",
    linewidth = 2,
)
savefig(plotsdir("sensitivity.png"))
println("  График чувствительности: plots/sensitivity.png")

# ## Выводы
# 
# 1. **Сравнение методов:**
#    - Детерминированная и стохастическая динамики качественно совпадают
#    - Стохастическая кривая имеет заметные флуктуации
# 
# 2. **Чувствительность к β:**
#    - При β < 0.2 эпидемия не возникает (пик I ≈ 0)
#    - При β = 0.3 пик I ≈ 400
#    - При β = 0.5 пик I ≈ 700
#    - При β > 0.6 пик I достигает насыщения

println()
println("="^60)
println("ОТЧЁТ ЗАВЕРШЁН")
println("="^60)
