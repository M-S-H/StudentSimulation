# Must be run from root directory

include("SimulationModel.jl")
include("models/PassRate.jl")
include("models/GaussianBayes.jl")
include("curriculums/CPE.jl")

f1 = [:HSGPA, :ACTENGL, :ACTMATH, :ACTSCIR]
f2 = [:GPA]

students = courseStudents(ece101, f1)

sim = Simulation(terms, f1, f2, GaussianBayes)

simulate(sim, students, numTerms = 2)