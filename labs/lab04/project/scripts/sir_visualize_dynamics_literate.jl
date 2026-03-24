# # Сводная визуализация результатов
# 
# **Цель:** Загрузить результаты сканирования β и создать комплексный график
# для итогового отчёта.

using DrWatson
@quickactivate

using DataFrames, CSV, Plots, Statistics

# ## Загрузка данных

println("="^60)
println("СВОДНАЯ ВИЗУАЛИЗАЦИЯ")
println("="^60)

df = CSV.read(datadir("beta_scan_all.csv"), DataFrame)

# ## Усреднение по повторам

grouped = combine(
    groupby(df, [:beta]),
    :peak => mean => :mean_peak,
    :final_inf => mean => :mean_final_inf,
    :deaths => mean => :mean_deaths,
)

# ## Создание комплексного графика

# Панель 1: Пик и конечная доля
p1 = plot(grouped.beta, grouped.mean_peak, 
          label = "Пик эпидемии", 
          marker = :circle, 
          linewidth = 2,
          title = "Динамика эпидемии",
          xlabel = "Коэффициент заразности β", 
          ylabel = "Доля инфицированных",
          legend = :topleft)
plot!(p1, grouped.beta, grouped.mean_final_inf, 
      label = "Конечная доля", 
      marker = :square, 
      linewidth = 2)

# Панель 2: Доля умерших
p2 = plot(grouped.beta, grouped.mean_deaths ./ 3000, 
          label = "Доля умерших", 
          marker = :diamond, 
          linewidth = 2,
          xlabel = "Коэффициент заразности β", 
          ylabel = "Доля умерших",
          legend = :topleft)

# Объединение
final_plot = plot(p1, p2, layout = (2, 1), size = (800, 600))
savefig(final_plot, plotsdir("comprehensive_analysis.png"))

# ## Вывод статистики

println("\nСводная статистика:")
println("\nβ\tПик (%)\tУмершие")
println("-"^30)
for row in eachrow(grouped)
    println("$(row.beta)\t$(round(row.mean_peak*100, digits=1))\t$(round(row.mean_deaths, digits=0))")
end

println("\n✅ Визуализация завершена!")
println("График сохранён в: ", plotsdir("comprehensive_analysis.png"))
