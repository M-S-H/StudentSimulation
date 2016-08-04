tic();
include("SimulationModel.jl");

f1 = [];
f2 = [];

c = Curriculum("Computer Engineering");
students = passRateStudents(10000);
sim = Simulation(c, f1, f2, PassRate);
simulate(sim, students, max_credits = 18, numTerms = 10, stopouts = false, locked_terms = false);
println(sim.gradRate)

c = Curriculum("Computer Engineering");
students = passRateStudents(10000);
sim = Simulation(c, f1, f2, PassRate);
simulate(sim, students, max_credits = 18, numTerms = 10, stopouts = false, locked_terms = false);
println(sim.gradRate)
println(toc());
println("DONE");