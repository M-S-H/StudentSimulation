using BoilingMoon
using Gadfly
using DataFrames
using GLM
include("./helpers/gadfly_theme.jl")

curricula = readdir("./curricula/web")
complexities = Float64[]
blocking = Float64[]
delay = Float64[]
rates = Float64[]
names = []
gini_indicies = Float64[]
terms = Float64[]
free = Float64[]
courses = Float64[]
credits = Float64[]

function gini(x)
    t = 0
    b = 0
    for i=1:length(x)
        for j=1:length(x)
            t += abs(x[i] - x[j])
        end
        b += x[i]
    end

    return t / (2*length(x)*b)
end

for c in curricula
    println(c)
    curriculum = Curriculum(c, "./curricula/web/$(c)")

    sim = Simulation(curriculum)
    setPassrates(curriculum.courses, 0.8);
    students = defaultStudents(1000);

    # Graduation Rate Simulation
    dur = length(curriculum.terms) + 2
    simulate(sim, students, max_credits = 18, duration = dur, stopouts = false)
    push!(complexities, float(curriculum.complexity))
    push!(blocking, float(curriculum.blocking))
    push!(delay, float(curriculum.delay))
    push!(rates, sim.gradRate)
    push!(names, c)
    push!(terms, length(curriculum.terms))
    push!(credits, sum(map(x -> x.credits, curriculum.courses)))

    freeCourses = 0
    for course in curriculum.courses
        if length(course.prereqs) == 0 && length(course.coreqs) == 0
            freeCourses += 1
        end
    end
    push!(free, freeCourses)

    push!(courses, curriculum.numCourses)

    comps = map(x -> x.cruciality, curriculum.courses)
    push!(gini_indicies, gini(comps))

    table = passTable(sim)
    writetable("./results/tables/$(c).csv", table)
end

# Save results
data = DataFrame(name = names, complexity = complexities, blocking = blocking, delay = delay, gradRate = rates, gini_index = gini_indicies, free=free, terms = terms, courses = courses, credits = credits)
writetable("./results/ratesComp.csv", data)


# Grad Rates
l1 = layer(x=complexities, y=rates, Geom.point)
ols = glm(gradRate ~ complexity, data, Normal(), IdentityLink())
l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line)
p = plot(l1,l2);
draw(PNG("./results/rates.png", 1920px, 1080px), p)


# Normalize data
rate_mean = mean(data[:gradRate])
rate_std = std(data[:gradRate])
complexity_mean = mean(data[:complexity])
complexity_std = std(data[:complexity])

data[:gradRate] = data[:gradRate] .- rate_mean
data[:gradRate] = data[:gradRate] ./ rate_std

data[:complexity] = data[:complexity] .- complexity_mean
data[:complexity] = data[:complexity] ./ complexity_std

ols = glm(gradRate ~ complexity, data, Normal(), IdentityLink())
println(ols)