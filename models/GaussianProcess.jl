module GaussianProcess
	using GaussianProcesses
	using Optim

	include("../lib/helper.jl")

	# Train the model
	function train(course, features)
		# Get Data
		X, Y = formatData(course, features)

		# # Normalize
		# for i=1:size(X)[2]
		# 	m = maximum(X[:, i])
		# 	X[:, i] ./= m
		# end

		mZero = MeanZero()
		kern = SE(0.0, 0.0)
		noise = - 0.1
		gp = GP(X', Y, mZero, kern, noise)

		# optimize!(gp)

		predictions = GaussianProcesses.predict(gp, X')[1];

		model = Dict()

		course.passrate = length(Y[Y .>= 2.0]) / length(Y)

		model[:gp] = gp
		model[:X] = X
		model[:Y] = Y
		model[:predictions] = predictions
		model[:rmse] = sqrt(sum((Y-predictions).^2) / size(Y)[1])

		course.model = model
	end


	# Predict grade
	function predict(course, sample)
		grade = GaussianProcesses.predict(course.model[:gp], sample')[1]

		return nearestvalue(grade)
	end
end