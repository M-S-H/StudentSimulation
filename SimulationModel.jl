# Types
include("types/student.jl")
include("types/course.jl")
include("types/term.jl")
include("types/curriculum.jl")

# Helper Files
include("lib/helper.jl")
include("lib/grades_helper.jl")
include("lib/students_helper.jl")
include("lib/course_helper.jl")
include("lib/sim_helper.jl")

# Models
include("models/FrequencyModel.jl")
include("models/Retention.jl")
include("models/PassRate.jl")


# Simulation Type
# This type keeps track of all simulation information
type Simulation
	# Attributes
	curriculum::Curriculum 							# The Curriculum that will be simulated
	numTerms::Int												# The number of terms the simulation will run for

	freshmanFeatures::Array							# Array of features used to train first semester courses
	regularFeatures::Array							# Array of features used to train in non first semester courses
	model::Module												# Module that implements training and predicting student performance

	numStudents::Int 										# Number of students in the simulation
	enrolledStudents::Array{Student}		# Array of students who are enrolled in the program
	graduatedStudents::Array{Student}		# Array of students who graduated
	stopoutStudents::Array{Student}			# Array of students who stoped out
	studentEnrollment::Array						# Track whichs students have completed the various courses

	gradRate::Float64
	termGradRates::Array{Float64}
	timeToDegree::Float64
	stopoutRate::Float64
	termStopouts::Array{Float64}


	# Constructor
	# Requires a curriculum, freshman features, regular features, model
	function Simulation(curriculum, freshmanFeatures, regularFeatures, model)
		# New Instance
		this = new()

		# Assign passed in variables
		this.curriculum = curriculum
		this.freshmanFeatures = freshmanFeatures
		this.regularFeatures = regularFeatures
		this.model = model

		# Set up student arrays
		this.enrolledStudents = Student[]
		this.graduatedStudents = Student[]
		this.stopoutStudents = Student[]

		# Set up courses
		id = 1
		features = freshmanFeatures
		for term in curriculum.terms
			for course in term.courses
				# Assign each course an id
				course.id = id
				id += 1

				# Train model for course
				model.train(course, features)
			end

			features = regularFeatures
		end

		return this
	end
end


