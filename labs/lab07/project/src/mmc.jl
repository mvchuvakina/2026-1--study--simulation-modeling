# src/mmc.jl
# Модель M/M/c - система массового обслуживания с несколькими каналами

using ConcurrentSim
using ResumableFunctions
using Distributions
using Random

# -------------------------------------------------------------------
# 1. ПОВЕДЕНИЕ КЛИЕНТА
# -------------------------------------------------------------------
@resumable function customer(
    env::Environment,
    server::Resource,
    id::Integer,
    arrival_time::Float64,
    service_dist::Distribution
)
    # Заявка прибывает
    @yield timeout(env, arrival_time)
    println("[$(now(env))] Клиент $id прибыл")
    
    # Запрос сервера
    @yield request(server)
    println("[$(now(env))] Клиент $id начал обслуживание")
    
    # Обслуживание
    @yield timeout(env, rand(service_dist))
    
    # Завершение обслуживания
    @yield release(server)
    println("[$(now(env))] Клиент $id завершил обслуживание")
end

# -------------------------------------------------------------------
# 2. ЗАПУСК СИМУЛЯЦИИ (Базовая версия)
# -------------------------------------------------------------------
function run_mmc(;
    λ::Float64 = 0.9,
    μ::Float64 = 0.5,
    c::Int = 2,
    n_customers::Int = 10,
    seed::Int = 123
)
    Random.seed!(seed)
    arrival_dist = Exponential(1 / λ)
    service_dist = Exponential(1 / μ)
    
    sim = Simulation()
    server = Resource(sim, c)
    arrival_time = 0.0
    
    for i in 1:n_customers
        arrival_time += rand(arrival_dist)
        @process customer(sim, server, i, arrival_time, service_dist)
    end
    
    run(sim)
    return now(sim)
end

# -------------------------------------------------------------------
# 3. СБОР СТАТИСТИКИ (С очередью)
# -------------------------------------------------------------------
@resumable function customer_stats(
    env::Environment,
    server::Resource,
    id::Integer,
    arrival_time::Float64,
    service_dist::Distribution,
    stats::Dict
)
    @yield timeout(env, arrival_time)
    start_wait = now(env)
    
    @yield request(server)
    end_wait = now(env)
    
    stats[:wait_times][id] = end_wait - start_wait
    
    @yield timeout(env, rand(service_dist))
    @yield release(server)
    
    stats[:service_times][id] = now(env) - end_wait
end

function run_mmc_stats(;
    λ::Float64 = 0.9,
    μ::Float64 = 0.5,
    c::Int = 2,
    n_customers::Int = 100,
    seed::Int = 123
)
    Random.seed!(seed)
    arrival_dist = Exponential(1 / λ)
    service_dist = Exponential(1 / μ)
    
    sim = Simulation()
    server = Resource(sim, c)
    arrival_time = 0.0
    
    stats = Dict(
        :wait_times => Dict{Int,Float64}(),
        :service_times => Dict{Int,Float64}()
    )
    
    for i in 1:n_customers
        arrival_time += rand(arrival_dist)
        @process customer_stats(sim, server, i, arrival_time, service_dist, stats)
    end
    
    run(sim)
    return stats, now(sim)
end
