using BoilingMoon, DataFrames, GLM;

data = readtable("../data/ComputerEngineeringDetailed/freshman/MATH162.csv")

Y = map(x->BoilingMoon.gradeconvert(x, expanded=false), data[:FINAL_GRADE_RECEIVED])

grades = [4.0, 3.0, 2.0, 1.0]
models = []

for grade in grades
    println(grade)
    labels = copy(Y)
    labels[labels .!= grade] = 0.0
    labels[labels .== grade] = 1.0
    data[:Y] = convert(Array{Float64,1}, labels)
    probitModel = glm(Y ~ HSGPA + ACTCOMP + ACTMATH + ACTSCIR + ACTENGL, data, Binomial(), ProbitLink())
    push!(models, probitModel)
end

predictions = []
for i = 1:length(Y)
    probs = []
    for model in models
        probability = predict(model, data[i, :])[1]
        push!(probs, probability)
    end
    push!(predictions, grades[indmax(probs)])
end

