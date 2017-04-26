addprocs(4)

@everywhere using BoilingMoon
using DataFrames
using Gadfly
using GLM
include("./helpers/gadfly_theme.jl")
include("./helpers/graphs.jl")

# Simulation Parameters
@everywhere numStudents = 1250
@everywhere itterations = 4
@everywhere reportSem = 8
@everywhere passTableSems = 8
@everywhere coursePassRate = 0.80
@everywhere duration = 12

# Simulation Function
@everywhere function perform_simulation(curriculum_name)
    # Load the curriculum
    curriculum = Curriculum(curriculum_name, "curricula/gen40/$(curriculum_name)")
    sim = Simulation(curriculum)
    setPassrates(curriculum.courses, coursePassRate)
    students = defaultStudents(numStudents)

    # Simulate
    simulate(sim, students, max_credits = 18, duration = duration, durationLock = true, stopouts = false)

    return [sim]
end


# Load the Curricula
curricula = readdir("./curricula/gen40")

# Results
# results = DataFrame(name=[], complexity=Float64[], delay=[], blocking=[], creditHours=[], free=[], timeComp1=[], timeComp2=[], inverseBlocking=[], inverseDelay=[], centrality=[], gradRate8=Float64[], gradRate10=Float64[], gradRate12=Float64[], averageTTD=[])

@time for (i, c) in enumerate(curricula)
    # Load Curriculum
    curriculum = Curriculum(c, "./curricula/gen40/$(c)")

    tic()
    println(c)

    # Perform Simulations
    # sims = pmap(perform_simulation, [i for j=1:itterations])
    sims = @parallel (vcat) for i=1:itterations
        perform_simulation(c)
    end;

    rates = sims[1].termGradRates[[8,10,12]]
    table = passTable(sims[1])

    # Sum Results
    for (i, sim) in enumerate(sims[2:end])
        # GradRates
        rates += sim.termGradRates[[8,10,12]]
    end

    # Average Results
    rates /= itterations

    # Write PassTable
    # writetable("./results/web/pass_tables/$(c).csv", table)

    # Time Complexities
    tc1 = 0
    tc2 = 0
    for (j, term) in enumerate(curriculum.terms)
        for course in term.courses
            tc1 += course.cruciality * j
            tc2 += course.cruciality + j
        end
    end


    # TTD
    sim = Simulation(curriculum);
    students = defaultStudents(numStudents);
    setPassrates(curriculum.courses, coursePassRate);
    simulate(sim, students, max_credits = 18, duration = 50, stopouts = false);
    ttd = sim.timeToDegree

    # Inverse Blocking & Delay
    ic = inverseCurriculum(curriculum)
    iblocking = float(ic.blocking)
    idelay = float(ic.delay)


    # Push results
    complexity = float(curriculum.complexity)
    delay = float(curriculum.delay)
    blocking = float(curriculum.blocking)
    credits = sum(map(x -> x.credits, curriculum.courses))
    free = length(find(x->length(x.prereqs)==0, curriculum.courses))
    cent = centrality(curriculum)

    # push!(results, [c complexity delay blocking credits free tc1 tc2 iblocking idelay cent float(round(rates, 2))' ttd])

    row = join([c complexity delay blocking credits free tc1 tc2 iblocking idelay cent float(round(rates, 2))' ttd], ",")
    row = "$(row)\n"
    f = open("./results/gen40/rates.csv", "a")
    write(f, row)
    close(f)

    toc()
end