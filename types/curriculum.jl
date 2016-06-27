import JSON

type Curriculum
	# Attributes
	terms::Array{Term}			# Array of terms
	courses::Array{Course}		# Array of courses in the curriculum
	numCourses::Int				# Number of courses
	complexity::Int				# Sum of course crucialities

	#Constructors
	function Curriculum(terms::Array{Term})
		this = new()

		this.terms = terms
		this.courses = Course[]

		for term in terms
			for course in term.courses
				push!(this.courses, course)

				# Add postreq link
				for prereq in course.prereqs
					push!(prereq.postreqs, course)
				end
			end
		end

		for course in this.courses
			# compute complexity
			cruciality(course)
		end

		this.complexity = sum(map(x->x.cruciality, this.courses))
		this.numCourses = length(this.courses)

		return this
	end

	function Curriculum(name::ASCIIString)

		# Read File and Convert to JSON
		f = open("curriculums/$(name).json")
		data = JSON.parse(readall(f))
		close(f)

		# Sort Courses By Term
		sort!(data["courses"], by = x->x["term"])

		# Number of terms
		terms = data["terms"]

		# Array of Course Arrays, one for each term
		courses = Array(Array{Course}, terms)
		for i=1:terms
			courses[i] = Course[]
		end

		allCourses = Course[]

		for course in data["courses"]
			name = course["name"]
			credits = course["credits"]
			passrate = course["passrate"]

			prereqs = Course[]
			for prereq in course["prerequisites"]
				ind = findfirst(x -> x.name == prereq, allCourses)
				if ind != 0
					push!(prereqs, allCourses[ind])
				end
			end

			c = Course(name, credits, passrate, prereqs)
			push!(courses[course["term"]], c)
			push!(allCourses, c)
		end

		terms = Term[]
		for courseArray in courses
			push!(terms, Term(courseArray))
		end

		this = Curriculum(terms)

		return this
	end
end