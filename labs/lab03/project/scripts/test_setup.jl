#!/usr/bin/env julia
# test_setup.jl - Скрипт для проверки установки пакетов

using DrWatson
@quickactivate "project"  # Активируем проект DrWatson

println("✅ Проект активирован: ", projectdir())

# Список пакетов для проверки
packages = [
    "DrWatson",
    "Agents",
    "Plots",
    "CairoMakie",
    "DataFrames",
    "Literate",
    "IJulia",
    "BenchmarkTools",
    "StatsPlots",
    "Distributions"
]

println("\n🔍 Проверка пакетов:")
for pkg in packages
    try
        # Пытаемся загрузить пакет
        eval(Meta.parse("using $pkg"))
        println("  ✅ $pkg")
    catch e
        println("  ❌ $pkg: Ошибка загрузки - ", e)
    end
end

# Проверка структуры проекта
println("\n📁 Структура проекта:")
println("  📂 Корень проекта: ", projectdir())
println("  📂 Данные: ", datadir())
println("  📂 Скрипты: ", scriptsdir())
println("  📂 Графики: ", plotsdir())
println("  📂 Исходный код: ", srcdir())

println("\n🎉 Все проверки завершены!")
