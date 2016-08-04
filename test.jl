include("SimulationModel.jl")
c = Curriculum("Case5")
sim = Simulation(c, [], [], PassRate);
students = passRateStudents(10000);
simulate(sim, students, numTerms = 4, max_credits = 9, stopouts = false, locked_terms = false);
baseRate = sim.gradRate

results = []

for i = 1:100
  courseIds = map(x->x.id, c.courses)

  bank = 0.2

  chosen = []

  # Number of courses to change
  numChangeCourses = rand(1:3)

  # Change passrates
  for j=1:numChangeCourses-1
    courseId = sample(courseIds)
    course = c.courses[courseId]
    push!(chosen, course)

    courseIndex = findfirst(courseIds, courseId)
    deleteat!(courseIds, courseIndex)

    amount = bank * rand()
    bank -= amount

    course.model[:passrate] += amount
  end

  courseId = sample(courseIds)
  course = c.courses[courseId]
  push!(chosen, course)

  course.model[:passrate] += bank

  simulate(sim, students, numTerms = 4, max_credits = 9, stopouts = false, locked_terms = false);

  names = ""

  for course in chosen
    course.model[:passrate] = course.passrate
    names = string(names, ", ", course.name)
  end

  result = Dict(:label => names, :diff => sim.gradRate-baseRate)
  push!(results, result)
end

sort!(results, by=x->x[:diff], rev=true)

resultTable = DataFrame(Label = [], Diff = [])

for i=1:100
  push!(resultTable, [results[i][:label], results[i][:diff]])
end

println(resultTable)

