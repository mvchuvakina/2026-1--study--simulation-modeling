# ============================================================================
# Модуль SIRPetri - модель SIR на сетях Петри (упрощённая версия)
# ============================================================================

module SIRPetri

using OrdinaryDiffEq
using Plots
using DataFrames
using Random

export build_sir_network, simulate_deterministic, simulate_stochastic
export plot_sir

# ----------------------------------------------------------------------------
# 1. Структура PetriNet (упрощённая)
# ----------------------------------------------------------------------------
struct PetriNet
    n_places::Int
    n_transitions::Int
    incidence::Matrix{Int}
    place_names::Vector{Symbol}
    transition_names::Vector{Symbol}
end

# ----------------------------------------------------------------------------
# 2. Построение сети Петри для модели SIR
# ----------------------------------------------------------------------------
function build_sir_network(β = 0.3, γ = 0.1)
    states = [:S, :I, :R]
    
    # Создаём сеть: 3 позиции, 2 перехода
    net = PetriNet(3, 2, zeros(Int, 3, 2), states, [:infection, :recovery])
    
    # Матрица инцидентности
    # Переход infection (1): S + I → I + I
    net.incidence[1, 1] = -1   # S уменьшается на 1
    net.incidence[2, 1] = +1   # I увеличивается на 1 (нетто-эффект)
    
    # Переход recovery (2): I → R
    net.incidence[2, 2] = -1   # I уменьшается на 1
    net.incidence[3, 2] = +1   # R увеличивается на 1
    
    # Начальная маркировка: S=990, I=10, R=0
    u0 = [990.0, 10.0, 0.0]
    
    return net, u0, states
end

# ----------------------------------------------------------------------------
# 3. Вспомогательная функция ОДУ
# ----------------------------------------------------------------------------
function sir_ode(net::PetriNet, rates = [0.3, 0.1])
    function f!(du, u, p, t)
        S, I, R = u
        β, γ = rates
        
        # Пропускные способности (закон действующих масс)
        infection_rate = β * S * I
        recovery_rate = γ * I
        
        # Изменения
        du[1] = -infection_rate          # dS/dt
        du[2] = infection_rate - recovery_rate  # dI/dt
        du[3] = recovery_rate            # dR/dt
    end
    return f!
end

# ----------------------------------------------------------------------------
# 4. Детерминированная симуляция (ODE)
# ----------------------------------------------------------------------------
function simulate_deterministic(net::PetriNet, u0::Vector{Float64}, tspan::Tuple;
                                saveat::Float64 = 0.1, rates = [0.3, 0.1])
    f = sir_ode(net, rates)
    prob = ODEProblem(f, u0, tspan)
    sol = solve(prob, Tsit5(), saveat = saveat)
    
    df = DataFrame(time = sol.t)
    df.S = sol[1, :]
    df.I = sol[2, :]
    df.R = sol[3, :]
    return df
end

# ----------------------------------------------------------------------------
# 5. Стохастическая симуляция (алгоритм Гиллеспи)
# ----------------------------------------------------------------------------
function simulate_stochastic(net::PetriNet, u0::Vector{Float64}, tspan::Tuple;
                             rates = [0.3, 0.1], rng = Random.GLOBAL_RNG)
    u = copy(u0)
    t = 0.0
    times = [t]
    states = [copy(u)]
    
    β, γ = rates
    
    while t < tspan[2]
        S, I, R = u
        a_inf = β * S * I
        a_rec = γ * I
        a0 = a_inf + a_rec
        
        if a0 == 0
            break
        end
        
        dt = -log(rand(rng)) / a0
        r = rand(rng) * a0
        
        if r < a_inf
            # Заражение: S -> I
            u[1] -= 1
            u[2] += 1
        else
            # Выздоровление: I -> R
            u[2] -= 1
            u[3] += 1
        end
        
        t += dt
        if t <= tspan[2]
            push!(times, t)
            push!(states, copy(u))
        end
    end
    
    df = DataFrame(time = times)
    df.S = [s[1] for s in states]
    df.I = [s[2] for s in states]
    df.R = [s[3] for s in states]
    return df
end

# ----------------------------------------------------------------------------
# 6. Визуализация
# ----------------------------------------------------------------------------
function plot_sir(df::DataFrame)
    p = plot(
        df.time,
        [df.S df.I df.R],
        label = ["S (Susceptible)" "I (Infected)" "R (Recovered)"],
        xlabel = "Time",
        ylabel = "Population",
        linewidth = 2,
    )
    return p
end

end # module
