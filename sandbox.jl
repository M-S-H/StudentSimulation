include("SimulationModel.jl")
include("curriculums/CPE.jl")

f1 = [:HSGPA, :ACTCOMP, :ATTEMPTS]
f2 = [:GPA]

students = courseStudents(ece101, f1)

sim = Simulation(terms, f1, f2, GaussianBayes)
simulate(sim, students, numTerms = 8)
simInfo(sim)