# scripts/ross_run.jl
# Запуск модели Росса и параметрическое исследование

using DrWatson
@quickactivate "project"

using Plots
using Statistics
using DataFrames
using JLD2

include(srcdir("ross.jl"))

# -------------------------------------------------------------------
# 1. БАЗОВЫЙ ЗАПУСК
# -------------------------------------------------------------------
println("="^60)
println("МОДЕЛЬ РОССА")
println("="^60)

println("\nБазовый запуск (N=10, S=3, R=1):")
time_to_fail = run_ross_single(N=10, S=3, λ=100.0, μ=1.0)
println("  Время до отказа системы: $time_to_fail")

# -------------------------------------------------------------------
# 2. ИССЛЕДОВАНИЕ ВЛИЯНИЯ КОЛИЧЕСТВА РЕМОНТНИКОВ
# -------------------------------------------------------------------
println("\n" * "="^60)
println("ИССЛЕДОВАНИЕ ВЛИЯНИЯ ЧИСЛА РЕМОНТНИКОВ")
println("="^60)

repair_counts = 1:5
mean_times = Float64[]

for R in repair_counts
    times = Float64[]
    for run in 1:10
        t = run_ross_multi(N=10, S=3, R=R, λ=100.0, μ=1.0, seed=42+run)
        push!(times, t)
    end
    push!(mean_times, mean(times))
    println("  R=$R: среднее время до отказа = ", round(mean_times[end], digits=1))
end

p1 = plot(repair_counts, mean_times,
    marker=:circle, linewidth=2,
    xlabel="Количество ремонтников (R)",
    ylabel="Среднее время до отказа",
    title="Влияние числа ремонтников на надёжность системы",
    legend=false
)

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))
savefig(p1, plotsdir(script_name, "ross_repair_vs_time.png"))

# -------------------------------------------------------------------
# 3. ИССЛЕДОВАНИЕ ВЛИЯНИЯ КОЛИЧЕСТВА РЕЗЕРВНЫХ МАШИН
# -------------------------------------------------------------------
println("\n" * "="^60)
println("ИССЛЕДОВАНИЕ ВЛИЯНИЯ ЧИСЛА РЕЗЕРВНЫХ МАШИН")
println("="^60)

spare_counts = 0:10
mean_times_spare = Float64[]

for S in spare_counts
    times = Float64[]
    for run in 1:10
        t = run_ross_single(N=10, S=S, λ=100.0, μ=1.0, seed=42+run)
        push!(times, t)
    end
    push!(mean_times_spare, mean(times))
    println("  S=$S: среднее время до отказа = ", round(mean_times_spare[end], digits=1))
end

p2 = plot(spare_counts, mean_times_spare,
    marker=:circle, linewidth=2,
    xlabel="Количество резервных машин (S)",
    ylabel="Среднее время до отказа",
    title="Влияние размера резерва на надёжность системы",
    legend=false
)
savefig(p2, plotsdir(script_name, "ross_spare_vs_time.png"))

# -------------------------------------------------------------------
# 4. МОНИТОРИНГ СОСТОЯНИЯ СИСТЕМЫ
# -------------------------------------------------------------------
println("\n" * "="^60)
println("МОНИТОРИНГ СОСТОЯНИЯ СИСТЕМЫ")
println("="^60)

fail_time, history = run_ross_monitored(N=10, S=3, R=1, λ=100.0, μ=1.0)

p3 = plot(history[:time], history[:spares],
    linewidth=2, color=:blue,
    xlabel="Время", ylabel="Количество резервных машин",
    title="Динамика резерва во времени",
    legend=false
)
savefig(p3, plotsdir(script_name, "ross_spares_dynamics.png"))

p4 = plot(history[:time], history[:repair_queue],
    linewidth=2, color=:red,
    xlabel="Время", ylabel="Длина очереди на ремонт",
    title="Динамика очереди на ремонт",
    legend=false
)
savefig(p4, plotsdir(script_name, "ross_queue_dynamics.png"))

# -------------------------------------------------------------------
# 5. СВОДНЫЙ ГРАФИК
# -------------------------------------------------------------------
p_combined = plot(p1, p2, p3, p4, layout=(2,2), size=(1200, 900))
savefig(p_combined, plotsdir(script_name, "ross_combined.png"))

println("\n✅ Все графики сохранены в: ", plotsdir(script_name))
