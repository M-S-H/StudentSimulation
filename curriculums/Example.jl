course1 = Course("Course One", 3, 0.8, Course[])
course2 = Course("Course Two", 3, 0.7, Course[])
course3 = Course("Course Three", 3, 0.7, Course[])

course4 = Course("Course Four", 3, 0.7, [course1, course3])
course5 = Course("Course Five", 3, 0.65, [course2])

course6 = Course("Course Six", 3, 0.8, [course5])


# Define Terms
term1 = Term([course1, course2, course3])
term2 = Term([course4, course5])
term3 = Term([course6])

terms = [term1, term2, term3]