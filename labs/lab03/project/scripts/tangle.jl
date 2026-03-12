#!/usr/bin/env julia
# tangle.jl - Генератор отчетов из Literate-скриптов
# 
# Этот скрипт преобразует файлы в литературном стиле (с Markdown-комментариями)
# в три формата:
# 1. Чистый код (без комментариев) - для запуска
# 2. Jupyter notebook - для интерактивной работы
# 3. Quarto-документ - для включения в отчёт
#
# Использование: julia tangle.jl <путь_к_скрипту>
# Пример: julia tangle.jl scripts/daisyworld_literate.jl

using DrWatson
@quickactivate  # Активирует текущий проект DrWatson

using Literate
using Dates

function main()
    if length(ARGS) == 0
        println("="^60)
        println("ГЕНЕРАТОР ПРОИЗВОДНЫХ ФОРМАТОВ")
        println("="^60)
        println("\n📋 Использование:")
        println("   julia tangle.jl <путь_к_скрипту>")
        println("\n📌 Примеры:")
        println("   julia tangle.jl scripts/daisyworld_literate.jl")
        println("   julia tangle.jl scripts/daisyworld-count_literate.jl")
        println("   julia tangle.jl scripts/daisyworld-luminosity_literate.jl")
        println("   julia tangle.jl scripts/daisyworld_param_literate.jl")
        println("\n🔍 Для массовой генерации можно использовать:")
        println("   for file in scripts/*_literate.jl; do")
        println("       julia tangle.jl \$file")
        println("   done")
        println("\n" * "="^60)
        return
    end

    script_path = ARGS[1]

    if !isfile(script_path)
        error("❌ Файл не найден: $script_path")
    end

    # Получаем имя скрипта без пути и расширения
    script_dir = dirname(script_path)
    script_name = splitext(basename(script_path))[1]
    
    println("="^60)
    println("ГЕНЕРАЦИЯ ИЗ: $script_path")
    println("="^60)
    println("📝 Имя скрипта: $script_name")
    println("🕒 Время начала: $(now())")

    # -------------------------------------------------------------------
    # 1. Генерация чистого скрипта (без Markdown-комментариев)
    # -------------------------------------------------------------------
    println("\n📄 Этап 1: Генерация чистого кода...")
    scripts_dir = scriptsdir(script_name)
    mkpath(scripts_dir)
    
    Literate.script(script_path, scripts_dir;
        credit = false  # не добавлять информацию о генерации
    )
    println("   ✅ Чистый код: $(scripts_dir)/$(script_name).jl")

    # -------------------------------------------------------------------
    # 2. Генерация Quarto-документа
    # -------------------------------------------------------------------
    println("\n📑 Этап 2: Генерация Quarto-документа...")
    quarto_dir = projectdir("markdown", script_name)
    mkpath(quarto_dir)
    
    Literate.markdown(script_path, quarto_dir;
        flavor = Literate.QuartoFlavor(),  # специальный формат для Quarto
        name = script_name,
        credit = false
    )
    println("   ✅ Quarto: $(quarto_dir)/$(script_name).qmd")

    # -------------------------------------------------------------------
    # 3. Генерация Jupyter notebook
    # -------------------------------------------------------------------
    println("\n📓 Этап 3: Генерация Jupyter notebook...")
    notebooks_dir = projectdir("notebooks", script_name)
    mkpath(notebooks_dir)
    
    Literate.notebook(script_path, notebooks_dir;
        name = script_name,
        execute = false,      # не выполнять код при генерации
        credit = false
    )
    println("   ✅ Notebook: $(notebooks_dir)/$(script_name).ipynb")

    # -------------------------------------------------------------------
    # 4. Информация о результате
    # -------------------------------------------------------------------
    println("\n" * "-"^60)
    println("🎉 ГЕНЕРАЦИЯ УСПЕШНО ЗАВЕРШЕНА!")
    println("-"^60)
    println("📁 Созданные файлы:")
    println("   📂 Чистый код:    scripts/$(script_name)/")
    println("   📂 Quarto:         markdown/$(script_name)/")
    println("   📂 Jupyter:        notebooks/$(script_name)/")
    println("\n🕒 Время окончания: $(now())")
    println("="^60)
end

# Запуск, если скрипт выполняется напрямую
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
