module PassRateBayes
	using Distributions
	include("../lib/grades_helper.jl")
	include("../lib/helper.jl")

	# Train the model
	function train(course, features)
		# Get Data
		X, Y = formatData(course, features)
		labels = Float64[]
		for y in Y
			label = 0.0
			if y > 1.67
				label = 1.0
			end
			push!(labels, label)
		end

		#Dictionary for storing model
		model = Dict()

		# Course Grade Prior
		model[:passdist] = fit(Normal, labels)

		# Feature Prior
		model[:featuredist] = fit(MvNormal, X')

		# Conditional Probabilities
		conditionals = []
		for i in [0.0 1.0]
			# Find features that have a given label
			inds = labels .== i
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
		labels  *= 4.0
		correct = 0
		predictions = []
		for i=1:size(X)[1]
			x = X[i, :]
			y = predict(course, x)
			push!(predictions, y)

			if y == labels[i]
				correct += 1
			end
		end
		model[:X] = X
		model[:Y] = labels
		model[:predictions] = predictions
		model[:correct] = correct
		model[:rmse] = sqrt(sum((labels-predictions).^2) / size(Y)[1])
		# return X, Y
	end


	# Predict grade
	function predict(course, sample)
		# Construct feature vector
		# features = [student.actengl student.actmath student.actscir student.hsgpa]'

		sample = sample'

		# Probablities
		probabilities = []

		for j in [0.0, 1.0]
			probOutcome = pdf(course.model[:passdist], j)

			probFeatures = pdf(course.model[:featuredist], sample)[1]

			probConditional = pdf(course.model[:conditionals][round(Int, j) + 1], sample)[1]

			push!(probabilities, probConditional * probOutcome / probFeatures)
		end

		ind = indmax(probabilities)
		return [0.0, 4.0][ind]
		# if rand() < probabilities[2]
		# 	return 0.0
		# else
		# 	return 4.0
		# end
	end
end