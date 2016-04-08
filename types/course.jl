include("student.jl")

type Course
	# Attributes
	name::ASCIIString			# Name of the course
	id::Int					# Unique id for course
	credits::Int				# Course credit hours
	passrate::Float64			# Pass rate for course
	failures::Int				# Number of students who failed the course
	grades::Array{Float64}		# Array of all grades made
	enrolled::Int				# Total Number of students who enrolled
	prereqs::Array{Course}		# Array of courses that are prereqs to this course
	students::Array{Student}		# Array of students enrolled in the course
	model	::Any					# Variable to hold model for predicting

	# Constructors
	function Course(name::ASCIIString, credits::Int, prereqs::Array{Course})
		this = new()

		this.name = name
		this.credits = credits
		this.prereqs = prereqs

		this.passrate = 75
		this.failures = 0
		this.enrolled = 0
		this.grades = Float64[]

		return this
	end
end