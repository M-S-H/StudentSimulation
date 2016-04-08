# Methods that perform common tasks

using DataFrames, DataArrays

# Arrays that hold grades and corresponding point values
grades = ["A+", "A", "A-", "B+", "B", "B-", "C+", "C", "C-", "D+", "D", "D-", "F"]
gradepoints = [4.33, 4.0, 3.67, 3.33, 3.0, 2.67, 2.33, 2.0, 1.67, 1.33, 1.0, 0.67, 0.0]
simplegrades = ["A", "B", "C", "D", "E", "F"]
simplegradepoints = [4.0, 3.0, 2.0, 1.0, 0.0]

# Converts a grade to a numerical value
function gradeconvert(grade; expanded=true)
	# The expanded variable determines wheter pluses and minuses
	# are accounted for, or discounted.

	# Stores a translation dictionary
	translation = nothing

	if expanded
		# Expanded Translation
		translation = Dict(
			"A+"	=> 4.33,
			"A"	=> 4.0,
			"A-"	=> 3.67,
			"B+"	=> 3.33,
			"B"	=> 3.0,
			"B-"	=> 2.67,
			"C+"	=> 2.33,
			"C"	=> 2.0,
			"C-"	=> 1.67,
			"D+"	=> 1.33,
			"D"	=> 1.0,
			"D-"	=> 0.67,
			"F" 	=> 0.0
		)
	else
		# Truncated Translation
		translation = Dict(
			"A+"	=> 4.0,
			"A"	=> 4.0,
			"A-"	=> 3.0,
			"B+"	=> 3.0,
			"B"	=> 3.0,
			"B-"	=> 2.0,
			"C+"	=> 2.0,
			"C"	=> 2.0,
			"C-"	=> 1.0,
			"D+"	=> 1.0,
			"D"	=> 1.0,
			"D-"	=> 0.0,
			"F" 	=> 0.0
		)
	end

	if in(grade, grades)
		# Checks for a standard grade and tralsate.	
		return translation[grade]
	else
		# Otherwise, return 0.0
		return 0.0
	end
end


# Converts a numerical value to a grade
function valueconvert(value; expanded=true)
	# The expanded variable determines wheter pluses and minuses
	# are accounted for, or discounted.

	# Variables to hold grade and point arrays depending on the
	# expanded variable
	g = nothing; p = nothing

	if expanded
		g = grades
		p = gradepoints
	else
		g = simplegrades
		p = simplegradepoints
	end

	# Find point value closests to passed in value
	diffs = abs(p .- value)
	ind = indmin(diffs)

	# Return corresponding grade
	return g[ind]
end


# Converts a numerical value to a grade
function nearestvalue(value; expanded=true)
	# The expanded variable determines wheter pluses and minuses
	# are accounted for, or discounted.

	# Variables to hold grade and point arrays depending on the
	# expanded variable
	g = nothing; p = nothing

	if expanded
		g = grades
		p = gradepoints
	else
		g = simplegrades
		p = simplegradepoints
	end

	# Find point value closests to passed in value
	diffs = abs(p .- value)
	ind = indmin(diffs)

	# Return corresponding grade
	return p[ind]
end


# function qualityPoints(grade)
# 	translation = Dict(
# 		4.3 => ,
# 		4.0 =>
# 	)
# end



# Test
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