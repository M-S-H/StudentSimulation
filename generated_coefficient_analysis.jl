using GLM
using Gadfly
using DataFrames
include("helpers/gadfly_theme.jl")

cases = readdir("./results/gen6/rates")

results = DataFrame(measure=[], difficulty=[], coef=[])

for case in cases
    println(case)

    data = readtable("results/gen6/rates/$(case)")

    # Normalize
    for measure in [:complexity, :delay, :blocking, :centrality, :free, :reachability, :term_complexity]
        mn = minimum(data[measure])
        mx = maximum(data[measure])

        data[measure] = (data[measure] .- mn) ./ (mx-mn)
    end

    # Complexity
    try
        model = glm(averageTTD ~ complexity, data, Normal(), IdentityLink())
        push!(results, ["complexity" data[:difficulty][1] abs(coef(model)[2])])
    catch error
        println(error)
    end

    try
        model = glm(averageTTD ~ delay, data, Normal(), IdentityLink())
        push!(results, ["delay" data[:difficulty][1] abs(coef(model)[2])])
    catch error
        println(error)
    end

    try
        model = glm(averageTTD ~ blocking, data, Normal(), IdentityLink())
        push!(results, ["blocking" data[:difficulty][1] abs(coef(model)[2])])
    catch error
        println(error)
    end

    # Centrality
    try
        model = glm(averageTTD ~ centrality, data, Normal(), IdentityLink())
        push!(results, ["centrality" data[:difficulty][1] abs(coef(model)[2])])
    catch error
        println(error)
    end

    # Free
    try
        model = glm(averageTTD ~ free, data, Normal(), IdentityLink())
        push!(results, ["free" data[:difficulty][1] abs(coef(model)[2])])
    catch error
        println(error)
    end

    # Reachability
    try
        model = glm(averageTTD ~ reachability, data, Normal(), IdentityLink())
        push!(results, ["reachability" data[:difficulty][1] abs(coef(model)[2])])
    catch error
        println(error)
    end

    # Reachability
    try
        model = glm(averageTTD ~ term_complexity, data, Normal(), IdentityLink())
        push!(results, ["term_complexity" data[:difficulty][1] abs(coef(model)[2])])
    catch error
        println(error)
    end
end

# results[:coef] = abs(results[:coef])

p = plot(results, x="difficulty", y="coef", color="measure", theme);

draw(PNG("results/gen6/coef_ttd_norm.png", 1920px, 1080px), p)