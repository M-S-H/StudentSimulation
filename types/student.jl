type Student
	id::Int						# Unique ID for student	
	total_credits::Int 				# The total number of credit hours the student has earned	
	gpa::Float64					# The student's GPA
	total_points::Float64				# The total number of points the student has earned
	attributes::Dict					# A dictionary of a student's attributes

	stopout::Bool					# Indicates wheter the student has stoped out
	stopsem::Int 					# The term a student stops out
	termcredits::Int					# Indicates how many credits a student is enrolled in during a term
	performance::Dict				# Stores the grades the student has made in each class


	# Constructors
	function Student(id, attributes)
		this = new()
		this.id = id
		this.termcredits = 0
		this.performance = Dict()
		this.gpa = 0.0
		this.total_credits = 0
		this.total_points = 0
		this.attributes = attributes

		return this	
	end
end