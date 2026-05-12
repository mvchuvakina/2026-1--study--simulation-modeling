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
    
    Literate.script(script_path, scriptsdir(script_name); credit=false)
    Literate.markdown(script_path, projectdir("markdown", script_name); 
                      flavor=Literate.QuartoFlavor(), name=script_name, credit=false)
    Literate.notebook(script_path, projectdir("notebooks", script_name); 
                      name=script_name, execute=false, credit=false)
    println("✅ Готово!")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
