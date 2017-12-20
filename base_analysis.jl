# Performans analysis over the base curricula

using CASL
using DataFrames
using GLM
using Gadfly
include("./helpers/gadfly_theme.jl")

# Get array of curriculum names
curricula = ["Case1", "Case2", "Case3", "Case4", "Case5", "Case6", "Case7"]

# Parameters
numstudents = 10000
passrate = 0.5

completion = DataFrame(name=[], complexity=[], completionRate2=[], completionRate3=[], completionRate4=[], completionRate5=[])
time_to_degree = DataFrame(name=[], complexity=[], averageTTD=[])

# Perform simulations
for name in curricula
    curriculum = Curriculum(name, "./curricula/base/$(name).json")
    setPassrates(curriculum.courses, passrate)
    students = simpleStudents(numstudents)

    sim = simulate(curriculum, students, max_credits = 9, duration = 100)

    table = passTable(sim, 5)
    writetable("./results/base/tables/$(name).csv", table)
    println("$(name): Complexity $(curriculum.complexity)")
    println(table)
    println("\n")

    push!(completion, [name curriculum.complexity sim.termGradRates[2:5]'])
    push!(time_to_degree, [name curriculum.complexity sim.timeToDegree])
end

# Write results
writetable("./results/base/completion_rates.csv", completion)
writetable("./results/base/average_ttd.csv", time_to_degree)

# Plots
layers = []
colors = [colorant"crimson", colorant"steelblue", colorant"orange", colorant"green"]
for t = 2:5
    l = layer(completion, x="complexity", y="completionRate$(t)", Geom.point, Theme(default_color = colors[t-1], default_point_size=5px))
    push!(layers, l)

    p = plot(l, 
    Theme(theme),
    Guide.xlabel("Curriculum Complexity"),
    Guide.ylabel("Completion Rate"))
    draw(PNG("./results/base/completion_rates_$(t).png", 1920px, 1080px), p)
end

p = plot(layers[1], layers[2], layers[3], layers[4], 
    Theme(theme),
    Guide.manual_color_key("", ["Term 2", "Term 3", "Term 4", "Term 5"], colors),
    Guide.xlabel("Curriculum Complexity"),
    Guide.ylabel("Completion Rate"))
draw(PNG("./results/base/completion_rates.png", 1920px, 1080px), p)

p = plot(time_to_degree, 
    x="complexity",
    y="averageTTD", 
    Geom.point,
    Theme(theme), 
    Guide.xlabel("Curriculum Complexity"),
    Guide.ylabel("Average Time To Degree"))
draw(PNG("./results/base/average_ttd.png", 1920px, 1080px), p)
