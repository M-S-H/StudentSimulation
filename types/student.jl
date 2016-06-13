type Student
	id::Int						# Unique ID for student				
	termcredits::Int					# Indicates how many credits a student is enrolled in during a term
	stopout::Bool					# Indicates wheter the student has stoped out
	stopsem::Int 					# The term a student stops out
	enrollment::Array				# Keeps track of the courses a student has passed
	performance::Dict				# Stores the grades the student has made in each class
	gpa::Float64					# The student's GPA
	total_credits::Int 				# The total number of credit hours the student has earned
	total_points::Float64				# The total number of points the student has earned
	features::Array{Float64}			# The features of the student used for predictions
	attributes::Dict


	# Constructors
	function Student(id, attributes)
		this = new()
		this.id = id
		this.termcredits = 0
		this.performance = Dict()
		this.gpa = 0.0
		this.total_credits = 0
		this.total_points = 0
		this.	features = []
		this.attributes = attributes

		return this	
	end
end