using BoilingMoon

case = "Case4"

curriculum = Curriculum(case, "curricula/base/$(case).json")

sim = Simulation(curriculum)
students = defaultStudents(10000)
simulate(sim, students, max_credits = 9, duration = 6)

gradStudents = sim.graduatedStudents[find(x->x.gradsem == 4, sim.graduatedStudents)]

println(unique(map(x->x.termpassed, gradStudents)))