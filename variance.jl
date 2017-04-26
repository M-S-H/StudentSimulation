using BoilingMoon
using DataFrames
using Gadfly
using GLM
include("./helpers/gadfly_theme.jl")
include("./helpers/graphs.jl")

curriculum = Curriculum("COMP", "./curricula/ComputerEngineering.json")

difference = []

for num in [100, 500, 1000, 5000, 10000]
    println(num)
    sim = Simulation(curriculum)
    setPassrates(curriculum.courses, 0.8)
    students = defaultStudents(num)

    # Simulate
    simulate(sim, students, max_credits = 18, duration = 12, durationLock = true, stopouts = false)
    rate1 = sim.termGradRates[10]

    simulate(sim, students, max_credits = 18, duration = 12, durationLock = true, stopouts = false)
    rate2 = sim.termGradRates[10]

    push!(difference, abs(rate1-rate2))
    println(difference)
end

println(difference)





# # Simulation Parameters
# numStudents = 1000
# itterations = 100
# reportSem = 8
# passTableSems = 8
# coursePassRate = 0.80
# duration = 12

# # Simulation Function
# @everywhere function perform_simulation(i)
#     # Load the curriculum
#     curriculum = Curriculum(curricula[i], "curricula/web/$(curricula[i])")
#     sim = Simulation(curriculum)
#     setPassrates(curriculum.courses, coursePassRate)
#     students = defaultStudents(numStudents)

#     # Simulate
#     simulate(sim, students, max_credits = 18, duration = duration, durationLock = true, stopouts = false)

#     return sim
# end


# # Load the Curricula
# @everywhere curricula = readdir("./curricula/web")

# # Results
# results = DataFrame(name=[], complexity=Float64[], delay=[], blocking=[], creditHours=[], free=[], timeComp1=[], timeComp2=[], inverseBlocking=[], inverseDelay=[], gradRate8=Float64[], gradRate10=Float64[], gradRate12=Float64[], averageTTD=[])

# for (i, c) in enumerate(curricula)
#     # Load Curriculum
#     curriculum = Curriculum(c, "./curricula/web/$(c)")

#     if length(curriculum.terms) >= 8 && sum(map(x -> x.credits, curriculum.courses)) >= 100
#         println(c)

#         tic()
#         # Perform Simulations
#         sim = Simulation(curriculum)
#         setPassrates(curriculum.courses, coursePassRate)
#         students = defaultStudents(numStudents)

#         # Simulate
#         simulate(sim, students, max_credits = 18, duration = duration, durationLock = true, stopouts = false)
#         toc()

#         rates = sim.termGradRates[[8,10,12]]
#         table = passTable(sim)

#         # Sum Results
#         # for (i, sim) in enumerate(sims[2:end])
#         #     # GradRates
#         #     rates += sim.termGradRates[[8,10,12]]

#         #     # PassTable
#         #     t = passTable(sim)
#         #     for key in names(table)[2:end]
#         #         table[key] += t[key]
#         #     end
#         # end

#         # Average Results
#         # rates /= itterations
#         # for key in names(table)[2:end]
#         #     table[key] /= itterations
#         #     table[key] = round(table[key], 2)
#         # end

#         # Write PassTable
#         writetable("./results/web/pass_tables/$(c).csv", table)

#         # Time Complexities
#         tc1 = 0
#         tc2 = 0
#         for (j, term) in enumerate(curriculum.terms)
#             for course in term.courses
#                 tc1 += course.cruciality * j
#                 tc2 += course.cruciality + j
#             end
#         end

#         tic()
#         # TTD
#         sim = Simulation(curriculum)
#         students = defaultStudents(1000)
#         simulate(sim, students, max_credits = 18, duration = 12, stopouts = false)
#         ttd = sim.timeToDegree
#         toc()

#         # Inverse Blocking & Delay
#         ic = inverseCurriculum(curriculum)
#         iblocking = float(ic.blocking)
#         idelay = float(ic.delay)


#         # Push results
#         complexity = float(curriculum.complexity)
#         delay = float(curriculum.delay)
#         blocking = float(curriculum.blocking)
#         credits = sum(map(x -> x.credits, curriculum.courses))
#         free = length(find(x->length(x.prereqs)==0, curriculum.courses))

#         push!(results, [c complexity delay blocking credits free tc1 tc2 iblocking idelay float(round(rates, 2))' ttd])
#     end
# end