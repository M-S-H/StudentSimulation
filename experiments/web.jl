using BoilingMoon
using Gadfly
using DataFrames
using GLM

curricula = readdir("./curricula/web")
grad_complexities = Float64[]
grad_blocking = Float64[]
grad_delay = Float64[]
grad_rates = Float64[]
grad_names = []
ttd_names = []
ttd_complexities = Float64[]
ttd_blocking = Float64[]
ttd_delay = Float64[]
ttd = Float64[]
gini_indicies = Float64[]

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
    simulate(sim, students, max_credits = 18, duration = dur, stopouts = true)
    push!(grad_complexities, float(curriculum.complexity))
    push!(grad_blocking, float(curriculum.blocking))
    push!(grad_delay, float(curriculum.delay))
    push!(grad_rates, sim.gradRate)
    push!(grad_names, c)

    comps = map(x -> x.cruciality, curriculum.courses)
    push!(gini_indicies, gini(comps))

    # Time-To-Degree Simulation
    simulate(sim, students, max_credits = 18, duration = 100, stopouts = true)
    if sim.timeToDegree < 100
        push!(ttd_complexities, float(curriculum.complexity))
        push!(ttd_blocking, float(curriculum.blocking))
        push!(ttd_delay, float(curriculum.delay))
        push!(ttd, sim.timeToDegree)
        push!(ttd_names, c)
    end
end

# Save results
d1 = DataFrame(name = grad_names, complexity = grad_complexities, blocking = grad_blocking, delay = grad_delay, gradRate = grad_rates, gini_index = gini_indicies)
writetable("./results/rates.csv", d1)

d2 = DataFrame(name = ttd_names, complexity = ttd_complexities, blocking = ttd_blocking, delay = ttd_delay, ttd = ttd)
writetable("./results/ttd.csv", d2)


# Create Plots
theme = Theme(
    background_color = colorant"white"
)
Gadfly.push_theme(theme)

# Grad Rates
l1 = layer(x=ttd_complexities, y=ttd, Geom.point)
ols = glm(ttd ~ complexity, d2, Normal(), IdentityLink())
l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line)
p = plot(l1,l2);
draw(PNG("./results/ttd.png", 1920px, 1080px), p)

l1 = layer(x=grad_complexities, y=grad_rates, Geom.point)
ols = glm(gradRate ~ complexity, d1, Normal(), IdentityLink())
l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line)
p = plot(l1,l2);
draw(PNG("./results/rates.png", 1920px, 1080px), p)

l1 = layer(d1, x="complexity", y="gradRate", color="gini_index", Geom.point)
p = plot(l1,l2);
draw(PNG("./results/rates_gini.png", 1920px, 1080px), p)

# Blocking
l1 = layer(x=ttd_blocking, y=ttd, Geom.point)
ols = glm(ttd ~ blocking, d2, Normal(), IdentityLink())
l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line)
p = plot(l1,l2);
draw(PNG("./results/ttd_blocking.png", 1920px, 1080px), p)

l1 = layer(x=grad_blocking, y=grad_rates, Geom.point)
ols = glm(gradRate ~ blocking, d1, Normal(), IdentityLink())
l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line)
p = plot(l1,l2);
draw(PNG("./results/rates_blocking.png", 1920px, 1080px), p)

# Delay
l1 = layer(x=ttd_delay, y=ttd, Geom.point)
ols = glm(ttd ~ delay, d2, Normal(), IdentityLink())
l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line)
p = plot(l1,l2);
draw(PNG("./results/ttd_delay.png", 1920px, 1080px), p)

l1 = layer(x=grad_delay, y=grad_rates, Geom.point)
ols = glm(gradRate ~ delay, d1, Normal(), IdentityLink())
l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line)
p = plot(l1,l2);
draw(PNG("./results/rates_delay.png", 1920px, 1080px), p)