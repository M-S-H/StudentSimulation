include("SimulationModel.jl")
include("models/PassRate.jl")
include("models/GaussianBayes.jl")
include("models/GaussianProcess.jl")
include("models/Mixtures.jl")
include("models/MaxProb.jl")
include("curriculums/CPE.jl")

f1 = [:HSGPA, :ATTEMPTS]
f2 = [:GPA, :ATTEMPTS]

students = courseStudents(ece101, f1)

models = [PassRate, GaussianBayes, Mixtures, MaxProb]

for m in models
	println("\n\n")
	println(m)
	println("----------------")

	sim = Simulation(terms, f1, f2, m)

	rate = simulate(sim, students, numTerms = 8)
	println(rate)

	# simInfo(sim)
end