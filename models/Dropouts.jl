module Dropout
	using DataFrames

	function train()
		stopouts = readtable("stopouts.csv")

		samples = size(stopouts)[1]
		n = 2	
		bins = 5
		
		X = zeros(samples, n)
		X[:,1] = stopouts[:GPA]
		X[:,2] = stopouts[:SEM]

		freqs = Dict()
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

		converted = zeros(samples, n)

		for i=1:samples
			for j=1:n
				e, count = hist([X[i,j]], ranges[j])
				converted[i,j] = indmax(count)

				freqs[converted[i,:]] = zeros(2)
			end
		end

		for i=1:samples
			ind = 1
			if stopouts[i, :LABEL] == "enrolled"
				ind = 2
			end

			freqs[converted[i,:]][ind] += 1
		end

		model = Dict()
		model[:freqs] = freqs
		model[:ranges] = ranges

		errors = 0
		for i=1:samples
			label = "enrolled"
			if predict(model, X[i,:])
				label = "dropout"
			end

			if label != stopouts[i, :LABEL]
				errors += 1
			end
		end

		model[:error] = errors / samples

		return model
	end


	function predict(model, sample)
		sample = vec(sample)
		n = 2

		count = []
		temp = zeros(1,n)

		for i=1:n
			e, count = hist([sample[i]], model[:ranges][i])
			temp[i] = indmax(count)
		end

		distances = []
		for k in keys(model[:freqs])
			push!(distances, sqrt(sum((temp - k).^2)))
		end

		closest = indmin(distances)

		all = [key for key in keys(model[:freqs])]

		key = all[closest]

		ind = indmax(model[:freqs][key])

		if ind == 1
			return true
		else
			return false
		end
	end
end