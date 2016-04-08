module GaussianBayes
	using Distributions
	include("../lib/helper.jl")

	# Train the model
	function train(course, features)
		# Get Data
		X, Y = formatData(course, features)

		#Dictionary for storing model
		model = Dict()

		# Course Grade Prior
		model[:gradedist] = fit(Normal, Y)

		# Feature Prior
		model[:featuredist] = fit(MvNormal, X')

		# Conditional Probabilities
		conditionals = []
		for p in gradepoints
			# Find features that have a given label
			inds = Y .== p
			x = X[inds, :]

			if size(x)[1] == 0
				push!(conditionals, 0)
			else
				try 
					dist = fit(MvNormal, x')
					push!(conditionals, dist)
				catch
					push!(conditionals, 0)
				end
			end
		end
		model[:conditionals] = conditionals

		course.passrate = length(Y[Y .>= 2.0]) / length(Y)
		
		# Save model to course
		course.model = model

		# For Debugging
		predictions = []
		for i=1:size(X)[1]
			x = X[i, :]
			y = predict(course, x)
			push!(predictions, y)
		end

		model[:X] = X
		model[:Y] = Y
		model[:predictions] = predictions

		model[:rmse] = sqrt(sum((Y-predictions).^2) / size(Y)[1])
		# return X, Y
	end


	# Predict grade
	function predict(course, sample)
		# Construct feature vector
		# features = [student.actengl student.actmath student.actscir student.hsgpa]'

		# println(sample)
		sample = vec(sample)

		# Probablities
		probabilities = []

		for j=1:length(gradepoints)
			grade = gradepoints[j]

			# Grade Prior
			prob_grade = pdf(course.model[:gradedist], grade)

			# println(sample)

			# Feature Prior
			prob_features = pdf(course.model[:featuredist], sample)[1]

			# Probability of feature given grade
			prob_conditional = 0.00001
			if course.model[:conditionals][j] != 0
				try
					prob_conditional = pdf(course.model[:conditionals][j], sample)[1]
				catch
					# println("fjdklsj")
				end
			end

			# println("$(grade):\t$(prob_grade)\t$(prob_features)\t$(prob_conditional)")

			# Bayes Formula
			prob = prob_conditional * prob_grade / prob_features

			# Push into array
			push!(probabilities, prob)
		end

		# Select the grade with the maximum probability
		ind = indmax(probabilities)
		return gradepoints[ind]
	end
end