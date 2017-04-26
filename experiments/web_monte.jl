using BoilingMoon
using Gadfly
using DataFrames
using GLM
include("./helpers/gadfly_theme.jl");

addprocs(4);

# Load the Curriculum
curricula = readdir("./curricula/web");

# Array to hold results
names = []
complexities = Float64[];
completionRates = Float64[];
terms = Float64[];
credits = Float64[];

# Itterate over curricula
for (n,c) in enumerate(curricula)
    print("\r$(n) of $(length(curricula)): $(c)");

    # Load Curriculum
    curriculum = Curriculum(c, "./curricula/web/$(c)");

    # Create Simulation
    sim = Simulation(curriculum);

    # Equalize all course passrates
    setPassrates(curriculum.courses, 0.8);

    # Run simulation 100 times
    for i=1:100
        # Create students
        students = defaultStudents(100);

        # Run the simulation
        duration = length(curriculum.terms) + 2;
        simulate(sim, students, max_credits = 18, duration = duration);

        # Push Results
        push!(names, c);
        push!(complexities, curriculum.complexity);
        push!(terms, length(curriculum.terms));
        push!(completionRates, sim.gradRate);
        push!(credits, sum(map(x->x.credits, curriculum.courses)))
    end
end

# Save Results
data = DataFrame(name = names, complexity = complexities, completionRate = completionRates, term = terms, credits = credits);
writetable("./results/monteCarlo.csv", data)

# Perform Regression
ols = glm(completionRate ~ complexity, data, Normal(), IdentityLink());
println("\n");
println("Total Regression Results:\n$(ols)");

# Plot Results
l1 = layer(data, x="complexity", y="completionRate", Geom.point);
l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line);
p = plot(l1, l2,
    Guide.title("Monte Carlo Simulation Results"),
    Guide.xlabel("Complexity"),
    Guide.ylabel("Completion Rate"));
draw(PNG("./results/monteCarlo.png", 1920px, 1080px), p);

# Only Use Curricula with Eight Terms
data = data[data[:term] .== 8, :];
data = data[data[:credits] .> 100, :];

ols = glm(completionRate ~ complexity, data, Normal(), IdentityLink());
println("Eight Terms Regression Results:\n$(ols)");

# Plot Results
l1 = layer(data, x="complexity", y="completionRate", Geom.point);
l2 = layer(x=[0,600], y=[1 0; 1 600]*coef(ols), Geom.line);
p = plot(l1, l2,
    Guide.title("Monte Carlo Simulation Results"),
    Guide.xlabel("Complexity"),
    Guide.ylabel("Completion Rate"));
draw(PNG("./results/monteCarloEight.png", 1920px, 1080px), p);
