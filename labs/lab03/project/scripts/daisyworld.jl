# scripts/daisyworld.jl - Базовая визуализация модели Daisyworld

using DrWatson
@quickactivate "project"

using Agents
using CairoMakie
using Plots

# Подключаем файл с моделью из папки src
include(srcdir("daisyworld.jl"))

# Создаем модель с параметрами по умолчанию
model = daisyworld()

# Функция для определения цвета маргаритки
daisycolor(a::Daisy) = a.breed == :white ? :white : :black

# Настройки для визуализации
plotkwargs = (
    agent_color = daisycolor,
    agent_size = 20,
    agent_marker = '✩',  # символ звездочки для маргариток
    heatarray = :temperature,  # показываем температуру как тепловую карту
    heatkwargs = (colorrange = (-20, 60),)
)

# Визуализируем начальное состояние
println("Шаг 1: Начальное состояние")
plt1, _ = abmplot(model; plotkwargs...)
save(plotsdir("daisy_step001.png"), plt1)
println("✅ График сохранён: ", plotsdir("daisy_step001.png"))

# Делаем 5 шагов модели
step!(model, 5)
println("\nШаг 5: После 5 итераций")
plt2, _ = abmplot(model; plotkwargs...)
save(plotsdir("daisy_step005.png"), plt2)
println("✅ График сохранён: ", plotsdir("daisy_step005.png"))

# Делаем еще 40 шагов (всего 45)
step!(model, 40)
println("\nШаг 45: После 45 итераций")
plt3, _ = abmplot(model; plotkwargs...)
save(plotsdir("daisy_step045.png"), plt3)
println("✅ График сохранён: ", plotsdir("daisy_step045.png"))

println("\n🎉 Базовая визуализация завершена!")
