include("SimulationModel.jl");
c = Curriculum("Mechanical Engineering");

setPassRate(c, 0.8)
sim = Simulation(c, [], [], PassRate);

# for i=1:500:2501
#     println(i)
#     rates = []
#     for j = 1:40
#         students = passRateStudents(i);
#         simulate(sim, students, numTerms = 10, stopouts = false, locked_terms = false);
#         push!(rates, sim.gradRate)
#     end
    
#     println("\t$(mean(rates))")
#     rate_var = sqrt(sum((rates .- mean(rates)).^2)/length(rates))
#     println("\t$(rate_var)")

# end


rates = []
for j = 1:2
    students = passRateStudents(100000);
    simulate(sim, students, numTerms = 10, stopouts = false, locked_terms = false);
    println(sim.gradRate)
end