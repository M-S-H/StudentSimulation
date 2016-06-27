include("SimulationModel.jl");
include("models/PassRateOneRoll.jl")
include("curriculums/Two.jl");

curriculum = Curriculum(terms);

f1 = [:ROLL]
f2 = [:ROLL]

# students = passRateStudents(10000)
# sim = Simulation(curriculum, f1, f2, PassRate);
# simulate(sim, students, max_credits = 100, numTerms = 2, stopouts = false, locked_terms = false);
# println(sim.gradRate)
# simFlow(sim)

curricula = ["Case1", "Case2", "Case3", "Case4", "Case5"]

for c in curricula
  curriculum = Curriculum(c)
  students = passRateStudents(10000)
  sim = Simulation(curriculum, f1, f2, PassRate);
  simulate(sim, students, max_credits = 6, numTerms = 4, stopouts = false, locked_terms = true);

  println("\n$(c) ($(curriculum.complexity))")
  frame = DataFrame(NAME = [], TERM1 = [], TERM2 = [], TERM3 = [], TERM4 = [])
  sample = []
  for course in curriculum.courses
    sample = [course.name course.termpassed[1] course.termpassed[2] course.termpassed[3] course.termpassed[4]]
    push!(frame, sample)
  end

  rates = ["GRAD RATE" sim.termGradRates[1] sim.termGradRates[2] sim.termGradRates[3] sim.termGradRates[4]]
  push!(frame, rates)

  println(frame)
end