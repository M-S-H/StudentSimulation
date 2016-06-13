module Frequentist
	include("../lib/grades_helper.jl")
	include("../lib/helper.jl")

	# Train the model
	function train(course, features)
		# Get Data
		X, Y = formatData(course, features)

		#Dictionary for storing model
		model = Dict()
		course.model = model
		model[:X] = X
		model[:Y] = Y

		course.passrate = length(Y[Y .>= 2.0]) / length(Y)

		bins = 15

		freqs = Dict()
		n = size(X)[2]
		samples = size(X)[1]

		ranges = []
		for i=1:n
			mn = minimum(X[:,i])
			mx = maximum(X[:,i])
			inc = (mx-mn) / bins
			if inc == 0
				inc = 0.1
				mx = 1+0.1
			end
			push!(ranges, mn:inc:mx)
		end

		model[:ranges] = ranges

		converted = zeros(samples, n)

		# Convert
		for i=1:samples
			for j=1:n
				e, count = hist([X[i,j]], ranges[j])
				converted[i,j] = indmax(count);

				freqs[converted[i,:]] = zeros(length(gradepoints))
			end
		end

		for i=1:samples
			grade = Y[i]
			ind = findfirst(gradepoints, grade)

			freqs[converted[i,:]][ind] += 1
		end

		model[:freqs] = freqs

		predictions = []
		for i=1:samples
			push!(predictions, predict(course, X[i,:]))
		end

		model[:predictions] = predictions
		model[:rmse] = sqrt(sum((Y-predictions).^2) / size(Y)[1])
	end


	# predicts a withdraw
	function predict_withdraw(course, sample)
	end


	# Predict grade
	function predict(course, sample)
		sample = vec(sample)
		n = length(sample)

		count = []
		temp = zeros(1,n)

		for i=1:n
			e, count = hist([sample[i]], course.model[:ranges][i])
			temp[i] = indmax(count)
		end

		distances = []
		for k in keys(course.model[:freqs])
			push!(distances, sqrt(sum((temp - k).^2)))
		end

		closest = indmin(distances)

		all = [key for key in keys(course.model[:freqs])]

		key = all[closest]

		ind = indmax(course.model[:freqs][key])

		return gradepoints[ind]
	end
end