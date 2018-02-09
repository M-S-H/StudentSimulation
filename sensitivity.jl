using DataFrames
using CASL

# curriculumName = "ComputerEngineering.json"
numStudents = 5000

# basePassRate = 0.8
passratePairs = [[0.8, 1.0], [0.6, 1.0], [1.0, 0.8], [1.0, 0.6]]
curricula = readdir("./curricula/unm")

curricula = ["ComputerEngineering.json"]

for curriculumName in curricula
  println(curriculumName)

  for pair in passratePairs
    println("\t$(pair)")

    results = DataFrame(course=[], term=[], difference8=[], difference10=[], difference12=[], credits=[], blocking=[], delay=[], centrality=[], reachability=[])
    basePassRate = pair[1]
    newPassRate = pair[2]

    # Baseline Simulation
    curriculum = Curriculum(curriculumName, "curricula/unm/$(curriculumName)")
    setPassrates(curriculum.courses, basePassRate)

    students = simpleStudents(numStudents)

    sim = simulate(curriculum, students, max_credits = 18, duration=12)
    base8 = sim.termGradRates[8]
    base10 = sim.termGradRates[10]
    base12 = sim.termGradRates[12]


    # Sensitivity Analysis
    for (i, term) in enumerate(curriculum.terms)
      for course in term.courses
        # println(course.name)

        students = simpleStudents(numStudents)
        course.passrate = newPassRate
        sim = simulate(curriculum, students, max_credits = 18, duration=12)
        diff8 = sim.termGradRates[8] - base8
        diff10 = sim.termGradRates[10] - base10
        diff12 = sim.termGradRates[12] - base12

        push!(results, [course.name i diff8 diff10 diff12 course.credits course.blocking course.delay course.centrality course.reachability])
        course.passrate = basePassRate
      end
    end
    
    writetable("./results/sensitivity/$(curriculumName)_$(pair[1])_to_$(pair[2]).csv", results)
  end
end




