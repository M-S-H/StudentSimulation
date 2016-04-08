module Mixtures
	using GaussianMixtures
	using Distributions

	include("../lib/helper.jl")

	# Train the model
	function train(course, features)
		# Get Data
		X, Y = formatData(course, features)

		numFeatures = size(X)[2]
		numPoints = length(gradepoints)

		myMeans = zeros(numPoints, numFeatures)

		for i=1:numPoints
			temp = X[Y.==gradepoints[i], :]	
			if size(temp)[1] == 0
				myMeans[i,:] = zeros(1,numFeatures)
			else
				myMeans[i,:] = mean(temp, 1)
			end
		end

		gmm = GMM(numPoints, numFeatures)
		gmm.μ = myMeans

		em!(gmm, X)

		model = Dict()

		model[:weights] = gmm.w
		model[:gmm] = MixtureModel(gmm)
		model[:X] = X
		model[:Y] = Y

		course.model = model

		predictions = []

		for i=1:size(X)[1]
			push!(predictions, predict(course, X[i,:]))
		end

		model[:predictions] = predictions

		model[:rmse] = sqrt(sum((Y-predictions).^2) / size(Y)[1])

		course.model = model
	end


	# Predict grade
	function predict(course, sample)
		probabilities = []

		for i=1:length(course.model[:weights])
			prob = course.model[:weights][i]*pdf(course.model[:gmm].components[i], sample')[1]
			push!(probabilities, prob)
		end

		ind = indmax(probabilities)

		return gradepoints[ind]
	end
end