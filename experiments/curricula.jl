using BoilingMoon
using Gadfly

for case in ["Accounting", "AccountingDetailed", "Biochemistry", "ComputerEngineering", "ComputerEngineeringDetailed", "MechanicalEngineering", "ChemicalEngineering"]
    println(case)
    curriculum = Curriculum(case, "curricula/$(case).json")
    sim = Simulation(curriculum)
    # setPassrates(curriculum.courses, 0.8);
    students = defaultStudents(10000);
    simulate(sim, students, max_credits = 15, duration = 20, stopouts = true)
    println("Complexity: $(curriculum.complexity)")
    println("Difficulty: $(curriculum.passrate)")
    println("Grad Rates: $(sim.termGradRates[8:12])")
    println("Stopout Rates: $(sim.termStopoutRates)")
    #println("5yr Grad Rate: $(sim.termGradRates[10])")
    println("Avg TTG: $(sim.timeToDegree)")
    println("\n")
end