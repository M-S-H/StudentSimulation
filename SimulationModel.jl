# Types
include("types/course.jl")
include("types/student.jl")
include("types/term.jl")

# Helper Files
include("lib/helper.jl")
include("lib/students_helper.jl")
include("lib/course_helper.jl")

# Models
include("models/PassRate.jl")
include("models/GaussianBayes.jl")
include("models/GaussianProcess.jl")
include("models/Mixtures.jl")
include("models/MaxProb.jl")

# Simulation Type
type Simulation
	terms						# Array to hold the terms and courses
	courses::Int				# Number of courses
	freshmanfeatures::Array		# Array of features used to train first semester courses
	regularFeatures::Array		# Array of features used to train in non first semester courses
	model::Module 				# Module for training and predicting
	students::Array{Student}		# Array of students
	studentEnrollment::Array		# Tracks which students have completed which courses
	gradRate::Float64			# Simulation graduation rate
	graduated::Array{Student}		# Array of graduated students
	notgraduated::Array{Student}	# Array of non graduated students


	function Simulation(terms, freshmanfeatures, regularFeatures, model)
		this = new()

		this.terms = terms
		this.freshmanfeatures = freshmanfeatures
		this.regularFeatures = regularFeatures
		this.model = model

		this.graduated = Student[]
		this.notgraduated = Student[]

		# Assign id to courses
		id = 0
		features = freshmanfeatures

		println("Training...")
		for term in terms
			for course in term.courses
				id += 1
				course.id = id

				# Train model for course
				# println("\t$(course.name)")
				model.train(course, features)
			end

			features = regularFeatures
		end

		this.courses = id

		return this
	end
end


function simulate(simulation, students; numTerms=8)

	# Get the number of students used in simulation
	numStudents = length(students)

	# Reset Students
	for i=1:numStudents
		students[i].gpa = 0.0
		students[i].total_credits = 0.0
		students[i].total_points = 0.0
		students[i].performance = Dict()
		students[i].termcredits = 0.0
	end
	simulation.graduated = []
	simulation.notgraduated = []

	# Matrix to hold student performance
	# Each row represents a student and each column is associated with a course.
	# A 1 signifies that the student passed the course, while a 0 indicates incomplete.
	# For example, if column 3 is a 1, then that indicates the student copleted course 3.
	enrollment = zeros(numStudents, simulation.courses)

	# Matrix to hold the number of attempts a student has made at passing a course
	attempts = ones(numStudents, simulation.courses)

	println("\nSimulating...")
	for s=1:numTerms
		# println("\t Semester $(s)")

		# Loop through terms
		# termnum is the index of the term, while term is the actual term object
		for (termnum, term) in enumerate(terms)

			# Checks the index of the current term against the current semester in the simulation.
			# This ensures that a student cant be enrolled in a course in a term later than the number
			# of terms simulated. A student cannot be enrolled in course in term 3 until at least 2 terms
			# have already been simulated.
			if termnum <= s

				# Populate Courses with Students
				# Loop through all courses in terms
				for course in term.courses

					# Sets the array of enrolled students to an empty array
					course.students = Student[]

					# Loop through students
					for i=1:numStudents
						# Checks to make sure a student can be enrolled in the current course.
						# A student must not have already completed the course and must have completed
						# the current course prereqs and must not be enrolled in more than 18 credit hours
						prereqids = map(x -> x.id, course.prereqs)
						if (length(course.prereqs) == 0 || sum(enrollment[i, prereqids]) == length(course.prereqs)) && enrollment[i, course.id] == 0.0 && students[i].termcredits + course.credits <= 18
							# If the requirements are met, push the student into the course's array of students
							push!(course.students, students[i])

							course.enrolled += 1

							# Increase the student's term credits
							students[i].termcredits += course.credits
						end
					end
				end


				# Simulate Performance
				# Loop through courses
				for course in term.courses

					# Loop through students enrolled in course
					for student in course.students
						
						features = simulation.regularFeatures
						if termnum == 1
							features = simulation.freshmanfeatures
						end

						# Set attempts for the given course...this is kind of hacky
						student.attributes[:ATTEMPTS] = attempts[student.id, course.id]

						f = studentFeatures(student, features)

						for p in course.prereqs
							f = [f student.performance[p.name]]
						end

						grade = simulation.model.predict(course, f)
						student.performance[course.name] = grade

						push!(course.grades, grade)

						if grade >= 2.0
							enrollment[student.id, course.id] = 1.0
						else
							course.failures += 1
							attempts[student.id, course.id] += 1.0
						end

						student.total_credits += course.credits
						student.total_points += grade*course.credits

					end
				end
			end
		end

		# Process term performance
		for i=1:numStudents
			students[i].termcredits = 0
			students[i].gpa = students[i].total_points / students[i].total_credits
			students[i].attributes[:GPA] = students[i].gpa
		end
	end

	simulation.studentEnrollment = enrollment

	# Compute Grad Rate
	for i=1:numStudents
		if sum(enrollment[i, :]) == simulation.courses
			simulation.gradRate += 1
			push!(simulation.graduated, students[i])
		else
			push!(simulation.notgraduated, students[i])
		end
	end

	simulation.gradRate /= numStudents
end


function simInfo(simulation)
	println("GraduationRate: $(simulation.gradRate)")

	avg_rmse = 0
	println("\nTraining RMSE Results")
	for t in simulation.terms
		for c in t.courses
			avg_rmse += c.model[:rmse]
			println("\t$(c.name): $(round(c.model[:rmse],3))")
		end
	end

	avg_rmse /= simulation.courses
	println("\tAverage RMSE: $(round(avg_rmse,3))")

	rate_error = 0
	println("\nCourse Pass Rates")
	for t in simulation.terms
		for c in t.courses
			rate = 1-c.failures / c.enrolled
			rate_error += (rate - c.passrate)^2

			println("\t$(c.name): Actual: $(round(c.passrate,3))\tSimulated: $(round(rate,3))")
		end
	end

	rate_error = sqrt(rate_error) / simulation.courses
	println("\tPass Rate RMSE: $(round(rate_error,3))")
end