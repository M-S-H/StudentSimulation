module PassRate
	include("../lib/helper.jl")


	function train(course, f)
		# Get Data
		features = []
		X, Y = formatData(course, features, removeNonGrades=false)

		model = Dict()

		# Determine pass rate
		passing = Y[Y .>= 2.0]

		model[:passrate] = 1.0 # length(passing) / length(Y)

		course.passrate = model[:passrate]
		
		model[:rmse] = "NA"

		course.model = model
	end


	function predict(course, sample)
		roll = rand()
		if roll <= course.model[:passrate]
			return 4.0
		else
			return 0.0
		end
	end
end