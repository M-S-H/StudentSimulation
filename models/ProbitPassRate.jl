module ProbitPassRate
	# Dependencies
	include("../lib/grades_helper.jl")
	include("../lib/helper.jl")
	using GLM
	
	# Function that trains a predictive model for predicting course grades
	# All necessary data must be stored in dictionary and assigned to a
	# course's model variable
	function train(course, features)
		# Get Course Data
		X, Y = formatData(course, features)
		samples = length(Y)
		features = size(X)[2]

		# Convert Y to binary values
		Y[Y .<= 1.67] = 0.0
		Y[Y .> 1.67] = 1.0

		probitModel = 0

		try
			probitModel = glm(X,Y,Binomial(),ProbitLink())
		catch
			probitModel = 0
		end

		# Dictionary for storing model info
		model = Dict()
		course.model = model
		model[:X] = X
		model[:Y] = Y
		model[:probitModel] = probitModel

		# Computes course passrate
		course.passrate = length(Y[Y .> 0.0]) / samples

		predictions = []
		for i=1:samples
			prediction = predict_grade(course, X[i,:]) / 4.0
			push!(predictions, prediction)
		end

		# Computes the model's RMSE
		model[:rmse] = sum(Y-predictions).^2 / samples
	end


	# Function for predicting whether or not a student will withdraw from a course
	# Returns true if the student should withdraw, or false if they staty enrolled
	function predict_withdraw(course, sample)
		sample = vec(sample)
	end


	# Function for predicting the grade a student makes in a given course
	# Returns the point value of the grade
	function predict_grade(course, sample)
		# sample = vec(sample)
		prob = 0
		if course.model[:probitModel] != 0
			prob = predict(course.model[:probitModel], sample)[1]
		else
			prob = course.passrate
		end

		roll = rand()

		if roll <= prob
			return 4.0
		else
			return 0
		end
	end
end