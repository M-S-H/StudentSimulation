module ProbitPassRate
    using GLM
    using CASL
    using DataFrames

    features = [:HSGPA, :ACTCOMP, :ACTMATH, :ACTSCIR, :ACTENGL]

    function student_sample(student)
        sample = Float64[]

        for f in features
            push!(sample, student.attributes[f])
        end
        return vec(sample)
    end

    function train(curriculum)
        for course in curriculum.courses
            name = join(split(course.name, " "))
            data = readtable("./data/$(curriculum.name)/freshman/$(name).csv")

            Y = map(x->BoilingMoon.gradeconvert(x), data[:FINAL_GRADE_RECEIVED])
            Y[Y .<= 1.67] = 0.0
            Y[Y .> 1.67] = 1.0

            data[:Y] = convert(Array{Float64,1}, Y)

            probitModel = 0

            try
                probitModel = glm(Y ~ HSGPA + ACTCOMP + ACTMATH + ACTSCIR + ACTENGL, data, Binomial(), ProbitLink())
                course.passrate = mean(Y)
            catch
                probitModel = 0
            end

            samples = length(Y)

            model = Dict()
            course.model = model
            model[:probitModel] = probitModel
            model[:add] = 0.0

            predictions = []
            if probitModel != 0
                for i=1:samples
                    prediction = predict(probitModel, data)[1]
                    push!(predictions, prediction)
                end
                model[:rmse] = sum(Y-predictions).^2 / samples
            else
                model[:rmse] = 0
            end
        end
    end


    function predict_grade(course, student)
        prob = 0

        sample = student_sample(student)

        if course.model[:probitModel] != 0
            prob = predict(course.model[:probitModel], [1 sample'])[1]
        else
            prob = course.passrate
        end

        roll = rand()

        prob = course.passrate

        if roll <= prob + course.model[:add]
            return 4.0
        else
            return 0.0
        end
    end


    # Predict stopout
    function predict_stopout(student, currentTerm, model)
        rates = [0.0838, 0.1334, 0.0465, 0.0631, 0.0368, 0.0189, 0.0165]
        #rates = [0.06, 0.12, ]
        if currentTerm > 7
            return false
        else
            roll = rand()
            return roll <= rates[currentTerm]
        end
    end


    function studentsFromFile(file, features)
        students = Student[]

        data = readtable(file)
        for i=1:size(data)[1]
            attributes = Dict()
            for (j, key) in enumerate(features)
                if in(key, [:ATTEMPTS])
                    continue
                end

                attributes[key] = data[i, key]
            end

            student = Student(i, attributes)
            push!(students, student)
        end

        return students
    end
end