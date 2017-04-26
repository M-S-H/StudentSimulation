using BoilingMoon
using DataFrames
using Gadfly
include("./helpers/gadfly_theme.jl")

curriculum = Curriculum("ComputerEngineering", "curricula/ComputerEngineering.json")
sim = Simulation(curriculum)
students = defaultStudents(1000);

gradRates = Float64[]
passrates = Float64[]

for passrate = 0.0:0.02:1.0
    setPassrates(curriculum.courses, passrate);
    simulate(sim, students, max_credits = 18, duration = 1000)
    push!(gradRates, sim.timeToDegree)
    push!(passrates, passrate)
end

p = plot(x=passrates, y=gradRates, Geom.line, Guide.title("Average Passrate vs Time To Degree"), Guide.xlabel("Avg Passrate"), Guide.ylabel("Time To Degree"))
draw(PNG("./results/instructional_ttd.png", 1920px, 1080px), p);
