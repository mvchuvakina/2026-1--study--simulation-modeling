# # Карантинные меры
# 
# **Цель:** Модифицировать модель, добавив возможность закрытия города
# при превышении порога заболеваемости, и оценить эффективность такой меры.
# 
# **Автор:** [Ваше Имя]
# **Дата:** 2026-03-23
# 
# ## Теоретическое введение
# 
# Карантин — это одна из основных мер борьбы с распространением инфекции.
# В реальной жизни города или регионы могут закрываться на карантин,
# когда уровень заболеваемости превышает критический порог.
# 
# ### Механизм карантина в модели
# 
# 1. **Мониторинг:** На каждом шаге проверяется доля инфицированных в каждом городе
# 2. **Активация:** Если доля превышает порог (30%), город закрывается
# 3. **Изоляция:** Из закрытого города нельзя выехать, и в него нельзя въехать
# 4. **Снятие карантина:** В данной модели карантин не снимается (упрощение)
# 
# ### Ожидаемый эффект
# 
# - Снижение пика заболеваемости
# - Замедление распространения инфекции
# - Возможность "сплющить кривую" (flatten the curve)

using DrWatson
@quickactivate

using Agents, DataFrames, Plots, Random
using StatsBase: sample, Weights
include(srcdir("sir_model.jl"))

# ## Модифицированная модель с карантином
# 
# ### Функция инициализации
# 
# Создаёт модель с дополнительными полями:
# - `quarantine_threshold` — порог для закрытия города
# - `quarantine_active` — массив флагов закрытых городов
# - `rng` — генератор случайных чисел (добавлен в properties)

function initialize_sir_with_quarantine(;
    Ns = [1000, 1000, 1000],
    β_und = [0.5, 0.5, 0.5],
    β_det = [0.05, 0.05, 0.05],
    infection_period = 14,
    detection_time = 7,
    death_rate = 0.02,
    Is = [1, 0, 0],
    seed = 42,
    quarantine_threshold = 0.3,
)

    rng = Xoshiro(seed)
    C = length(Ns)
    
    # Создаём базовую матрицу миграции
    migration_rates = zeros(C, C)
    for i = 1:C
        for j = 1:C
            migration_rates[i, j] = (Ns[i] + Ns[j]) / Ns[i]
        end
    end
    for i = 1:C
        migration_rates[i, :] ./= sum(migration_rates[i, :])
    end
    
    properties = Dict(
        :Ns => Ns,
        :β_und => β_und,
        :β_det => β_det,
        :migration_rates => migration_rates,
        :infection_period => infection_period,
        :detection_time => detection_time,
        :death_rate => death_rate,
        :reinfection_probability => 0.1,
        :C => C,
        :quarantine_threshold => quarantine_threshold,
        :quarantine_active => zeros(Bool, C),
        :rng => rng,  # Добавляем rng в properties для доступа
    )
    
    space = GraphSpace(complete_graph(C))
    model = StandardABM(Person, space; properties, rng, agent_step! = sir_agent_step_with_quarantine!)
    
    # Заполняем города агентами
    for city = 1:C
        for _ = 1:Ns[city]
            add_agent!(city, model, 0, :S)
        end
    end
    
    # Инфицируем начальных носителей
    for city = 1:C
        if Is[city] > 0
            city_agents = ids_in_position(city, model)
            infected_ids = sample(rng, city_agents, Is[city]; replace = false)
            for id in infected_ids
                agent = model[id]
                agent.status = :I
                agent.days_infected = 1
            end
        end
    end
    
    return model
end

# ## Шаг агента с учётом карантина
# 
# ### Логика работы:
# 
# 1. **Проверка порога:** Для каждого города вычисляем долю инфицированных.
#    Если превышен порог — город закрывается.
# 
# 2. **Миграция:** Агенты могут перемещаться только между открытыми городами.
#    Если агент находится в закрытом городе, он остаётся там.
# 
# 3. **Заражение:** Процесс заражения не меняется, но ограничение миграции
#    снижает скорость распространения.

function sir_agent_step_with_quarantine!(agent, model)
    # === 1. Проверяем порог для закрытия города ===
    for city in 1:model.C
        if !model.quarantine_active[city]
            infected_frac = count(a.status == :I && a.pos == city for a in allagents(model)) / model.Ns[city]
            if infected_frac >= model.quarantine_threshold
                model.quarantine_active[city] = true
                println("⚠️  Город $city закрыт на карантин! (заражено $(round(infected_frac*100, digits=1))%)")
            end
        end
    end
    
    # === 2. Миграция с учётом карантина ===
    current_city = agent.pos
    if !model.quarantine_active[current_city]
        # Если город не на карантине, можно мигрировать
        probs = copy(model.migration_rates[current_city, :])
        
        # Убираем закрытые города из вероятностей
        for city in 1:model.C
            if model.quarantine_active[city]
                probs[city] = 0.0
            end
        end
        
        if sum(probs) > 0
            probs ./= sum(probs)
            target = sample(model.rng, 1:model.C, Weights(probs))
            if target != current_city
                move_agent!(agent, target, model)
            end
        end
    end
    
    # === 3. Передача инфекции ===
    if agent.status == :I
        # Определяем интенсивность заражения
        rate = if agent.days_infected < model.detection_time
            model.β_und[agent.pos]      # невыявленный – высокая заразность
        else
            model.β_det[agent.pos]      # выявленный – низкая заразность
        end
        
        n_infections = rand(model.rng, Poisson(rate))
        
        if n_infections > 0
            neighbors = [a for a in agents_in_position(agent.pos, model) if a.id != agent.id]
            shuffle!(model.rng, neighbors)
            
            for contact in neighbors
                if contact.status == :S
                    contact.status = :I
                    contact.days_infected = 1
                    n_infections -= 1
                    n_infections == 0 && break
                elseif contact.status == :R && rand(model.rng) ≤ model.reinfection_probability
                    contact.status = :I
                    contact.days_infected = 1
                    n_infections -= 1
                    n_infections == 0 && break
                end
            end
        end
    end
    
    # === 4. Обновление счётчика дней ===
    if agent.status == :I
        agent.days_infected += 1
    end
    
    # === 5. Выздоровление или смерть ===
    if agent.status == :I && agent.days_infected ≥ model.infection_period
        if rand(model.rng) ≤ model.death_rate
            remove_agent!(agent, model)  # смерть
        else
            agent.status = :R             # выздоровление
            agent.days_infected = 0
        end
    end
