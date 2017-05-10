if length(ARGS) == 0
    println("Must specify curricula type.")
    exit()
end

if length(ARGS) == 1
    println("Must specify reporting term")
end

using GLM
using Gadfly
using DataFrames
include("helpers/gadfly_theme.jl")

curricula = ARGS[1] 
term = ARGS[2]

cases = readdir("./results/$(curricula)/rates")
println(size(cases))

for dependent in [Symbol(term), :averageTTD]
    println(dependent)
    results = DataFrame(measure=[], difficulty=[], coef=[])

    for case in cases
        println("\t$(case)")

        data = readtable("results/$(curricula)/rates/$(case)")

        if dependent == :averageTTD
            data = data[data[:name] .!= "Biology - 44.json", :]
        end

        # Normalize
        for measure in [:complexity, :delay, :blocking, :centrality, :free, :reachability, :term_complexity]
            println("\t\t$(measure): ")
            mn = minimum(data[measure])
            mx = maximum(data[measure])

            data[measure] = (data[measure] .- mn) ./ (mx-mn)

            Ysym = Symbol(dependent)
            Xsym = Symbol(measure)
            fm = Formula(Ysym, Xsym)

            try
                println("good")
                model = glm(fm, data, Normal(), IdentityLink())
                push!(results, [measure data[:difficulty][1] abs(coef(model)[2])])
            catch error
                println(error)
            end
        end
    end

    println(results)

    p = plot(results, x="difficulty", y="coef", color="measure", theme, Guide.xlabel("Average Pass-Rate"), Guide.ylabel("Regression Coefficient"));
    draw(PNG("results/$(curricula)/coef_$(dependent).png", 1920px, 1080px), p)
end