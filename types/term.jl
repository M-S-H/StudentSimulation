type Term
  # Attributes
  courses::Array{Course}    # Array of courses for the term
  total_enrolled::Int       # Total number of students
  failed::Int               # Number of course failures within term

  #Constructors
  function Term(courses::Array{Course})
    this = new()

    this.courses = courses
    this.total_enrolled = 0
    this.failed = 0

    return this
  end
end