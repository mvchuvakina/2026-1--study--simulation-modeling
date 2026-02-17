#!/usr/bin/env julia
using Pkg
Pkg.activate(".")

packages = [
    "DrWatson",
    "DifferentialEquations",
    "Plots",
    "DataFrames",
    "CSV",
    "JLD2",
    "Literate",
    "IJulia",
    "BenchmarkTools",
    "StatsPlots",
    "LaTeXStrings",
    "SimpleDiffEq",
    "Tables",
    "FFTW"
]

println("Установка пакетов...")
Pkg.add(packages)
println("✓ Все пакеты установлены!")
