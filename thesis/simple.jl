include("SimulationModel.jl");
# include("curriculums/CPE.jl");
# include("models/ProbitPassRate.jl");

f1 = [];
f2 = [];

me = Curriculum("Mechanical Engineering");
cpe = Curriculum("Computer Engineering");
acct = Curriculum("Accounting");

# students = studentsFromFile("geng", f1)
students = passRateStudents(1000);

meSim = Simulation(me, f1, f2, PassRate);
cpeSim = Simulation(cpe, f1, f2, PassRate);
acctSim = Simulation(acct, f1, f2, PassRate);

rates = []
dev = []
ittr = []
times = []

for i=1:100
    temp_rates = []
    temp_times = []
    println(i)

    for j=:1:20
        simulate(acctSim, students, numTerms = 10, stopouts = true, locked_terms = false);
        push!(temp_rates, acctSim.gradRate)
        push!(temp_times, acctSim.timeToDegree)
            # push!(ittr, i)
            # push!(dev, sqrt(sum((rates .- mean(rates)).^2)/length(rates)))
    end

    push!(rates, mean(temp_rates))
    push!(times, mean(temp_times))

    # println(acctSim.numTerms)
    # println(acctSim.timeToDegree)
end

println("Results")

println(mean(rates))
println(sqrt(sum((rates .- mean(rates)).^2)/length(rates)))

println(mean(times))
println(sqrt(sum((times .- mean(times)).^2)/length(times)))


# plot(x=ittr, y=dev, Geom.line)

# simulate(acctSim, students, numTerms = 8, stopouts = true, locked_terms = false);
# println("ACCT\nComplexity: $(acct.complexity)\nDifficulty: $(acct.passrate)\nGrad Rate: $(acctSim.gradRate)\nThing: $((1-acctSim.gradRate) / acct.complexity)")

# simulate(cpeSim, students, numTerms = 8, stopouts = true, locked_terms = false);
# println("CPE\nComplexity: $(cpe.complexity)\nDifficulty: $(cpe.passrate)\nGrad Rate: $(cpeSim.gradRate)\nThing: $((1-cpeSim.gradRate) / cpe.complexity)")

# simulate(meSim, students, numTerms = 8, stopouts = true, locked_terms = false);
# println("ME\nComplexity: $(me.complexity)\nDifficulty: $(me.passrate)\nGrad Rate: $(meSim.gradRate)\nThing: $((1-meSim.gradRate) / me.complexity)")