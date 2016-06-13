include("NewSimulationModel.jl");
include("curriculums/CPE.jl");

f1 = [];
f2 = [];

c = Curriculum(terms);

# students = studentsFromFile("geng", f1)
students = passRateStudents(1000);

sim = Simulation(c, f1, f2, PassRate);
simulate(sim, students, numTerms = 12, stopouts = false, locked_terms = false);

simInfo(sim);