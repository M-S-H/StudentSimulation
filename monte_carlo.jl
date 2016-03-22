function simulate(number, trials, terms, semesters)

    # Get number of courses
    courses = 0
    for term in terms
        courses += length(term.courses)
    end

    # An array that holds the graduation rates for each trial.
    rates = []

    # Loop through trials.
    for t=1:trials

        # Matrix to hold student performance
        # Each row represents a student and each column is associated with a course.
        # A 1 signifies that the student passed the course, while a 0 indicates incomplete.
        # For example, if column 3 is a 1, then that indicates the student copleted course 3.
        students = zeros(number, courses)

        enrollment = []

        # Run the simulation for the specified number of semesters.
        for s=1:semesters

            # An array that holds the number of courses a student is enrolled in. 
            # This is to ensure that a student cannot be enrolled in an unrealistic number of courses.
            enrollment = zeros(number)

            # Loop through terms.
            # termnum is the index of the term, while term is the actual term object.
            for (termnum, term) in enumerate(terms)
                
                # Checks the index of the current term against the current semester in the simulation.
                # This ensures that a student cant be enrolled in a course in a term later than the number
                # of terms simulated. A student cannot be enrolled in course in term 3 until at least 2 terms
                # have already been simulated.
                if termnum <= s

                    # Populate Courses With Students

                    # Loop through all courses in term.
                    for course in term.courses

                        # Sets the array of enrolled students to an empty array.
                        course.students = []

                        # Loop through students.
                        for i=1:number
                            # Checks to make sure a student can be enrolled in the current course.
                            # A student must not have already copleted the course and must have completed
                            # the current courses prereqs and must not be enrolled in more than 6 courses
                            if (length(course.prereqs) == 0 || sum(students[i, course.prereqs]) == length(course.prereqs)) && students[i, course.id] == 0.0 && enrollment[i] < 6
                                # If requirements are met, push student id (the index of the student row)
                                # into the courses student array.
                                push!(course.students, i)

                                # Increase student enrollment counter
                                enrollment[i] += 1
                            end
                        end
                    end


                    # Simulate Performance

                    # Loop through all courses in term.
                    for course in term.courses

                        # Loop through students enrolled in course.
                        for i in course.students
                            # Generates a random number between 0 and 100.
                            # This simulates the student's performance.
                            performance = rand(1:100)

                            # If the random number is less than the pass rate, then the student
                            # passed the class.
                            if performance <= course.rate

                                # Mark the course's corresponding column with a 1.
                                students[i, course.id] = 1.0
                            else
                                # If the student did not pass, increase the course's fail counter by 1.
                                course.failed += 1
                            end
                        end
                    end
                end             
            end
        end


        # Count Graduated Students

        # Counter for number of graduated students
        grad = 0

        for i=1:number
            # Checks if the student passed all courses
            if sum(students[i, :]) == courses
                grad += 1
            end
        end

        # Push the ratio of graduated students to all students into the rates array.
        push!(rates, grad/number)
    end

    # Return the average of all graduation rates.
    return sum(rates) / trials
end