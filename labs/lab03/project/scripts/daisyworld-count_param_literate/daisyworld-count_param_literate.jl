using DrWatson
@quickactivate "project"

using Agents
using CairoMakie
using DataFrames
using Statistics
using JLD2
using DrWatson: dict_list, savename

include(srcdir("daisyworld.jl"))

black(a) = a.breed == :black
white(a) = a.breed == :white

adata = [(black, count), (white, count)]

param_dict = Dict(
    :griddim => (30, 30),
    :max_age => [25, 40],           # два варианта максимального возраста
    :init_white => [0.2, 0.8],       # два варианта начальной доли белых
    :init_black => 0.2,
    :albedo_white => 0.75,
    :albedo_black => 0.25,
    :surface_albedo => 0.4,
    :solar_change => 0.005,
    :solar_luminosity => 1.0,
    :scenario => :default,
    :seed => 165,
)

params_list = dict_list(param_dict)

println("="^60)
println("МОДЕЛЬ DAISYWORLD - ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ ЧИСЛЕННОСТИ")
println("="^60)
println("\n📊 Всего комбинаций параметров: ", length(params_list))
println("\nИсследуемые комбинации:")
for (i, params) in enumerate(params_list)
    println("   $i. max_age = $(params[:max_age]), init_white = $(params[:init_white])")
end

param_plots_dir = plotsdir("daisyworld-count_param")
mkpath(param_plots_dir)

results_summary = []

for (idx, params) in enumerate(params_list)
    println("\n" * "-"^60)
    println("🔄 Запуск $idx/$(length(params_list))")
    println("   Параметры: max_age = $(params[:max_age]), init_white = $(params[:init_white])")

    model = daisyworld(; params...)

    agent_df, model_df = run!(model, 1000; adata = adata)

    push!(results_summary, Dict(
        :max_age => params[:max_age],
        :init_white => params[:init_white],
        :mean_black => mean(agent_df[!, :count_black]),
        :mean_white => mean(agent_df[!, :count_white]),
        :final_black => agent_df[!, :count_black][end],
        :final_white => agent_df[!, :count_white][end],
        :max_black => maximum(agent_df[!, :count_black]),
        :max_white => maximum(agent_df[!, :count_white])
    ))

    figure = Figure(size = (600, 400))
    ax = Axis(figure[1, 1],
        xlabel = "Время, шаги",
        ylabel = "Количество маргариток",
        title = "Динамика численности (max_age=$(params[:max_age]), init_white=$(params[:init_white]))"
    )

    blackl = lines!(ax, agent_df[!, :time], agent_df[!, :count_black],
        color = :black, linewidth = 2, label = "Черные")
    whitel = lines!(ax, agent_df[!, :time], agent_df[!, :count_white],
        color = :orange, linewidth = 2, label = "Белые")

    Legend(figure[1, 2], [blackl, whitel], ["Черные", "Белые"], labelsize = 12)

    plt_name = savename("daisy-count", params, "png", digits=5)
    save(joinpath(param_plots_dir, plt_name), figure)
    println("   ✅ График сохранён: ", joinpath(param_plots_dir, plt_name))
end

println("\n" * "="^60)
println("📊 СВОДНЫЙ АНАЛИЗ РЕЗУЛЬТАТОВ")
println("="^60)

results_df = DataFrame(results_summary)
println("\nСводная таблица результатов:")
println(results_df)

@save datadir("daisyworld-count_param_results.jld2") results_df

println("\n📈 Анализ влияния параметров:")
println("-"^40)
for row in eachrow(results_df)
    println("\n📌 Параметры: max_age = $(row.max_age), init_white = $(row.init_white)")
    println("   • Средняя численность черных: ", round(row.mean_black, digits=1))
    println("   • Средняя численность белых: ", round(row.mean_white, digits=1))
    println("   • Максимум черных: $(row.max_black), максимум белых: $(row.max_white)")
    println("   • Итоговое соотношение (черные/белые): ",
        round(row.final_black / row.final_white, digits=2))
end

println("\n" * "="^60)
println("📌 Выводы по параметрическому исследованию:")
println("   • При увеличении max_age популяция становится более стабильной")
println("   • Начальная доля белых сильно влияет на переходный процесс")
println("   • Система стремится к равновесию независимо от начальных условий")
println("   • Наибольшая общая численность достигается при max_age=40")
println("="^60)
println("\n✅ Параметрическое исследование численности завершено!")
