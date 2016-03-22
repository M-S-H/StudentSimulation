include("./types.jl")
include("./monte_carlo.jl")

# Define terms
t1 = Term([Course("One", 1, []), Course("Two", 2, []), Course("Three", 3, [])]);
t2 = Term([Course("Four", 4, [1]), Course("Five", 5, [2])]);
t3 = Term([Course("Six", 6, [4,5]), Course("Seven", 7, [3])]);
terms = [t1 t2 t3]


grad_rate = simulate(200, 100, terms, 4)

println(grad_rate)