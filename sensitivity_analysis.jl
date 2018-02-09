using DataFrames
using Combinatorics
using GLM

file = "ComputerEngineering.json_0.8_to_1.0.csv"

data = readtable("./results/sensitivity/$(file)")
data[:delay_blocking] = data[:delay] + data[:blocking]
data[:blocking_reachability] = data[:blocking] + data[:reachability]
# data[Symbol(term)] = data[Symbol(term)] * 100

Y = [:differene8, :difference10, :difference12]
possible = [:blocking, :delay, :centrality, :reachability, :blocking_reachability, :delay_blocking]

function r2_measure(y, f)
    y_hat = sum(y)/length(y)
    ss_tot = sum((y .- y_hat).^2)
    ss_res = sum((y - f).^2)
    return 1 - (ss_res/ss_tot)
end

for y in Y
    results = DataFrame(combinations=[], coefs=[], n=[], pMax=[], pAvg=[], r2=[])

    for i=1:length(possible)
        for c in combinations(possible, i)
            pairs = [
              [:delay_blocking, :delay],
              [:delay_blocking, :blocking],
              [:blocking_reachability, :reachability],
              [:blocking_reachability, :blocking]
            ]

            acceptable = true
            for p in pairs
                if in(p[1], c) && in(p[2], c)
                    acceptable = false
                    break
                end
            end

            if !acceptable
                println("continue")
                continue
            end

            fm = 0
            if (i==1)
                fm = Formula(y, c[1])
            else
                fm = Formula(y, Expr(:call, :+, c...))
            end

            print("$(fm): ")

            try
                model = glm(fm, data, Normal(), IdentityLink())

                # Pr
                cc = coef(model)
                se = stderr(model)
                zz = cc ./ se
                pr = 2.0 * ccdf(Normal(), abs.(zz))

                e = r2_measure(data[y], predict(model))
                push!(results, [join(c, ",") join(cc, ",") i maximum(pr) mean(pr) e])
                println("good")
            catch error
                println(error)
            end
        end
    end
    writetable("./results/sensitivity/combinations/$(file)_$(y)_combinations_with_coefs.csv", results)
end



# using DataFrames
# using GLM

# file = "ComputerEngineering.json_0.6_to_1.0.csv"

# data = readtable("./results/sensitivity/$(file)");

# function r2_measure(y, f)
#     y_hat = sum(y)/length(y)
#     ss_tot = sum((y .- y_hat).^2)
#     ss_res = sum((y - f).^2)
#     return 1 - (ss_res/ss_tot)
# end

# # All variables
# println("All Variables")
# model = glm(difference10 ~ term + delay + blocking + reachability + centrality, data, Normal(), IdentityLink())
# println(model)
# println(r2_measure(data[:difference10], predict(model)))
# println("--------------------")

# # Delay + Blocking
# println("Delay + Blocking")
# model = glm(difference10 ~ delay + blocking, data, Normal(), IdentityLink())
# println(model)
# println(r2_measure(data[:difference10], predict(model)))
# println("--------------------")

# # Reachability + Blocking
# println("Reachability + Blocking")
# model = glm(difference10 ~ reachability + blocking, data, Normal(), IdentityLink())
# println(model)
# println(r2_measure(data[:difference10], predict(model)))
# println("--------------------")

# # Centrality
# println("Centrality")
# model = glm(difference10 ~ centrality, data, Normal(), IdentityLink())
# println(model)
# println(r2_measure(data[:difference10], predict(model)))
# println("--------------------")