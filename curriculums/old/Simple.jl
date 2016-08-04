course1 = Course("Course One", 3, 0.8, Course[])

course2 = Course("Course Two", 3, 0.7, [course1])
course3 = Course("Course Three", 3, 0.7, [course1])

course4 = Course("Course Four", 3, 0.7, [course3])
course5 = Course("Course Five", 3, 0.7, [course3])

course6 = Course("Course Six", 3, 0.7, [course5])

# Define Terms
term1 = Term([course1])
term2 = Term([course2, course3])
term3 = Term([course4, course5])
term4 = Term([course6])

terms = [term1, term2, term3, term4]