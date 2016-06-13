# Methods that perform common tasks

using DataFrames, DataArrays

function formatData(course, features; expanded=true, removeNonGrades=true, firstTerm=false)

	# Load data based on course name
	data = readtable("./data/$(course.name).csv")

	# If there are prereqs, select students who have taken all courses
	ids = data[:STUDENT_ID]
	prereqdata = Dict()

	for c in course.prereqs
		d = readtable("data/$(c.name).csv")
		prereqdata[c.name] = d
		ids = intersect(ids, d[:STUDENT_ID])
	end
	inds = indexin(data[:STUDENT_ID], ids) .> 0
	data = data[inds, :]

	# Number of samples
	n = size(data)[1]

	# Number of features
	m = length(features) + size(course.prereqs)[1]

	# Feature Vectors
	X = Array{Float64}(0,m)

	# Label Vector
	Y = Array{Float64}(0)

	# Count attempts
	data[:ATTEMPTS] = zeros(n)
	sort!(data, cols=[:STUDENT_ID])
	at = 1.0
	last = 0
	for i=1:n
		if last != data[i,:STUDENT_ID]
			at = 1.0
		end
		data[i, :ATTEMPTS] = at
		last = data[i,:STUDENT_ID]
		at += 1
	end

	for i=1:n
		grade = data[i, :FINAL_GRADE_RECEIVED]
		id = data[i, :STUDENT_ID]

		# If removeNonGrades flag is true, then all non standard grades
		# will not be included
		if removeNonGrades && !in(grade, grades)
			continue
		end

		# Create sample from features
		sample = Array{Float64}(1,0)
		for f in features
			sample = [sample data[i, f]]
		end

		for k in keys(prereqdata)
			d = prereqdata[k]
			
			g = d[d[:STUDENT_ID] .== id, :]

			g = g[size(g)[1], :FINAL_GRADE_RECEIVED]
			
			sample = [sample gradeconvert(g, expanded=expanded)]
		end

		# Add sample to feature vector
		X = [X; sample]

		# Push label
		label = gradeconvert(grade, expanded=expanded)
		push!(Y, label)
	end

	return X, Y
end