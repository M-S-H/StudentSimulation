# Number of processes
if length(ARGS) != 0
    addprocs(parse(Int64, ARGS[1]))
end

# Libraries
@everywhere using BoilingMoon
@everywhere using DataFrames
@everywhere using LightGraphs

# All Curriculum Files
@everywhere curricula = readdir("./curricula/gen6")

# Simulation Function
@everywhere function perform_simulation(difficulty)
    # Results
    results = data = DataFrame(name=[], difficulty=[], complexity=[], blocking=[], delay=[], centrality=[], reachability=[], term_complexity=[], term_blocking=[], term_delay=[], term_centrality=[], term_reachability=[], free=[], edges=[], gradRate3=[], gradRate4=[], gradRate5=[], gradRate6=[], gradRate7=[], averageTTD=[])

    # Itterate through all curriculum
    for (i, c) in enumerate(curricula)
        print("$(c) : ")
        

        # Load Curriculum
        curriculum = Curriculum(c, "curricula/gen6/$(c)")

        # Setup Simulation
        sim = Simulation(curriculum)
        setPassrates(curriculum.courses, (difficulty/100.0))

        # Students
        students = defaultStudents(5000)

        # Run the simulation
        tic()
        simulate(sim, students, max_credits = 9, duration = 1000)
        toc()

        # Construct measures
        term_blocking = sum(map(x->x.blocking*x.term, curriculum.courses))
        term_delay = sum(map(x->x.delay*x.term, curriculum.courses))
        term_complexity = term_blocking + term_delay
        term_centrality = sum(map(x->x.centrality*x.term, curriculum.courses))
        term_reachability = sum(map(x->x.reachability*x.term, curriculum.courses))
        free = f = length(find(x->length(x.prereqs)==0, curriculum.courses))
        edges = ne(curriculum.graph)

        # Push results
        push!(results, [c difficulty curriculum.complexity curriculum.blocking curriculum.delay curriculum.centrality curriculum.reachability term_complexity term_blocking term_delay term_centrality term_reachability free edges float(round(sim.termGradRates[3:7], 2))' sim.timeToDegree])
    end

    # Write the results to a csv
    writetable("./results/gen6/rates/rates_$(difficulty).csv", results)
end


# Itterate through various difficulties
difficulties = 10.0:2.5:100.0
if length(ARGS) != 0
    pmap(perform_simulation, collect(difficulties))
else
    println("no stuff")
    for difficulty = difficulties
        perform_simulation(difficulty)
    end    
end

# for difficulty = 0.0:2.5:100.0
#     if length(ARGS) != 0
        
#     else

#     end
# end