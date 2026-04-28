using DrWatson
@quickactivate

using Plots
using DataFrames

include(srcdir("SIRPetri.jl"))
using .SIRPetri

params_list = [
    (β = 0.2, γ = 0.1, name = "β=0.2, γ=0.1 (слабая эпидемия)"),
    (β = 0.3, γ = 0.1, name = "β=0.3, γ=0.1 (средняя эпидемия)"),
    (β = 0.5, γ = 0.1, name = "β=0.5, γ=0.1 (сильная эпидемия)"),
    (β = 0.3, γ = 0.2, name = "β=0.3, γ=0.2 (быстрое выздоровление)"),
    (β = 0.5, γ = 0.2, name = "β=0.5, γ=0.2 (комбинированный)"),
]

tmax = 100.0

println("="^60)
println("ПАРАМЕТРИЧЕСКАЯ АНИМАЦИЯ МОДЕЛИ SIR")
println("="^60)

for (idx, params) in enumerate(params_list)
    β = params.β
    γ = params.γ
    name = params.name

    println("Создание анимации для: $name")

    net, u0, states = build_sir_network(β, γ)
    df = simulate_deterministic(net, u0, (0.0, tmax), saveat = 0.2, rates = [β, γ])

    anim = @animate for i in 1:length(df.time)
        bar(
            ["S", "I", "R"],
            [df.S[i], df.I[i], df.R[i]],
            ylims = (0, 1000),
            title = "$name | Время = $(round(df.time[i], digits=1))",
            ylabel = "Численность",
            color = [:blue, :red, :green],
            legend = false,
        )
    end

    filename = "sir_animation_β=$(β)_γ=$(γ).gif"
    gif(anim, plotsdir(filename), fps = 10)
    println("  Сохранено: plots/$filename")
end

println()
println("Создание сравнительной анимации...")

cases = [
    (β = 0.2, γ = 0.1, color = :blue, label = "β=0.2, γ=0.1"),
    (β = 0.3, γ = 0.1, color = :red, label = "β=0.3, γ=0.1"),
    (β = 0.5, γ = 0.1, color = :green, label = "β=0.5, γ=0.1"),
]

dfs = []
for case in cases
    net, u0, states = build_sir_network(case.β, case.γ)
    df = simulate_deterministic(net, u0, (0.0, tmax), saveat = 0.2, rates = [case.β, case.γ])
    push!(dfs, (df = df, case = case))
end

anim_compare = @animate for i in 1:length(dfs[1].df.time)
    p = plot(
        title = "Сравнение динамики I(t) при разных β",
        xlabel = "Группа",
        ylabel = "Численность",
        ylims = (0, 1000),
        legend = :topleft,
    )

    for (j, data) in enumerate(dfs)
        bar!(
            p, [data.case.label],
            [data.df.I[i]],
            color = data.case.color,
            alpha = 0.7,
            label = data.case.label,
        )
    end

    annotate!(p, 0.5, 950, text("Время = $(round(dfs[1].df.time[i], digits=1))", 10))
end

gif(anim_compare, plotsdir("sir_animation_comparison.gif"), fps = 10)
println("Сравнительная анимация сохранена: plots/sir_animation_comparison.gif")

println()
println("="^60)
println("ПАРАМЕТРИЧЕСКАЯ АНИМАЦИЯ ЗАВЕРШЕНА")
println("="^60)
