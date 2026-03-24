using DrWatson
@quickactivate "project"

using Agents, DataFrames, Plots
using JLD2

include(srcdir("sir_model.jl"))

# Параметры эксперимента
params = Dict(
    :Ns => [1000, 1000, 1000],
    :β_und => [0.5, 0.5, 0.5],
    :β_det => [0.05, 0.05, 0.05],
    :infection_period => 14,
    :detection_time => 7,
    :death_rate => 0.02,
    :reinfection_probability => 0.1,
    :Is => [0, 0, 1],
    :seed => 42,
)

println("Инициализация модели...")
model = initialize_sir(; params...)

# Подготовка массивов для хранения данных
times = Int[]
S_vals = Int[]
I_vals = Int[]
R_vals = Int[]
total_vals = Int[]

n_steps = 100
println("Запуск симуляции на $n_steps шагов...")

for step = 1:n_steps
    Agents.step!(model, 1)
    
    push!(times, step)
    push!(S_vals, susceptible_count(model))
    push!(I_vals, infected_count(model))
    push!(R_vals, recovered_count(model))
    push!(total_vals, total_count(model))
    
    if step % 10 == 0
        println("  Шаг $step: S=$(S_vals[end]), I=$(I_vals[end]), R=$(R_vals[end])")
    end
end

# Создаём DataFrame
agent_df = DataFrame(time = times, susceptible = S_vals, infected = I_vals, recovered = R_vals)
model_df = DataFrame(time = times, total = total_vals)

# Сохранение данных
println("\nСохранение данных...")
@save datadir("sir_basic_agent.jld2") agent_df
@save datadir("sir_basic_model.jld2") model_df

# Визуализация
println("Построение графика...")
plot(agent_df.time, agent_df.susceptible, 
     label = "Восприимчивые (S)", 
     xlabel = "Дни", 
     ylabel = "Количество",
     linewidth = 2)
plot!(agent_df.time, agent_df.infected, 
      label = "Инфицированные (I)", 
      linewidth = 2)
plot!(agent_df.time, agent_df.recovered, 
      label = "Выздоровевшие (R)", 
      linewidth = 2)
plot!(agent_df.time, model_df.total, 
      label = "Всего (включая умерших)", 
      linestyle = :dash, 
      linewidth = 2)

title!("Модель SIR: Динамика эпидемии")
savefig(plotsdir("sir_basic_dynamics.png"))

println("\n=== Анализ результатов ===")
println("Пик заболеваемости: I_max = ", maximum(I_vals))
println("Время достижения пика: ", argmax(I_vals), " дней")
println("Итоговое число переболевших: R(∞) = ", R_vals[end])
println("Доля переболевших: ", round(R_vals[end]/3000*100, digits=1), "%")
println("Всего умерших: ", 3000 - total_vals[end])
println("\nГрафик сохранён в: ", plotsdir("sir_basic_dynamics.png"))
