
# addprocs(8)

@everywhere using BoilingMoon
@everywhere using DataFrames

tic()
for i=1:4
    curriculum = Curriculum("ComputerEngineering", "curricula/ComputerEngineering.json");
    sim = Simulation(curriculum);
    students = defaultStudents(1000);
    simulate(sim, students, max_credits = 18, duration = 8);
end
println(toc())

@everywhere function perform_sim(i)
    curriculum = Curriculum("ComputerEngineering", "curricula/ComputerEngineering.json")
    sim = Simulation(curriculum)
    students = defaultStudents(1000)
    simulate(sim, students, max_credits = 18, duration = 8)
    return sim
end

tic()
stuff = pmap(perform_sim, zeros(4));
toc()
println(stuff)
