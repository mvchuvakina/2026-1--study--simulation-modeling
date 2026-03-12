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

println("="^60)
println("МОДЕЛЬ DAISYWORLD - АНАЛИЗ ЧИСЛЕННОСТИ")
println("="^60)

model = daisyworld(solar_luminosity = 1.0, seed=165)
println("\n🔄 Создана модель Daisyworld")
println("   - Начальная солнечная активность: 1.0")
println("   - Начальная доля черных: 20%")
println("   - Начальная доля белых: 20%")

println("\n⏳ Запуск симуляции на 1000 шагов...")
println("   (это может занять некоторое время)")
agent_df, model_df = run!(model, 1000; adata = adata)

println("✅ Симуляция завершена!")
println("   - Собрано строк данных: ", nrow(agent_df))

println("\n📊 Создание графика численности...")

figure = Figure(size = (600, 400))
ax = Axis(figure[1, 1],
    xlabel = "Время, шаги модели",
    ylabel = "Количество маргариток",
    title = "Динамика численности маргариток в модели Daisyworld"
)

blackl = lines!(ax, agent_df[!, :time], agent_df[!, :count_black],
    color = :black,
    linewidth = 2,
    label = "Черные маргаритки"
)

whitel = lines!(ax, agent_df[!, :time], agent_df[!, :count_white],
    color = :orange,
    linewidth = 2,
    label = "Белые маргаритки"
)

Legend(figure[1, 2], [blackl, whitel], ["Черные", "Белые"])

save(plotsdir("daisy_count.png"), figure)
println("✅ График сохранён: ", plotsdir("daisy_count.png"))

println("\n📈 Анализ результатов:")
println("   - Средняя численность черных: ", round(mean(agent_df[!, :count_black]), digits=1))
println("   - Средняя численность белых: ", round(mean(agent_df[!, :count_white]), digits=1))
println("   - Максимальная численность черных: ", maximum(agent_df[!, :count_black]))
println("   - Максимальная численность белых: ", maximum(agent_df[!, :count_white]))
println("   - Минимальная численность черных: ", minimum(agent_df[!, :count_black]))
println("   - Минимальная численность белых: ", minimum(agent_df[!, :count_white]))

println("\n📌 Наблюдения:")
println("   - Видны ли колебания численности?")
println("   - Какой вид преобладает?")
println("   - Есть ли корреляция между численностью черных и белых?")
println("\n" * "="^60)
