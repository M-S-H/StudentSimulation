# Must be run from root directory

include("SimulationModel.jl")
include("models/PassRate.jl")
include("models/GaussianBayes.jl")
include("curriculums/Test1.jl")

students = courseStudents(ece203, features)

sim = Simulation(terms, features, features, GaussianBayes)

simulate(sim, students, numTerms = 2)