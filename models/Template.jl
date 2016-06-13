module ModelTemplate
	# Dependencies
	include("../lib/grades_helper.jl")
	include("../lib/helper.jl")
	
	# Function that trains a predictive model for predicting course grades
	# All necessary data must be stored in dictionary and assigned to a
	# course's model variable
	function train(terms, features)
		for term in terms
			for course in term.courses
				# Get Course Data
				X, Y = formatData(course, features)
				samples = length(Y)
				features = size(X)[2]

				# Dictionary for storing model info
				model = Dict()
				course.model = model
				model[:X] = X
				model[:Y] = Y

				# Computes course passrate
				course.passrate = length(Y[Y .> 2.0]) / samples


				# Computes the model's RMSE
				model[:rmse] = sqrt(sum(Y-predictions).^2) / samples
			end
		end
	end


	# Function for predicting whether or not a student will withdraw from a course
	# Returns true if the student should withdraw, or false if they staty enrolled
	function predict_withdraw(course, sample)
		sample = vec(sample)
	end


	# Function for predicting the grade a student makes in a given course
	# Returns the point value of the grade
	function predict_grade(course, sample)
		sample = vec(sample)
	end
end