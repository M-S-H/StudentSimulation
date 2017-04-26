using BoilingMoon
using DataFrames
using Gadfly
using GLM
include("./helpers/graphs.jl")
include("./helpers/gadfly_theme.jl")

rates = Float64[]
complexities = Float64[]

n = "6"

cases = readdir("./curricula/gen$(n)")

data = DataFrame(name=[], complexity=[], blocking=[], delay=[], between=[], free=[], timeComp1=[], timeComp2=[], edges=[], gradRate3=[], gradRate4=[], gradRate5=[], gradRate6=[], gradRate7=[], averageTTD=[])

for (i, case) in enumerate(cases[1:2])
    tic();
    print(i)
    print(" - ")
    print(case)
    print(" : ")
    curriculum = Curriculum(case, "curricula/gen$(n)/$(case)")
    sim = Simulation(curriculum)

    students = defaultStudents(5000);
    simulate(sim, students, max_credits = 9, duration = 100);
    g = curriculumGraph(curriculum)

    tc1 = 0
    tc2 = 0
    for (i, term) in enumerate(curriculum.terms)
        for course in term.courses
            tc1 += course.cruciality * i
            tc2 += course.cruciality + i
        end
    end

    b = sum(betweenness_centrality(g, normalize=false))
    f = length(find(x->length(x.prereqs)==0, curriculum.courses))
    e = ne(g)

    push!(data, [case curriculum.complexity curriculum.blocking curriculum.delay b f tc1 tc2 e sim.termGradRates[3] sim.termGradRates[4] sim.termGradRates[5] sim.termGradRates[6] sim.termGradRates[7] sim.timeToDegree])
    toc();
end

writetable("./results/gen$(n)/rates.csv", data)