using DrWatson
@quickactivate "project"

using DataFrames, CSV, Plots, Statistics

# Загрузка данных из CSV
println("Загрузка данных из beta_scan_all.csv...")
df = CSV.read(datadir("beta_scan_all.csv"), DataFrame)

# Усреднение по повторам
grouped = combine(
    groupby(df, [:beta]),
    :peak => mean => :mean_peak,
    :final_inf => mean => :mean_final_inf,
    :deaths => mean => :mean_deaths,
    :final_rec => mean => :mean_final_rec,
)

println("Построение комплексного графика...")
# Создание комплексного графика с тремя панелями
p1 = plot(grouped.beta, grouped.mean_peak, 
          label = "Пик эпидемии", 
          marker = :circle, 
          linewidth = 2,
          title = "Динамика эпидемии",
          xlabel = "Коэффициент заразности β", 
          ylabel = "Доля инфицированных",
          legend = :topleft)
plot!(p1, grouped.beta, grouped.mean_final_inf, 
      label = "Конечная доля инфицированных", 
      marker = :square, 
      linewidth = 2)

p2 = plot(grouped.beta, grouped.mean_deaths ./ 3000, 
          label = "Доля умерших", 
          marker = :diamond, 
          linewidth = 2,
          xlabel = "Коэффициент заразности β", 
          ylabel = "Доля умерших",
          legend = :topleft)

p3 = plot(grouped.beta, grouped.mean_final_rec, 
          label = "Доля переболевших", 
          marker = :star, 
          linewidth = 2,
          xlabel = "Коэффициент заразности β", 
          ylabel = "Доля переболевших",
          legend = :topleft)

# Объединение графиков
final_plot = plot(p1, p2, p3, layout = (3, 1), size = (800, 900))
savefig(final_plot, plotsdir("comprehensive_analysis.png"))

println("\n=== Сводная статистика ===")
println("\nЗависимость от β:")
for row in eachrow(grouped)
    println("β = $(row.beta): пик = $(round(row.mean_peak*100, digits=1))%, умерших = $(round(row.mean_deaths, digits=0))")
end

println("\nГрафик сохранён в: ", plotsdir("comprehensive_analysis.png"))
