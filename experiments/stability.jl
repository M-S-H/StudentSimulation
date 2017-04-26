using BoilingMoon
curricula = Curriculum("./curricula/ComputerEngineering.json");

sim = Simulation(curricula);
setPassrates(curricula.courses, 0.8);

samples = [10, 100, 500, 1000, 5000, 10000, 50000]
students = defaultStudents(1000);
simulate(sim, students, duration = 10);
println(sim.gradRate);