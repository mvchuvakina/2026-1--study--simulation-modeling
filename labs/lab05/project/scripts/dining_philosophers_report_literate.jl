# # Итоговый отчёт: Сравнение классической сети и сети с арбитром
# 
# **Цель:** Сравнить динамику «едящих» философов в классической сети
# и в сети с арбитром.
# 
# **Автор:** Чувакина Мария Владимировна
# **Дата:** 2026-04-14
# 
# ## Подключение пакетов

using DrWatson
@quickactivate

using DataFrames, CSV, Plots

# ## Загрузка данных
# 
# Загружаем результаты симуляций, сохранённые в предыдущих экспериментах.

df_classic = CSV.read(datadir("dining_classic.csv"), DataFrame)
df_arbiter = CSV.read(datadir("dining_arbiter.csv"), DataFrame)
N = 5

# ## Извлечение данных о состоянии «Ест»
# 
# Столбцы `Eat_1`, ..., `Eat_N` показывают, ест ли соответствующий философ.

eat_cols = [Symbol("Eat_$i") for i in 1:N]

# ## График для классической сети
# 
# В классической сети через некоторое время все Eat_i становятся нулевыми
# — это и есть deadlock.

p1 = plot(df_classic.time, Matrix(df_classic[:, eat_cols]),
          label=["Ф $i" for i in 1:N],
          xlabel="Время", ylabel="Ест (1/0)",
          title="Классическая сеть", linewidth=2)

# ## График для сети с арбитром
# 
# В сети с арбитром Eat_i колеблются, всегда есть хотя бы один философ,
# который ест — deadlock отсутствует.

p2 = plot(df_arbiter.time, Matrix(df_arbiter[:, eat_cols]),
          label=["Ф $i" for i in 1:N],
          xlabel="Время", ylabel="Ест (1/0)",
          title="Сеть с арбитром", linewidth=2)

# ## Объединение графиков

p_final = plot(p1, p2, layout=(2,1), size=(800, 600))
savefig(plotsdir("final_report.png"))

# ## Выводы
# 
# - Классическая сеть: deadlock наступает через некоторое время
# - Сеть с арбитром: deadlock отсутствует, философы едят по очереди

println("График сохранён: plots/final_report.png")
