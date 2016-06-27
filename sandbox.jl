include("SimulationModel.jl");
include("curriculums/CPE.jl");
include("models/ProbitPassRate.jl");

f1 = [:HSGPA, :ACTCOMP];
f2 = [];

c = Curriculum(terms);

students = studentsFromFile("geng", f1)
# students = passRateStudents(1000);

sim = Simulation(c, f1, f2, ProbitPassRate);
simulate(sim, students, numTerms = 8, stopouts = true, locked_terms = true);

simInfo(sim);