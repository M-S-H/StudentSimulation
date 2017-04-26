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

data = DataFrame(name=[], difficulty=[], complexity=[], blocking=[], delay=[], between=[], free=[], timeComp1=[], timeComp2=[], edges=[], gradRate3=[], gradRate4=[], gradRate5=[], gradRate6=[], gradRate7=[], averageTTD=[])
difficulty_coef = DataFrame(difficulty=Float64[], coef=Float64[])

for d=0.0:2.5:100.0
    for (i, case) in enumerate(cases)
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
        setPassrates(curriculum.courses, (d/100.0))

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

        push!(data, [case d curriculum.complexity curriculum.blocking curriculum.delay b f tc1 tc2 e sim.termGradRates[3] sim.termGradRates[4] sim.termGradRates[5] sim.termGradRates[6] sim.termGradRates[7] sim.timeToDegree])
        toc();
    end
end

writetable("./results/gen$(n)/rates.csv", data)

# Plot

# function regressionPlot(Y, X, data)
#     Ysym = Symbol(Y)
#     Xsym = Symbol(X)
#     fm = Formula(Ysym, Xsym)
#     ols = glm(fm, data, Normal(), IdentityLink())
    
#     l1 = layer(data, x=X, y=Y, Geom.point)
    
#     Xmin = minimum(data[Xsym])
#     Xmax = maximum(data[Xsym])
#     Ymin = minimum(data[Ysym])
#     Ymax = maximum(data[Ysym])
    
#     newData = DataFrame()
#     newData[Xsym] = [Xmin, Xmax]
#     newData
#     newData[Ysym] = predict(ols, newData)
    
#     l2 = layer(newData, x=X, y=Y, Geom.line, Theme(default_color=colorant"red"))
    
#     p = plot(l1,l2,Coord.cartesian(ymin=Ymin, ymax=Ymax, xmin=Xmin, xmax=Xmax), Guide.xlabel("0.088 * Complexity + 1.381 * Credit Hours"), Guide.ylabel("5th Term Completion Rate (%)"))
    
#     return (ols, p)
# end

# l1 = layer(results, x="complexity", y="gradRate8", Geom.point, Theme(default_color=colorant"blue"))
# ols = glm(gradRate8 ~ complexity, results, Normal(), IdentityLink())
# l2 = l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line, Theme(default_color=colorant"blue"))

# p = plot(l1,l2);
# draw(PNG("./results/web/rates8.png", 1920px, 1080px), p)

# l3 = layer(results, x="complexity", y="gradRate10", Geom.point, Theme(default_color=colorant"red"))
# ols = glm(gradRate10 ~ complexity, results, Normal(), IdentityLink())
# l4 = l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line, Theme(default_color=colorant"red"))

# p = plot(l3,l4);
# draw(PNG("./results/web/rates10.png", 1920px, 1080px), p)

# l5 = layer(results, x="complexity", y="gradRate12", Geom.point, Theme(default_color=colorant"green"))
# ols = glm(gradRate12 ~ complexity, results, Normal(), IdentityLink())
# l6 = l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line, Theme(default_color=colorant"green"))

# p = plot(l5,l6);
# draw(PNG("./results/web/rates12.png", 1920px, 1080px), p)