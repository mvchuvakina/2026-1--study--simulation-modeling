#!/usr/bin/env julia
using DrWatson
@quickactivate "project"

println("✅ Проект активирован: ", projectdir())

packages = ["DrWatson", "ConcurrentSim", "ResumableFunctions", "Distributions", 
            "Plots", "DataFrames", "Literate", "IJulia", "StatsPlots", "LaTeXStrings"]

println("\n🔍 Проверка пакетов:")
for pkg in packages
    try
        eval(Meta.parse("using $pkg"))
        println("  ✅ $pkg")
    catch
        println("  ❌ $pkg")
    end
end
