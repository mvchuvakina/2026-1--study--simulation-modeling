#!/usr/bin/env julia
# tangle.jl - Генератор отчетов из Literate-скриптов

using DrWatson
@quickactivate

using Literate

function main()
    if length(ARGS) == 0
        println("""
        Использование: julia tangle.jl <путь_к_скрипту>
        
        Примеры:
          julia tangle.jl scripts/sirpetri_run_literate.jl
        """)
        return
    end
    
    script_path = ARGS[1]
    
    if !isfile(script_path)
        error("Файл не найден: $script_path")
    end
    
    script_name = splitext(basename(script_path))[1]
    
    println("Генерация из: $script_path")
    
    # Создаём директории
    mkpath(scriptsdir(script_name))
    mkpath(projectdir("markdown", script_name))
    mkpath(projectdir("notebooks", script_name))
    
    # Чистый скрипт
    Literate.script(script_path, scriptsdir(script_name); credit=false)
    println("  ✓ Чистый скрипт: $(scriptsdir(script_name))/$(script_name).jl")
    
    # Quarto-документ
    quarto_dir = projectdir("markdown", script_name)
    Literate.markdown(script_path, quarto_dir;
        flavor = Literate.QuartoFlavor(),
        name = script_name, credit=false)
    println("  ✓ Quarto: $(quarto_dir)/$(script_name).qmd")
    
    # Jupyter notebook
    notebooks_dir = projectdir("notebooks", script_name)
    Literate.notebook(script_path, notebooks_dir, name=script_name;
        execute = false, credit=false)
    println("  ✓ Notebook: $(notebooks_dir)/$(script_name).ipynb")
    
    println()
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
