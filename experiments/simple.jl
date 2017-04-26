using BoilingMoon
using DataFrames
rates = Float64[]
complexities = Float64[]
cases = ["Case1", "Case2", "Case3", "Case4", "Case5"]

for case in cases
    println(case)
    curriculum = Curriculum(case, "curricula/base/$(case).json")
    sim = Simulation(curriculum)
    students = defaultStudents(10000);
    simulate(sim, students, max_credits = 9, duration = 4)
    println("Complexity: $(curriculum.complexity)")
    println(passTable(sim))
    println("\n")

    push!(rates, sim.gradRate)
    push!(complexities, curriculum.complexity)
end

data = DataFrame(name = cases, complexity = complexities, gradRate = rates)
writetable("./results/simple.csv", data)