# This experiment varries the passrate of each course with a complexity
# greater than one and measures the effect it has on the completion rate

# Add Processes
addprocs(4)

# Dependencies
@everywhere using BoilingMoon
@everywhere using DataFrames
using Gadfly

# Simulation Variables
@everywhere numStudents = 500
@everywhere itterations = 20
@everywhere semesters = 8
@everywhere reportSem = 8
@everywhere passTableSems = 8
@everywhere curriculumName = "ComputerEngineering"


# Base Curriculum and Simulations
baseCurriculum = Curriculum("$(curriculumName)", "curricula/$(curriculumName).json")
baseSimulation = Simulation(baseCurriculum)


# Define the Simulation Function
# i is the index of the course to be varried
@everywhere function perform_simulation(i)
    # Load the curriculum and Simulation
    curriculum = Curriculum("$(curriculumName)", "curricula/$(curriculumName).json");
    sim = Simulation(curriculum)
    setPassrates(curriculum.courses, 0.90);

    # Increase Passrate
    if i > 0
        curriculum.courses[i].model[:passrate] = 0.50
        if curriculum.courses[i].model[:passrate] > 1
            curriculum.courses[i].model[:passrate] = 1
        end
    end

    # Perform Simulation
    students = defaultStudents(numStudents);
    simulate(sim, students, max_credits = 18, duration = semesters, stopouts = false)
    return sim
end


# Perform Baseline Simulations
tic()
simulations = pmap(perform_simulation, zeros(itterations))
toc()
baseGradRate = sum(map(x->x.gradRate, simulations)) / itterations


# Results
results = DataFrame(name=[], original=[], new=[], delay=[], blocking=[], cruciality=[], centrality=[], reachability=[], total=[], term=[], difference=[])


# Itterate over all courses
for (t, term) in enumerate(baseCurriculum.terms)
    for (c, course) in enumerate(term.courses)
        println(course.name)

        if (course.cruciality) > 1

            # Perform Simulations
            simulations = @parallel (vcat) for i=1:itterations
                perform_simulation(c)
            end

            # GradRate
            gradRate = sum(map(x->x.gradRate, simulations)) / itterations

            total = course.cruciality + course.centrality + course.reachability

            newPassrate = course.model[:passrate] * 1.3
            if newPassrate > 1
                newPassrate = 1
            end

            # Push Results
            push!(results, [course.name, round(course.passrate, 4), round(newPassrate, 4), course.delay, course.blocking, course.cruciality, course.centrality, course.reachability, total, t, gradRate - baseGradRate])
        end
    end
end

writetable("./results/sensitivity/$(curriculumName)_sensitivity_reverse.csv", results)

# for (t, term) in enumerate(baseCurriculum.terms)
#     for(c, course) in enumerate(term.courses)
#         println(course.name)
#         if (course.cruciality > 1)
#             # Perform Simulations
#             simulations = pmap(perform_simulation, [course.id for i=1:itterations])

#             gradRate = sum(map(x->x.gradRate, simulations)) / itterations

#             newPassrate = course.passrate * 1.3
#             if newPassrate > 1
#                 newPassrate = 1
#             end
#             push!(results, [course.name, round(course.passrate, 4), round(newPassrate, 4), course.cruciality, t, gradRate - baseGradRate])
#         end
#     end
# end

# writetable("./results/sensitivity/$(curriculumName)_sensitivity.csv", results)