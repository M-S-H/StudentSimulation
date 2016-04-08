function courseStudents(course, features)
	students = Student[]
	X, Y = formatData(course, features)

	for i=1:size(X)[1]
		attributes = Dict()
		for (j, key) in enumerate(features)
			if in(key, [:ATTEMPTS])
				continue
			end

			attributes[key] = X[i, j]
		end

		student = Student(i, attributes)
		push!(students, student)
	end

	return students
end


function passRateStudents(number)
	students = Student[]
	for i=1:number
		student = Student(i, Dict())
		push!(students, student)
	end
	return students
end


function studentFeatures(student, features)
	feature = Array{Float64}(1,0)
	for k in features
		feature = [feature student.attributes[k]]
	end

	return feature
end