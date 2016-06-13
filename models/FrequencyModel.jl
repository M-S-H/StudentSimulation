#= 	This model predicts grades based on the most frequent grade made for a given set
	of parameters. Because the given parameters such as GPA's are so varied. They
	are placed in bins (like a histogram). A count of the grades made for each combination
	of bins is computed.

	When predicting a grade, the student's features are converted to the bins each belongs in.
	It will then pull the closest bin on record and return the grade with the highest frequency.
=#

module FrequencyModel
	# Dependencies
	include("../lib/grades_helper.jl")
	include("../lib/helper.jl")

	# Function that trains a predictive model for predicting course grades
	# All necessary data must be stored in dictionary and assigned to a
	# course's model variable
	function train(course, features)
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
		course.passrate = length(Y[Y .> 1.67]) / samples

		# The number of bins used to catagorize the features
		bins = 15
		
		# An array that holds a float range to define the bins for each feature
		ranges = []

		for i=1:features
			# Find the minimum and miximum values for each feature
			mx = maximum(X[:,i])
			mn = minimum(X[:,i])

			# Compute the incriment to divide the range of values by the number of bins specified
			inc = (mx-mn) / bins
			
			# If the incriment is 0, meaning that the min and max values are the same,
			# set the inc to be 0.1 and increase the max value by the same amount. This ensures
			# that a valid range is created.
			if inc == 0
				inc = 0.1
				mx += 0.1
			end

			# Push the range
			push!(ranges, mn:inc:mx)
		end


		# Once the bins for each feature is defined, a student's features can be transformed into
		# the bin that they belong in.

		# This array holds the transformed features
		binSpace = zeros(samples, features)

		# Define a dictionary that will contain the grade counts for every combination of bins
		# The key to the dictonary is the actual array of bins
		frequencies = Dict()

		for i=1:samples
			for j=1:features
				# Julia's histogram function is used to determine which bein the student's feature
				# belong in.
				e, count = hist([X[i,j]], ranges[j])
				binSpace[i,j] = indmax(count)
			end

			# Once the feature is converted, an entry is made in the frequency dictionoary, and is
			# initialized to an array of zeros, one for each possible grade.
			frequencies[binSpace[i,:]] = zeros(length(gradepoints))
		end


		# For each combination of bins, the grades made are counted
		for i=1:samples
			grade = Y[i]
			ind = findfirst(gradepoints, grade)

			frequencies[binSpace[i,:]][ind] += 1.0
		end


		# Save the frequency and ranges variables to the course's model variable
		model[:ranges] = ranges
		model[:frequencies] = frequencies


		# Make predictions to test the model
		predictions = []
		for i=1:samples
			push!(predictions, predict_grade(course, X[i,:]))
		end
		model[:predictions] = predictions

		# Computes the model's RMSE
		model[:rmse] = sqrt(sum((Y-predictions).^2) / samples)
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
		features = length(sample)

		# Get a list of keys (bin combinations) from the trained model
		allKeys = [key for key in keys(course.model[:frequencies])]

		# Transform sample to bins
		binSpace = zeros(1,features)
		for i=1:features
			e, count = hist([sample[i]], course.model[:ranges][i])
			binSpace[i] = indmax(count)
		end

		# Check to see if transformed feature matches one found in the training model.
		# If not, the closest feature is found and used instead
		if !in(binSpace, allKeys)
			distances = []
			for k in allKeys
				push!(distances, sqrt(sum((binSpace - k).^2)))
			end

			closest = indmin(distances)
			binSpace = allKeys[closest]
		end

		# Returns the most frequently made grade for the given combination of bins
		ind = indmax(course.model[:frequencies][binSpace])
		return gradepoints[ind]
	end
end