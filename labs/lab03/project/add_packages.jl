#!/usr/bin/env julia
# add_packages.jl

using Pkg
Pkg.activate(".")

packages = [
    "DrWatson",
    "Agents",          # Основной пакет для агентного моделирования
    "Plots",
    "DataFrames",
    "JLD2",
    "Literate",
    "IJulia",
    "BenchmarkTools",
    "StatsPlots",
    "CairoMakie"       # Рекомендуется для визуализации Agents.jl
]

println("📦 Установка пакетов для агентного моделирования...")
Pkg.add(packages)
println("\n✅ Все пакеты установлены!")
