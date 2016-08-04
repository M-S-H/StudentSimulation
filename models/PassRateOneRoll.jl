module PassRateOneRoll
  include("../lib/grades_helper.jl")
  include("../lib/helper.jl")


  function train(course, f)
    model = Dict()

    if course.passrate == 0
      # Get Data
      features = []
      X, Y = formatData(course, features, removeNonGrades=false)

      # Determine pass rate
      passing = Y[Y .>= 1.67]

      model[:passrate] = length(passing) / length(Y)

      course.passrate = model[:passrate]
    else
      model[:passrate] = course.passrate
    end

    course.model = model

    rates = 0
    for i=1:1000
      if predict_grade(course, [rand()]) > 0
        rates += 1
      end
    end
    model[:rmse] = abs((rates / 1000) - course.model[:passrate])
  end


  function predict_grade(course, sample)
    if sample[1] <= course.model[:passrate]
      return 4.0
    else
      return 0.0
    end
  end
end