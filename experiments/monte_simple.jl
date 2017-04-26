using BoilingMoon
using DataFrames
using Gadfly
using GLM
cases = ["Case1", "Case2", "Case3", "Case4", "Case5"]

data = DataFrame(gradRate=Float64[],complexity=Float64[])

for case in cases
    println(case)
    curriculum = Curriculum(case, "curricula/base/$(case).json")
    rates = []
    for i=1:100
        sim = Simulation(curriculum)
        students = defaultStudents(100);
        simulate(sim, students, max_credits = 9, duration = 4)
        push!(rates, sim.gradRate)
        push!(data, [sim.gradRate curriculum.complexity])
    end

    println(mean(rates))


    # println("Complexity: $(curriculum.complexity)")
    # println(passTable(sim))
    println("\n")
end


# Create Plots
theme = Theme(
    background_color = colorant"white"
)
Gadfly.push_theme(theme)

l1 = layer(data, x="complexity", y="gradRate", Geom.point)
ols = glm(gradRate ~ complexity, data, Normal(), IdentityLink())
l2 = layer(x=[0,12], y=[1 0; 1 12]*coef(ols), Geom.line)
p = plot(l1,l2);
draw(PNG("./results/simple.png", 1920px, 1080px), p)

println(ols)