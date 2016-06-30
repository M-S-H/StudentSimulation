include("student.jl")

type Course
  # Attributes
  name::ASCIIString     # Name of the course
  id::Int         # Unique id for course

  credits::Int        # Course credit hours
  delay::Int          # The course's delay factor. This is the value of the longest path this course is on
  blocking::Int       # The course's blocking factor. This is the number of course that open up as a result of passing this course
  cruciality::Int       # The sum of the delay and blocking factor

  prereqs::Array{Course}    # Array of courses that are prereqs to this course
  postreqs::Array{Course}   # Array of courses that has this course as a prereq

  students::Array{Student}    # Array of students enrolled in the course

  model::Dict       # Model for prediction
  passrate::Float64     # Pass rate for course
  failures::Int         # Number of students who failed the course
  withdraws::Int        # Number of withdraws
  grades::Array{Float64}    # Array of all grades made
  enrolled::Int       # Total Number of students who enrolled
  termenrollment::Array{Int}    # An array of enrollment by term
  termpassed::Array{Int}    # An array of the number of students who pass each term

  # Constructors
  function Course(name::ASCIIString, credits::Int, prereqs::Array{Course})
    this = new()

    this.name = name
    this.credits = credits
    this.prereqs = prereqs
    this.postreqs = Course[]

    this.passrate = 0
    this.failures = 0
    this.enrolled = 0
    this.grades = Float64[]

    return this
  end

  # With Passrate
  function Course(name::ASCIIString, credits::Int, passrate::Float64, prereqs::Array{Course})
    this = new()

    this.name = name
    this.credits = credits
    this.prereqs = prereqs
    this.postreqs = Course[]

    this.passrate = passrate
    this.failures = 0
    this.enrolled = 0
    this.grades = Float64[]
    this.students = Student[]

    return this
  end
end