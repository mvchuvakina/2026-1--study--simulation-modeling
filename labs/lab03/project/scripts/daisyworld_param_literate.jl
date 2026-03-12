# # Модель Daisyworld - Параметрическое исследование
#
# **Цель работы:** Исследовать, как различные параметры модели влияют на
# динамику популяции черных и белых маргариток.
#
# ## 1. Инициализация проекта и загрузка пакетов

using DrWatson
@quickactivate "project"

using Agents
using CairoMakie
using DataFrames
using Statistics
using JLD2
using DrWatson: dict_list, savename

include(srcdir("daisyworld.jl"))

# ## 2. Определение функций для сбора данных

# Функции для фильтрации агентов по цвету
black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]

# ## 3. Параметры эксперимента
#
# Исследуем влияние двух параметров:
# - `max_age` - максимальный возраст маргариток (25 или 40)
# - `init_white` - начальная доля белых маргариток (0.2 или 0.8)

param_dict = Dict(
    :griddim => (30, 30),
    :max_age => [25, 40],
    :init_white => [0.2, 0.8],
    :init_black => 0.2,
    :albedo_white => 0.75,
    :albedo_black => 0.25,
    :surface_albedo => 0.4,
    :solar_change => 0.005,
    :solar_luminosity => 1.0,
    :scenario => :default,
    :seed => 165,
)

# Генерируем все комбинации параметров
params_list = dict_list(param_dict)

println("="^60)
println("МОДЕЛЬ DAISYWORLD - ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ")
println("="^60)
println("\n📊 Всего комбинаций параметров: ", length(params_list))
println("\nИсследуемые комбинации:")
for (i, params) in enumerate(params_list)
    println("   $i. max_age=$(params[:max_age]), init_white=$(params[:init_white])")
end

# ## 4. Запуск для всех комбинаций параметров

# Создаем директорию для сохранения графиков
param_plots_dir = plotsdir("daisyworld_param")
mkpath(param_plots_dir)

# Массив для хранения результатов
results_summary = []

for (idx, params) in enumerate(params_list)
    println("\n" * "-"^60)
    println("🔄 Запуск $idx/$(length(params_list))")
    println("   Параметры: max_age=$(params[:max_age]), init_white=$(params[:init_white])")
    
    # Создаем модель с текущими параметрами
    model = daisyworld(; params...)
    
    # Запускаем симуляцию на 500 шагов и собираем данные
    agent_df, model_df = run!(model, 500; adata)
    
    # Сохраняем сводные результаты
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
    
    # Создаем график динамики численности
    fig = Figure(size = (600, 400))
    ax = Axis(fig[1, 1],
        xlabel = "Время, шаги",
        ylabel = "Количество маргариток",
        title = "Динамика численности (max_age=$(params[:max_age]), init_white=$(params[:init_white]))"
    )
    
    # Строим линии
    black_line = lines!(ax, agent_df[!, :time], agent_df[!, :count_black],
        color = :black, linewidth = 2, label = "Черные")
    white_line = lines!(ax, agent_df[!, :time], agent_df[!, :count_white],
        color = :orange, linewidth = 2, label = "Белые")
    
    # Добавляем легенду (передаем линии и подписи)
    axislegend(ax, [black_line, white_line], ["Черные", "Белые"], position = :rt)
    
    # Сохраняем график
    plt_name = savename("daisyworld_param", params, "png", digits=5)
    save(joinpath(param_plots_dir, plt_name), fig)
    println("   ✅ График сохранён: ", joinpath(param_plots_dir, plt_name))
end

# ## 5. Сводный анализ результатов

println("\n" * "="^60)
println("📊 СВОДНЫЙ АНАЛИЗ РЕЗУЛЬТАТОВ")
println("="^60)

# Создаем сводную таблицу
results_df = DataFrame(results_summary)
println("\nСводная таблица результатов:")
println(results_df)

# Сохраняем результаты в JLD2
@save datadir("daisyworld_param_results.jld2") results_df

println("\n📈 Анализ влияния параметров:")
for row in eachrow(results_df)
    println("\nПараметры: max_age=$(row.max_age), init_white=$(row.init_white)")
    println("   - Средняя численность черных: ", round(row.mean_black, digits=1))
    println("   - Средняя численность белых: ", round(row.mean_white, digits=1))
    println("   - Максимум черных: $(row.max_black), максимум белых: $(row.max_white)")
end

println("\n" * "="^60)
println("✅ Параметрическое исследование завершено!")
println("="^60)
