# src/ross.jl
# Модель Росса - система с конечной популяцией, резервом и ремонтом

using ConcurrentSim
using ResumableFunctions
using Distributions
using Random

# -------------------------------------------------------------------
# 1. МАШИНА ДЛЯ МОДЕЛИ С ОДНИМ РЕМОНТНИКОМ
# -------------------------------------------------------------------
@resumable function machine_single(
    env::Environment,
    repair_facility::Resource,
    spares::Store{Process},
    id::Int,
    λ::Float64,
    μ::Float64
)
    failure_dist = Exponential(λ)
    repair_dist = Exponential(μ)
    
    while true
        @yield timeout(env, rand(failure_dist))
        
        if isempty(spares.items)
            throw(StopSimulation("Нет резервных машин! Система упала."))
        end
        
        get_spare = take!(spares)
        @yield get_spare
        
        @yield request(repair_facility)
        @yield timeout(env, rand(repair_dist))
        @yield release(repair_facility)
        
        @yield put!(spares, active_process(env))
    end
end

function run_ross_single(;
    N::Int = 10,
    S::Int = 3,
    λ::Float64 = 100.0,
    μ::Float64 = 1.0,
    seed::Int = 42
)
    Random.seed!(seed)
    sim = Simulation()
    
    repair_facility = Resource(sim, 1)
    spares = Store{Process}(sim)
    
    for i in 1:S
        proc = @process machine_single(sim, repair_facility, spares, i, λ, μ)
        put!(spares, proc)
    end
    
    for i in 1:N
        @process machine_single(sim, repair_facility, spares, N+i, λ, μ)
    end
    
    try
        run(sim)
        return Inf
    catch e
        return now(sim)
    end
end

# -------------------------------------------------------------------
# 2. МАШИНА ДЛЯ МОДЕЛИ С НЕСКОЛЬКИМИ РЕМОНТНИКАМИ
# -------------------------------------------------------------------
@resumable function machine_multi(
    env::Environment,
    repair_facility::Resource,
    spares::Store{Process},
    id::Int,
    λ::Float64,
    μ::Float64
)
    failure_dist = Exponential(λ)
    repair_dist = Exponential(μ)
    
    while true
        @yield timeout(env, rand(failure_dist))
        
        if isempty(spares.items)
            throw(StopSimulation("Нет резервных машин! Система упала."))
        end
        
        get_spare = take!(spares)
        @yield get_spare
        
        @yield request(repair_facility)
        @yield timeout(env, rand(repair_dist))
        @yield release(repair_facility)
        
        @yield put!(spares, active_process(env))
    end
end

function run_ross_multi(;
    N::Int = 10,
    S::Int = 3,
    R::Int = 2,
    λ::Float64 = 100.0,
    μ::Float64 = 1.0,
    seed::Int = 42
)
    Random.seed!(seed)
    sim = Simulation()
    
    repair_facility = Resource(sim, R)
    spares = Store{Process}(sim)
    
    for i in 1:S
        proc = @process machine_multi(sim, repair_facility, spares, i, λ, μ)
        put!(spares, proc)
    end
    
    for i in 1:N
        @process machine_multi(sim, repair_facility, spares, N+i, λ, μ)
    end
    
    try
        run(sim)
        return Inf
    catch e
        return now(sim)
    end
end

# -------------------------------------------------------------------
# 3. МОНИТОРИНГ СОСТОЯНИЯ
# -------------------------------------------------------------------
@resumable function machine_monitored(
    env::Environment,
    repair_facility::Resource,
    spares::Store{Process},
    id::Int,
    λ::Float64,
    μ::Float64,
    history::Dict
)
    failure_dist = Exponential(λ)
    repair_dist = Exponential(μ)
    
    while true
        @yield timeout(env, rand(failure_dist))
        
        if isempty(spares.items)
            throw(StopSimulation("Нет резервных машин! Система упала."))
        end
        
        get_spare = take!(spares)
        @yield get_spare
        
        @yield request(repair_facility)
        @yield timeout(env, rand(repair_dist))
        @yield release(repair_facility)
        
        @yield put!(spares, active_process(env))
        
        push!(history[:time], now(env))
        push!(history[:spares], length(spares.items))
        push!(history[:repair_queue], length(repair_facility.queue))
    end
end

function run_ross_monitored(;
    N::Int = 10,
    S::Int = 3,
    R::Int = 1,
    λ::Float64 = 100.0,
    μ::Float64 = 1.0,
    seed::Int = 42
)
    Random.seed!(seed)
    sim = Simulation()
    
    repair_facility = Resource(sim, R)
    spares = Store{Process}(sim)
    
    history = Dict(
        :time => Float64[],
        :spares => Int[],
        :repair_queue => Int[]
    )
    
    for i in 1:S
        proc = @process machine_monitored(sim, repair_facility, spares, i, λ, μ, history)
        put!(spares, proc)
    end
    
    for i in 1:N
        @process machine_monitored(sim, repair_facility, spares, N+i, λ, μ, history)
    end
    
    try
        run(sim)
        return Inf, history
    catch e
        return now(sim), history
    end
end
