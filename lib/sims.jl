function sensitivity(curriculum; diff=0.1)
    students = passRateStudents(100);

    sim = Simulation(c, [], [], PassRate);

    rates = []

    for j=1:20
        simulate(sim, students, numTerms = 10, stopouts = false, locked_terms = false);
        push!(rates, sim.gradRate)
    end

    baseRate = mean(rates)
    println(baseRate)

    results = DataFrame(Name=[], Complexity=[], Term=[], Sensitivity=[])

    for (termNum, term) in enumerate(curriculum.terms)
        for course in term.courses
            println(course.name)
            oldRate = course.model[:passrate]
            course.model[:passrate] += diff

            rates = []

            for j=1:20
                simulate(sim, students, numTerms = 10, stopouts = false, locked_terms = false);
                push!(rates, sim.gradRate)
            end
            
            # sens = (sim.gradRate - baseRate) / (course.model[:passrate] - oldRate)
            sens = (mean(rates) - baseRate)

            course.model[:passrate] = oldRate

            push!(results, [course.name, course.cruciality, termNum, sens])
        end
    end

    sort!(results, cols=:Sensitivity, rev=true)
    println(results)
    results
end