include("SimulationModel.jl");
include("models/PassRateOneRoll.jl")
include("curriculums/Two.jl");

curriculum = Curriculum(terms);

f1 = []
f2 = []

# curricula = ["ComplexCase1", "ComplexCase2", "ComplexCase3", "ComplexCase4"]
# for c in curricula
#   curriculum = Curriculum(c)
#   students = passRateStudents(100000)
#   sim = Simulation(curriculum, f1, f2, PassRate);
#   simulate(sim, students, max_credits = 12, numTerms = 6, stopouts = false, locked_terms = false);

#   println("\n$(c) ($(curriculum.complexity))")
#   frame = DataFrame(NAME = [], TERM1 = [], TERM2 = [], TERM3 = [], TERM4 = [], TERM5 = [], TERM6 = [])
#   sample = []
#   for course in curriculum.courses
#     sample = [course.name course.termpassed[1] course.termpassed[2] course.termpassed[3] course.termpassed[4] course.termpassed[5] course.termpassed[6]]
#     push!(frame, sample)
#   end

#   rates = ["GRAD RATE" sim.termGradRates[1] sim.termGradRates[2] sim.termGradRates[3] sim.termGradRates[4] sim.termGradRates[5] sim.termGradRates[6]]
#   push!(frame, rates)

#   println(frame)
# end


curricula = ["Case1", "Case2", "Case3", "Case4", "Case5"]
for c in curricula
  curriculum = Curriculum(c)
  students = passRateStudents(10000)
  sim = Simulation(curriculum, f1, f2, PassRate);
  simulate(sim, students, max_credits = 6, numTerms = 4, stopouts = false, locked_terms = false);

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