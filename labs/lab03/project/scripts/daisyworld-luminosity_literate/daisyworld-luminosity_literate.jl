using DrWatson
@quickactivate "project"

using Agents
using CairoMakie
using DataFrames
using Statistics

include(srcdir("daisyworld.jl"))

black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]

temperature(model) = Statistics.mean(model.temperature)

mdata = [temperature, :solar_luminosity]

println("="^60)
println("МОДЕЛЬ DAISYWORLD - ВЛИЯНИЕ СОЛНЕЧНОЙ АКТИВНОСТИ")
println("="^60)
println("\n🔄 Сценарий :ramp (циклическое изменение)")

model = daisyworld(solar_luminosity = 1.0, scenario = :ramp, seed=165)

println("   - Начальная солнечная активность: 1.0")
println("   - Сценарий: рост (200-400), затем спад (500-750)")
println("\n⏳ Запуск симуляции на 1000 шагов...")

agent_df, model_df = run!(model, 1000; adata = adata, mdata = mdata)

println("✅ Симуляция завершена!")

println("\n📊 Создание составного графика...")

figure = CairoMakie.Figure(size = (600, 600))

ax1 = figure[1, 1] = Axis(figure,
    ylabel = "Количество маргариток",
    title = "Динамика численности"
)

blackl = lines!(ax1, agent_df[!, :time], agent_df[!, :count_black],
    color = :red, linewidth = 2, label = "Черные")
whitel = lines!(ax1, agent_df[!, :time], agent_df[!, :count_white],
    color = :blue, linewidth = 2, label = "Белые")

figure[1, 2] = Legend(figure, [blackl, whitel], ["Черные", "Белые"])

ax2 = figure[2, 1] = Axis(figure,
    ylabel = "Средняя температура, °C",
    title = "Изменение температуры"
)
lines!(ax2, model_df[!, :time], model_df[!, :temperature],
    color = :red, linewidth = 2)

ax3 = figure[3, 1] = Axis(figure,
    xlabel = "Время, шаги модели",
    ylabel = "Солнечная активность",
    title = "Изменение солнечной активности"
)
lines!(ax3, model_df[!, :time], model_df[!, :solar_luminosity],
    color = :red, linewidth = 2)

for ax in (ax1, ax2)
    ax.xticklabelsvisible = false
end

save(plotsdir("daisy_luminosity_ramp.png"), figure)
println("✅ График сохранён: ", plotsdir("daisy_luminosity_ramp.png"))

println("\n🔄 Сценарий :change (линейный рост)")

model2 = daisyworld(solar_luminosity = 1.0, scenario = :change, seed=165)

println("   - Начальная солнечная активность: 1.0")
println("   - Сценарий: постоянный рост")
println("\n⏳ Запуск симуляции на 1000 шагов...")

agent_df2, model_df2 = run!(model2, 1000; adata = adata, mdata = mdata)

println("✅ Симуляция завершена!")

figure2 = CairoMakie.Figure(size = (600, 600))

ax1b = figure2[1, 1] = Axis(figure2,
    ylabel = "Количество маргариток",
    title = "Динамика численности (линейный рост)"
)

blackl2 = lines!(ax1b, agent_df2[!, :time], agent_df2[!, :count_black],
    color = :red, linewidth = 2, label = "Черные")
whitel2 = lines!(ax1b, agent_df2[!, :time], agent_df2[!, :count_white],
    color = :blue, linewidth = 2, label = "Белые")
figure2[1, 2] = Legend(figure2, [blackl2, whitel2], ["Черные", "Белые"])

ax2b = figure2[2, 1] = Axis(figure2, ylabel = "Средняя температура, °C")
lines!(ax2b, model_df2[!, :time], model_df2[!, :temperature],
    color = :red, linewidth = 2)

ax3b = figure2[3, 1] = Axis(figure2,
    xlabel = "Время, шаги модели",
    ylabel = "Солнечная активность"
)
lines!(ax3b, model_df2[!, :time], model_df2[!, :solar_luminosity],
    color = :red, linewidth = 2)

for ax in (ax1b, ax2b)
    ax.xticklabelsvisible = false
end

save(plotsdir("daisy_luminosity_change.png"), figure2)
println("✅ График сохранён: ", plotsdir("daisy_luminosity_change.png"))

println("\n📈 Сравнительный анализ сценариев:")
println("\nСценарий :ramp:")
println("   - Пик численности черных: ", maximum(agent_df[!, :count_black]))
println("   - Пик численности белых: ", maximum(agent_df[!, :count_white]))
println("   - Диапазон температур: ", round(minimum(model_df[!, :temperature]), digits=1),
    " - ", round(maximum(model_df[!, :temperature]), digits=1))

println("\nСценарий :change:")
println("   - Пик численности черных: ", maximum(agent_df2[!, :count_black]))
println("   - Пик численности белых: ", maximum(agent_df2[!, :count_white]))
println("   - Диапазон температур: ", round(minimum(model_df2[!, :temperature]), digits=1),
    " - ", round(maximum(model_df2[!, :temperature]), digits=1))

println("\n📌 Выводы:")
println("   - В сценарии :ramp система успевает адаптироваться к изменениям")
println("   - В сценарии :change при слишком высокой солнечной активности")
println("     маргаритки могут погибнуть (проверьте графики)")
println("\n" * "="^60)