# The function that simulates students flowing through a curriculum
# The function requres a simulation type and an array of students
function simulate(simulation, students; max_credits = 18, numTerms = 8, stopouts = true, withdraws = true, locked_terms = true)
	# Determine the number of students used in the simulation
	numStudents = length(students)
	simulation.numStudents = numStudents

	# Populate the enrolled students array with the students passed in.
	simulation.enrolledStudents = copy(students)

	# Reset Simulation
	simulation.graduatedStudents = Student[]
	simulation.stopoutStudents = Student[]
	simulation.gradRate = 0.0
	simulation.termGradRates = zeros(numTerms)
	simulation.stopoutRate = 0.0

	# Assign each student a unique id
	for (i, student) in enumerate(simulation.enrolledStudents)
		student.id = i
	end

	# Matrix to hold student performance
	# Each row represents a student and each column is associated with a course.
	# A 1 signifies that the student passed the course, while a 0 indicates incomplete.
	# For example, if column 3 is a 1, then that indicates the student completed course 3.
	studentEnrollment = zeros(numStudents, simulation.curriculum.numCourses)

	# Matrix to hold the number of attempts a student has made at passing a course
	attempts = ones(numStudents, simulation.curriculum.numCourses)

	# Record number of simulation terms
	simulation.numTerms = numTerms

	# Prepare courses
	for course in simulation.curriculum.courses
		course.termenrollment = zeros(numTerms)
		course.termpassed = zeros(numTerms)
		course.students = Student[]
	end

	terms = simulation.curriculum.terms


	# Loop through the number of terms the user specified for simulation
	for currentTerm = 1:numTerms
		# Student Enrollment
		# Loops through all terms in curriculum
		for (termnum, term) in enumerate(terms)
			# Checks the index of the current term against the current semester in the simulation.
			# This ensures that a student cant be enrolled in a course in a term later than the number
			# of terms simulated. A student cannot be enrolled in course in term 3 until at least 2 terms
			# have already been simulated.
			if !locked_terms || termnum <= currentTerm
				for course in term.courses
					# Sets the array of students enrolled in the course to an empty array
					course.students = Student[]

					for student in simulation.enrolledStudents
						# Find the prereq ids of the current course
						prereqids = map(x -> x.id, course.prereqs)

						# Detemine whether the student can be enrolled in the current course.
						# A student must not have already completed the course, must have completed
						# the current course prereqs and must not be enrolled in more than 18 credit hours
						if (length(course.prereqs) == 0 || sum(studentEnrollment[student.id, prereqids]) == length(course.prereqs)) && studentEnrollment[student.id, course.id] == 0.0 && student.termcredits + course.credits <= max_credits
							# If the requirements are met, push the student into the course's array of enrolled students
							push!(course.students, student)

							# Increment the course's enrollment counter
							course.enrolled += 1
							course.termenrollment[currentTerm] += 1

							# Increase the student's term credits
							student.termcredits += course.credits
						end
					end
				end
			end
		end


		# Student Performance
		# Loop through all courses in the curriculum, term by term
		for (termnum, term) in enumerate(terms)
			# Determine which features to use based on the current term
			features = []
			termnum == 1 ? features = simulation.freshmanFeatures : features = simulation.regularFeatures

			for course in term.courses
				# Loop through all students enrolled in the current course
				for student in course.students
					# Create a vector of the student's attributes that will be used as features
					# to predict the student's performance in the class

					# Set the number of attempts the student has made at the current course
					student.attributes[:ATTEMPTS] = attempts[student.id, course.id]

					# Constrcut the feature vector from the specified student attributes
					featureVector = studentFeatures(student, features)

					# Append the students performance in prereq courses to the feature vector
					for prereq in course.prereqs
						featureVector = [featureVector student.performance[prereq.name]]
					end

					# Predict the student's outcome
					predictedGrade = simulation.model.predict_grade(course, featureVector)

					# Record the student's outcome
					student.performance[course.name] = predictedGrade

					# Log the grade for the course
					push!(course.grades, predictedGrade)

					# Assess wheter the student should pass
					if predictedGrade > 1.67
						# Mark that the student passed the course
						studentEnrollment[student.id, course.id] = 1.0

						# Log the term which the student passed the course
						course.termpassed[currentTerm] += 1
					else
						# Record the failure
						course.failures += 1

						# Increment the attempt amount
						attempts[student.id, course.id] += 1.0
					end

					# Increment the student's attempt credits and points
					student.total_credits += course.credits
					student.total_points += predictedGrade*course.credits
				end
			end
		end


		# Process term performance
		for student in simulation.enrolledStudents
			# Compute the student's GPA
			student.gpa = student.total_points / student.total_credits
			student.attributes[:GPA] = student.gpa

			# Reset the term credits to 0
			student.termcredits = 0
		end


		# Determine wheter a student has graduated
		graduatedStudentIds = []
		for (i, student) in enumerate(simulation.enrolledStudents)
			if sum(studentEnrollment[student.id, :]) == simulation.curriculum.numCourses
				# Add the student to the array of graduated students
				push!(simulation.graduatedStudents, student)

				# Record the index of the student so it can be removed from the array of enrolled students
				push!(graduatedStudentIds, i)
			end
		end
		simulation.termGradRates[currentTerm] = length(simulation.graduatedStudents) / numStudents 

		# Remove graduated students from the array of enrolled students
		deleteat!(simulation.enrolledStudents, graduatedStudentIds)


		# Determine stopouts
		if stopouts
			stopoutStudentIds = []
			for (i, student) in enumerate(simulation.enrolledStudents)
				# Predict stopout
				student.stopout = Retention.predict(currentTerm)

				if student.stopout
					# If the student is a stopout, add to array of stopout students
					push!(simulation.stopoutStudents, student)

					# Record the index of the student so it can be removed from the array of enrolled students
					push!(stopoutStudentIds, i)
				end
			end

			# Remove graduated students from the array of enrolled students
			deleteat!(simulation.enrolledStudents, stopoutStudentIds)
		end
	end


	# Compute Graduation Rate
	simulation.gradRate = length(simulation.graduatedStudents) / numStudents

	# Compute Stopout Rate
	simulation.stopoutRate = length(simulation.stopoutStudents) / numStudents
end