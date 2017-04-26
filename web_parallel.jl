addprocs(4)

@everywhere using BoilingMoon
using DataFrames
using Gadfly
using GLM
include("./helpers/gadfly_theme.jl")
include("./helpers/graphs.jl")

# Simulation Parameters
@everywhere numStudents = 5000
@everywhere itterations = 20
@everywhere reportSem = 8
@everywhere passTableSems = 8
@everywhere coursePassRate = 0.80
@everywhere duration = 12

# Simulation Function
@everywhere function perform_simulation(curriculum_name)
    # Load the curriculum
    curriculum = Curriculum(curriculum_name, "curricula/web/$(curriculum_name)")
    sim = Simulation(curriculum)
    setPassrates(curriculum.courses, coursePassRate)
    students = defaultStudents(numStudents)

    # Simulate
    simulate(sim, students, max_credits = 18, duration = duration, durationLock = true, stopouts = false)

    return [sim]
end


# Load the Curricula
curricula = readdir("./curricula/web")
blacklist = ["Mechanical Engineering 2013-14  - 51.json"]

# Results
results = DataFrame(name=[], complexity=Float64[], delay=[], blocking=[], creditHours=[], free=[], timeComp1=[], timeComp2=[], inverseBlocking=[], inverseDelay=[], centrality=[], gradRate8=Float64[], gradRate10=Float64[], gradRate12=Float64[], averageTTD=[])

@time for (i, c) in enumerate(curricula)
    # Load Curriculum
    curriculum = Curriculum(c, "./curricula/web/$(c)")

    if length(curriculum.terms) >= 8 && sum(map(x -> x.credits, curriculum.courses)) >= 100 && !in(c, blacklist)
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

            # PassTable
            t = passTable(sim)
            for key in names(table)[2:end]
                table[key] += t[key]
            end
        end

        # Average Results
        rates /= itterations
        for key in names(table)[2:end]
            table[key] /= itterations
            table[key] = round(table[key], 2)
        end

        # Write PassTable
        writetable("./results/web/pass_tables/$(c).csv", table)

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

        push!(results, [c complexity delay blocking credits free tc1 tc2 iblocking idelay cent float(round(rates, 2))' ttd])

        toc()
        # # Setup Simulation
        # sim = Simulation(curriculum)
        # setPassrates(curriculum.courses, coursePassRate)
        # students = defaultStudents(numStudents)
        # duration = 12

        # # Perform Simulation
        # simulate(sim, students, max_credits = 18, duration = duration, stopouts = false)

        # push!(results, [c curriculum.complexity sum(map(x -> x.credits, curriculum.courses)) sim.termGradRates[[8,10,12]]'])

        # table = passTable(sim)
        # writetable("./results/pass_tables/$(c).csv", table)
    end
end

writetable("./results/web/rates.csv", results)

l1 = layer(results, x="complexity", y="gradRate8", Geom.point, Theme(default_color=colorant"blue"))
ols = glm(gradRate8 ~ complexity, results, Normal(), IdentityLink())
l2 = l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line, Theme(default_color=colorant"blue"))

p = plot(l1,l2);
draw(PNG("./results/web/rates8.png", 1920px, 1080px), p)

l3 = layer(results, x="complexity", y="gradRate10", Geom.point, Theme(default_color=colorant"red"))
ols = glm(gradRate10 ~ complexity, results, Normal(), IdentityLink())
l4 = l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line, Theme(default_color=colorant"red"))

p = plot(l3,l4);
draw(PNG("./results/web/rates10.png", 1920px, 1080px), p)

l5 = layer(results, x="complexity", y="gradRate12", Geom.point, Theme(default_color=colorant"green"))
ols = glm(gradRate12 ~ complexity, results, Normal(), IdentityLink())
l6 = l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line, Theme(default_color=colorant"green"))

p = plot(l5,l6);
draw(PNG("./results/web/rates12.png", 1920px, 1080px), p)




