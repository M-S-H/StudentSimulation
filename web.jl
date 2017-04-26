using BoilingMoon
using DataFrames
using Gadfly
using GLM
include("./helpers/gadfly_theme.jl")
include("./helpers/graphs.jl")

# Simulation Parameters
numStudents = 1000
itterations = 100
reportSem = 8
passTableSems = 8
coursePassRate = 0.80
duration = 12

# Simulation Function
@everywhere function perform_simulation(i)
    # Load the curriculum
    curriculum = Curriculum(curricula[i], "curricula/web/$(curricula[i])")
    sim = Simulation(curriculum)
    setPassrates(curriculum.courses, coursePassRate)
    students = defaultStudents(numStudents)

    # Simulate
    simulate(sim, students, max_credits = 18, duration = duration, durationLock = true, stopouts = false)

    return sim
end


# Load the Curricula
@everywhere curricula = readdir("./curricula/web")

# Results
results = DataFrame(name=[], complexity=Float64[], delay=[], blocking=[], creditHours=[], free=[], timeComp1=[], timeComp2=[], inverseBlocking=[], inverseDelay=[], gradRate8=Float64[], gradRate10=Float64[], gradRate12=Float64[], averageTTD=[])

for (i, c) in enumerate(curricula)
    # Load Curriculum
    curriculum = Curriculum(c, "./curricula/web/$(c)")

    if length(curriculum.terms) >= 8 && sum(map(x -> x.credits, curriculum.courses)) >= 100
        println(c)

        tic()
        # Perform Simulations
        sim = Simulation(curriculum)
        setPassrates(curriculum.courses, coursePassRate)
        students = defaultStudents(numStudents)

        # Simulate
        simulate(sim, students, max_credits = 18, duration = duration, durationLock = true, stopouts = false)
        toc()

        rates = sim.termGradRates[[8,10,12]]
        table = passTable(sim)

        # Sum Results
        # for (i, sim) in enumerate(sims[2:end])
        #     # GradRates
        #     rates += sim.termGradRates[[8,10,12]]

        #     # PassTable
        #     t = passTable(sim)
        #     for key in names(table)[2:end]
        #         table[key] += t[key]
        #     end
        # end

        # Average Results
        # rates /= itterations
        # for key in names(table)[2:end]
        #     table[key] /= itterations
        #     table[key] = round(table[key], 2)
        # end

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

        tic()
        # TTD
        sim = Simulation(curriculum)
        students = defaultStudents(1000)
        simulate(sim, students, max_credits = 18, duration = 12, stopouts = false)
        ttd = sim.timeToDegree
        toc()

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

        push!(results, [c complexity delay blocking credits free tc1 tc2 iblocking idelay float(round(rates, 2))' ttd])

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