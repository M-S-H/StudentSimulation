import JSON

type Curriculum
  # Attributes
  terms::Array{Term}        # Array of terms
  courses::Array{Course}    # Array of courses in the curriculum
  numCourses::Int           # Number of courses
  complexity::Int           # Sum of course crucialities
  delay::Int
  blocking::Int

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

        for coreq in course.coreqs
          push!(coreq.postreqs, course)
        end
      end
    end

    for course in this.courses
      # compute complexity
      cruciality(course)
    end

    this.complexity = sum(map(x->x.cruciality, this.courses))
    this.delay = sum(map(x->x.delay, this.courses))
    this.blocking = sum(map(x->x.blocking, this.courses))
    this.numCourses = length(this.courses)

    return this
  end

  function parseCurriculum(data)
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

    # Create Courses First
    for course in data["courses"]
      name = course["name"]
      credits = course["credits"]
      passrate = course["passrate"]
      haskey(data, "termReq") ? termReq = data["termReq"] : termReq = 0

      c = Course(name, credits, termReq, passrate, Course[], Course[])
      push!(courses[course["term"]], c)
      push!(allCourses, c)
    end

    # Assign Pre and Co-Reqs
    for (i, course) in enumerate(data["courses"])
      c = allCourses[i]

      # prereqs
      prereqs = Course[]
      for prereq in course["prerequisites"]
        ind = findfirst(x -> x.name == prereq, allCourses)
        if ind != 0
          push!(prereqs, allCourses[ind])
        end
      end

      # coreqs
      coreqs = Course[]
      for coreq in course["corequisites"]
        ind = findfirst(x -> x.name == coreq, allCourses)
        if ind != 0
          push!(coreqs, allCourses[ind])
        end
      end

      c.prereqs = prereqs
      c.coreqs = coreqs
    end

    terms = Term[]
    for courseArray in courses
      push!(terms, Term(courseArray))
    end

    return terms
  end

  function Curriculum(data::Dict)
    this = Curriculum(parseCurriculum(data))
    return this
  end

  function Curriculum(name::ASCIIString)

    # Read File and Convert to JSON
    f = open("curriculums/$(name).json")
    data = JSON.parse(readall(f))
    close(f)

    this = Curriculum(parseCurriculum(data))

    return this
  end
end