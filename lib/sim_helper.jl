function simInfo(simulation)
  println("Graduation Rate: $(simulation.gradRate)")

  println("\nStopout Rate: $(simulation.stopoutRate)")

  avg_grad_gpa = mean(map(x->x.gpa, simulation.graduatedStudents))
  println("\nAverage Graduated GPA: $(avg_grad_gpa)")

  avg_rmse = 0
  println("\nTraining RMSE Results")
  for t in simulation.curriculum.terms
    for c in t.courses
      avg_rmse += c.model[:rmse]
      println("\t$(c.name): $(round(c.model[:rmse],3))")
    end
  end

  avg_rmse /= simulation.curriculum.numCourses
  println("\tAverage RMSE: $(round(avg_rmse,3))")

  rate_error = 0
  println("\nCourse Pass Rates")
  for t in simulation.curriculum.terms
    for c in t.courses
      rate = 1-c.failures / c.enrolled
      rate_error += (rate - c.passrate)^2

      println("\t$(c.name): Actual: $(round(c.passrate,3))\tSimulated: $(round(rate,3))")
    end
  end

  rate_error = sqrt(rate_error / simulation.curriculum.numCourses)
  println("\tPass Rate RMSE: $(round(rate_error,3))")
end


function simFlow(simulation)
  for i=1:simulation.numTerms
    println("\nTerm $(i)")

    for term in simulation.curriculum.terms
      for course in term.courses
        println("\t$(course.name): $(course.termenrollment[i]) -> $(course.termpassed[i])")
      end
    end
  end
end


function passTable(simulation)
  frame = DataFrame()

  # Make Keys
  frame[:COURSE] = []
  terms = simulation.numTerms
  for i=1:terms
    frame[symbol("TERM$(i)")] = []
  end

  # Populate Data Course by Course
  for course in simulation.curriculum.courses
    row = [course.name]
    prev = 0
    for i=1:terms
      prev += course.termpassed[i]
      row = [row round((prev/simulation.numStudents)*100, 3)]
    end
    push!(frame, row)
  end

  rates = ["GRAD RATE"]
  for i=1:terms
    rates = [rates round(simulation.termGradRates[i]*100, 3)]
  end
  push!(frame, rates)

  frame
end