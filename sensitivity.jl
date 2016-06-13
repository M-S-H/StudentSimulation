include("SimulationModel.jl")
# include("curriculums/CPE.jl")
# include("curriculums/Simple.jl")
# include("curriculums/Two.jl")

# c = Curriculum("ME");
c = Curriculum(terms)

f1 = [];
f2 = [];

terms = c.terms

students = passRateStudents(10000);

sim = Simulation(terms, f1, f2, PassRate);
simulate(sim, students, numTerms = length(terms));

base = sim.gradRate

rates = []

for (i, term) in enumerate(terms)
	for course in term.courses
		o = course.model[:passrate]
		course.model[:passrate] = 0.7*o
		simulate(sim, students, numTerms = length(terms));
		course.model[:passrate] = o
		course.model[:diff] = (base - sim.gradRate) / i
	end
end

allCourses = Course[]

for term in terms
	for course in term.courses
		push!(allCourses, course)
	end
end

sort!(allCourses, by=x->x.model[:diff], rev=true)

results = DataFrame(Name=[], Cruciality=[], Blocking=[], Delay=[], Impact=[])

for c in allCourses
	push!(results, [c.name, c.cruciality, c.blocking, c.delay, c.model[:diff]])
end

println(results)