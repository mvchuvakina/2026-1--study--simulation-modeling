#!/usr/bin/env julia
using DrWatson
@quickactivate
using Literate

function main()
    if length(ARGS) == 0
        println("Использование: julia tangle.jl <путь_к_скрипту>")
        return
    end
    
    script_path = ARGS[1]
    script_name = splitext(basename(script_path))[1]
    
    println("Генерация из: $script_path")
    
    # Чистый скрипт
    scripts_dir = scriptsdir(script_name)
    mkpath(scripts_dir)
    Literate.script(script_path, scripts_dir; credit=false)
    println("  ✓ Чистый скрипт создан")
    
    # Quarto-документ
    quarto_dir = projectdir("markdown", script_name)
    mkpath(quarto_dir)
    Literate.markdown(script_path, quarto_dir; 
                     flavor=Literate.QuartoFlavor(),
                     name=script_name, credit=false)
    println("  ✓ Quarto документ создан")
    
    # Jupyter notebook
    notebooks_dir = projectdir("notebooks", script_name)
    mkpath(notebooks_dir)
    Literate.notebook(script_path, notebooks_dir, name=script_name;
                     execute=false, credit=false)
    println("  ✓ Jupyter notebook создан")
    
    println("\nГотово!")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
