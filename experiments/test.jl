using BoilingMoon
using DataFrames
using Gadfly

curriculum = Curriculum("ComputerEngineering", "curricula/ComputerEngineering.json");
sim = Simulation(curriculum);
students = defaultStudents(10000);

sem = 8

simulate(sim, students, max_credits = 18, duration = sem);
og_table = passTable(sim);


curriculum = Curriculum("ComputerEngineering", "curricula/ComputerEngineering.json");
sim = Simulation(curriculum);
curriculum.courses[8].model[:passrate] += 0.2;
students = defaultStudents(10000);
simulate(sim, students, max_credits = 18, duration = sem);

new_table = passTable(sim);

diff_table = DataFrame(COUSE = new_table[:COUSE])

for i=1:sem
    key = Symbol("TERM$(i)")
    diff_table[key] = new_table[key] - og_table[key]
end

