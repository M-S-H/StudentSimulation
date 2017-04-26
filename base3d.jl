using BoilingMoon
using DataFrames
using GLM
using Gadfly
include("./helpers/gadfly_theme.jl")
rates = Float64[]
complexities = Float64[]
cases = ["Case1", "Case2", "Case3", "Case4", "Case5", "Case6", "Case7"]

data = DataFrame(complexity=[], passRate=[], gradRate4=[], gradRate5=[], gradRate6=[])
diff_v_coef = DataFrame(diff=Float64[], coef=Float64[])

for d=0:2.5:100
    temp = DataFrame(rates=Float64[], complexity=Float64[])
    for case in cases
        println(case)
        curriculum = Curriculum(case, "curricula/base/$(case).json")
        sim = Simulation(curriculum)
        setPassrates(curriculum.courses, (d/100))

        students = defaultStudents(10000);
        simulate(sim, students, max_credits = 9, duration = 6)
        # println("Complexity: $(curriculum.complexity)")
        # println(passTable(sim))
        # writetable("./results/$(case).csv", passTable(sim))
        # println("\n")

        # push!(rates, sim.gradRate)
        # push!(complexities, curriculum.complexity)
        push!(data, [curriculum.complexity d sim.termGradRates[4] sim.termGradRates[5] sim.termGradRates[6]])
        push!(temp, [sim.termGradRates[5] curriculum.complexity])
    end

    try
        model = glm(rates ~ complexity, temp, Normal(), IdentityLink())
        push!(diff_v_coef, [d coef(model)[2]])
    catch error
        println(error)
    end
end

writetable("./results/diff_v_coef.csv", diff_v_coef)

p = plot(diff_v_coef, x="diff", y="coef", theme)
draw(PNG("./results/diff_v_coef.png", 1920px, 1080px), p)

# data = DataFrame(name = cases, complexity = complexities, gradRate = rates)
writetable("./results/base3d.csv", data)