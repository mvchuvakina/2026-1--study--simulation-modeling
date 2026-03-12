# scripts/daisyworld-count.jl - Анализ численности маргариток

using DrWatson
@quickactivate "project"

using Agents
using CairoMakie
using DataFrames

include(srcdir("daisyworld.jl"))

# Функции для подсчета черных и белых маргариток
black(a) = a.breed == :black
white(a) = a.breed == :white

# Данные для сбора
adata = [(black, count), (white, count)]

# Создаем модель
model = daisyworld(solar_luminosity = 1.0)

# Запускаем модель на 1000 шагов и собираем данные
println("🔄 Запуск симуляции на 1000 шагов...")
agent_df, model_df = run!(model, 1000; adata = adata)

# Визуализация
figure = Figure(size = (600, 400))
ax = Axis(figure[1, 1], xlabel = "Время, шаги", ylabel = "Количество маргариток")

# Линии для черных и белых маргариток
blackl = lines!(ax, agent_df[!, :time], agent_df[!, :count_black], color = :black)
whitel = lines!(ax, agent_df[!, :time], agent_df[!, :count_white], color = :orange)

# Добавляем легенду
Legend(figure[1, 2], [blackl, whitel], ["Черные маргаритки", "Белые маргаритки"])

# Сохраняем график
save(plotsdir("daisy_count.png"), figure)
println("✅ График сохранён: ", plotsdir("daisy_count.png"))
