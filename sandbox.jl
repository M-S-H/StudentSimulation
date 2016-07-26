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

simulate(acctSim, students, numTerms = 10, stopouts = false, locked_terms = false);
println("ACCT\nComplexity: $(acct.complexity)\nGrad Rate: $(acctSim.gradRate)\nThing: $((1-acctSim.gradRate) / acct.complexity))")

simulate(cpeSim, students, numTerms = 10, stopouts = false, locked_terms = false);
println("CPE\nComplexity: $(cpe.complexity)\nGrad Rate: $(cpeSim.gradRate)\nThing: $((1-cpeSim.gradRate) / cpe.complexity))")

simulate(meSim, students, numTerms = 10, stopouts = false, locked_terms = false);
println("ME\nComplexity: $(me.complexity)\nGrad Rate: $(meSim.gradRate)\nThing: $((1-meSim.gradRate) / me.complexity))")