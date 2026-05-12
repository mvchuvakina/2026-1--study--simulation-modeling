#!/usr/bin/env julia
using Pkg
Pkg.activate(".")

packages = [
    "DrWatson",
    "ConcurrentSim",      # Основной пакет для дискретно-событийного моделирования
    "ResumableFunctions", # Для асинхронных функций
    "Distributions",      # Для работы с распределениями
    "Random",             # Генерация случайных чисел
    "StableRNGs",         # Воспроизводимые случайные числа
    "Plots",
    "DataFrames",
    "JLD2",
    "Literate",
    "IJulia",
    "BenchmarkTools",
    "StatsPlots",
    "LaTeXStrings"
]

println("📦 Установка пакетов для дискретно-событийного моделирования...")
Pkg.add(packages)
println("✅ Все пакеты установлены!")
