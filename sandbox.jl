include("SimulationModel.jl")
include("models/PassRate.jl")
include("models/GaussianBayes.jl")
include("models/GaussianProcess.jl")
include("models/Mixtures.jl")
include("models/MaxProb.jl")
include("curriculums/CPE.jl")
include("lib/course_helper.jl")

f1 = [:HSGPA, :ACTCOMP, :ATTEMPTS]
f2 = [:GPA]

students = courseStudents(ece101, f1)

sim = Simulation(terms, f1, f2, GaussianBayes)
simulate(sim, students, numTerms = 8)
simInfo(sim)