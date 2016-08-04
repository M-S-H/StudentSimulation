include("SimulationModel.jl");
c = Curriculum("Computer Engineering");
setPassRate(c, 0.75)

students = passRateStudents(10000);

sim = Simulation(c, [], [], PassRate);
simulate(sim, students, numTerms = 10, stopouts = false, locked_terms = false);
println(sim.gradRate)

courses = sort(c.courses, by=x->x.cruciality, rev=false)
for i=1:3
    courses[i].model[:passrate] = 0.95
end

simulate(sim, students, numTerms = 10, stopouts = false, locked_terms = false);
println(sim.gradRate)



# results = sensitivity(c, diff=0.2)

# # students = studentsFromFile("geng", f1)
# students = passRateStudents(10000);

# sim = Simulation(c, [], [], PassRate);
# simulate(sim, students, numTerms = 10, stopouts = false, locked_terms = false);

# baseRate = sim.gradRate

# for course in c.courses
#   oldRate = course.passrate
#   course.passrate += 0.1
#   sim = Simulation(c, [], [], PassRate);
#   simulate(sim, students, numTerms = 10, stopouts = false, locked_terms = false);

#   sens = (sim.gradRate - baseRate) / (course.passrate - oldRate)

#   course.passrate = oldRate

#   println("$(course.name):\t$(round(sens,3))")
# end

# rates = []
# gradRates = []

# math162 = c.courses[2];

# for pr = 0.05:0.05:1
#   math162.passrate = pr;
#   sim = Simulation(c, [], [], PassRate);
#   simulate(sim, students, numTerms = 10, stopouts = false, locked_terms = false);

#   push!(rates, pr);
#   push!(gradRates, sim.gradRate);
# end

# plot(x=rates, y=gradRates, Geom.line)