end

# ## Запуск модели с карантином
# 
# Сравниваем два сценария:
# 1. **Без карантина** — стандартная модель
# 2. **С карантином** — с порогом активации 30%

println("="^60)
println("МОДЕЛЬ С КАРАНТИННЫМИ МЕРАМИ")
println("="^60)

# ### Сценарий 1: Без карантина
println("\n1. Сценарий без карантина...")
model_no_quarantine = initialize_sir(;
    Ns = [1000, 1000, 1000],
    β_und = [0.5, 0.5, 0.5],
    β_det = [0.05, 0.05, 0.05],
    Is = [1, 0, 0],
    seed = 42,
)

infected_no_quarantine = []
for step in 1:100
    Agents.step!(model_no_quarantine, 1)
    push!(infected_no_quarantine, count(a.status == :I for a in allagents(model_no_quarantine)))
end

# ### Сценарий 2: С карантином
println("\n2. Сценарий с карантином (порог 30%)...")
model_quarantine = initialize_sir_with_quarantine(;
    Ns = [1000, 1000, 1000],
    β_und = [0.5, 0.5, 0.5],
    β_det = [0.05, 0.05, 0.05],
    Is = [1, 0, 0],
    seed = 42,
    quarantine_threshold = 0.3,
)

infected_with_quarantine = []
quarantine_activated = false

for step in 1:100
    Agents.step!(model_quarantine, 1)
    push!(infected_with_quarantine, count(a.status == :I for a in allagents(model_quarantine)))
    if any(model_quarantine.quarantine_active) && !quarantine_activated
        global quarantine_activated = true
        println("   ✓ Карантин активирован на шаге $step")
    end
end

# ## Визуализация результатов
# 
# Строим сравнительный график динамики инфицированных
# для двух сценариев.

plot(1:100, infected_no_quarantine, 
     label = "Без карантина", 
     xlabel = "Дни", 
     ylabel = "Количество инфицированных",
     linewidth = 2,
     color = :red)
plot!(1:100, infected_with_quarantine, 
      label = "С карантином (порог 30%)", 
      linewidth = 2,
      color = :blue,
      linestyle = :dash)
title!("Эффективность карантинных мер")
savefig(plotsdir("quarantine_effect.png"))

# ## Анализ эффективности

peak_no = maximum(infected_no_quarantine)
peak_with = maximum(infected_with_quarantine)
reduction = (peak_no - peak_with) / peak_no * 100

println("\n" * "="^60)
println("АНАЛИЗ ЭФФЕКТИВНОСТИ КАРАНТИНА")
println("="^60)
println()
println("📊 **Сравнение показателей:**")
println("   - Пик заболеваемости без карантина: $peak_no")
println("   - Пик заболеваемости с карантином: $peak_with")
println("   - Снижение пика: $(round(reduction, digits=1))%")
println()
println("📌 **Выводы:**")

if reduction > 50
    println("   ✅ Карантинная мера оказалась **высокоэффективной**")
    println("   - Пик снизился более чем на 50%")
    println("   - Рекомендуется для сдерживания эпидемии")
elseif reduction > 20
    println("   ✅ Карантинная мера оказалась **умеренно эффективной**")
    println("   - Пик снизился на $(round(reduction, digits=1))%")
    println("   - Требуется комбинация с другими мерами")
else
    println("   ⚠️ Карантинная мера оказалась **малоэффективной**")
    println("   - Снижение пика менее 20%")
    println("   - Возможно, порог активации выбран слишком высоко")
end

println()
println("🔬 **Факторы, влияющие на эффективность:**")
println("   - Порог активации карантина (30%)")
println("   - Скорость распространения инфекции (β = 0.5)")
println("   - Интенсивность миграции между городами")
println("   - Время выявления заболевания (7 дней)")
println()
println("💡 **Рекомендации:**")
println("   - Для повышения эффективности можно снизить порог активации")
println("   - Раннее введение карантина даёт лучший результат")
println("   - Сочетание с другими мерами (маски, дистанция) усиливает эффект")

println("\n✅ Исследование карантинных мер завершено!")
println("📁 График сохранён в: ", plotsdir("quarantine_effect.png"))
