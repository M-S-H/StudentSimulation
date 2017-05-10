# Number of processes
if length(ARGS) != 0
    addprocs(parse(Int64, ARGS[1]))
end

# Libraries
@everywhere using CASL
@everywhere using DataFrames
@everywhere using LightGraphs

# All Curriculum Files
# @everywhere curricula = readdir("./curricula/web")
@everywhere data = readtable("./results/web/rates.csv");
@everywhere data = data[data[:creditHours] .< 150, :];
@everywhere curricula = data[:name];

# Simulation Function
@everywhere function perform_simulation(difficulty)
    # Results
    results = data = DataFrame(name=[], credits=[], difficulty=[], complexity=[], blocking=[], delay=[], centrality=[], reachability=[], term_complexity=[], term_blocking=[], term_delay=[], term_centrality=[], term_reachability=[], free=[], edges=[], gradRate8=[], gradRate9=[], gradRate10=[], gradRate11=[], gradRate12=[], averageTTD=[])

    # Itterate through all curriculum
    for (i, c) in enumerate(curricula)
        print("$(c) : ")

        # Load Curriculum
        curriculum = Curriculum(c, "curricula/web/$(c)")

        # Setup Simulation
        setPassrates(curriculum.courses, (difficulty/100.0))

        # Students
        students = simpleStudents(5000)

        # Run the simulation
        tic()
        sim = simulate(curriculum, students, max_credits = 18, duration = 1000)
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
        push!(results, [c curriculum.creditHours difficulty curriculum.complexity curriculum.blocking curriculum.delay curriculum.centrality curriculum.reachability term_complexity term_blocking term_delay term_centrality term_reachability free edges float(round(sim.termGradRates[8:12], 2))' sim.timeToDegree])
    
        # Garbage Collect
        curriculum = 0
        students = 0
        sim = 0
        gc()
    end

    # Write the results to a csv
    writetable("./results/web/rates/rates_$(difficulty).csv", results)
end


# Itterate through various difficulties
difficulties = 30.0:5.0:100.0
if length(ARGS) != 0
    pmap(perform_simulation, collect(difficulties))
else
    for difficulty in collect(difficulties)
        perform_simulation(difficulty)
    end    
end

# for difficulty = 0.0:2.5:100.0
#     if length(ARGS) != 0
        
#     else

#     end
# end