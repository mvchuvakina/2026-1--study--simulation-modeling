# scripts/daisyworld-luminosity.jl - Влияние солнечной активности

using DrWatson
@quickactivate "project"

using Agents
using CairoMakie
using DataFrames
using Statistics

include(srcdir("daisyworld.jl"))

# Функции для подсчета
black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]

# Функция для средней температуры
temperature(model) = Statistics.mean(model.temperature)
mdata = [temperature, :solar_luminosity]

# Создаем модель со сценарием :ramp (солнечная активность меняется)
model = daisyworld(solar_luminosity = 1.0, scenario = :ramp)

# Запускаем симуляцию
println("🔄 Запуск симуляции со сценарием :ramp...")
agent_df, model_df = run!(model, 1000; adata = adata, mdata = mdata)

# Создаем составной график
figure = CairoMakie.Figure(size = (600, 600))

# График 1: Численность маргариток
ax1 = figure[1, 1] = Axis(figure, ylabel = "Количество маргариток")
blackl = lines!(ax1, agent_df[!, :time], agent_df[!, :count_black], color = :red)
whitel = lines!(ax1, agent_df[!, :time], agent_df[!, :count_white], color = :blue)
figure[1, 2] = Legend(figure, [blackl, whitel], ["Черные", "Белые"])

# График 2: Температура
ax2 = figure[2, 1] = Axis(figure, ylabel = "Средняя температура")
lines!(ax2, model_df[!, :time], model_df[!, :temperature], color = :red)

# График 3: Солнечная активность
ax3 = figure[3, 1] = Axis(figure, xlabel = "Время, шаги", ylabel = "Солнечная активность")
lines!(ax3, model_df[!, :time], model_df[!, :solar_luminosity], color = :red)

# Скрываем подписи на верхних графиках
for ax in (ax1, ax2)
    ax.xticklabelsvisible = false
end

# Сохраняем
save(plotsdir("daisy_luminosity.png"), figure)
println("✅ График сохранён: ", plotsdir("daisy_luminosity.png"))
