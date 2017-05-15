if length(ARGS) == 0
    println("Must specify curricula type.")
    exit()
end

if length(ARGS) == 1
    println("Must specify reporting term")
end

using DataFrames
using Combinatorics
using GLM

curricula = ARGS[1]
term = ARGS[2]
difficulty = 80.0

if length(ARGS) == 3
    difficulty = parse(Float64, ARGS[3])
end

data = readtable("./results/$(curricula)/rates/rates_$(difficulty).csv");
data[Symbol(term)] = data[Symbol(term)] * 100

Y = [Symbol(term), :averageTTD]
possible = [:credits, :complexity, :blocking, :delay, :centrality, :reachability, :free, :edges]

function r2_measure(y, f)
    y_hat = sum(y)/length(y)
    ss_tot = sum((y .- y_hat).^2)
    ss_res = sum((y - f).^2)
    return 1 - (ss_res/ss_tot)
end

for y in Y
    results = DataFrame(combinations=[], n=[], pMax=[], pAvg=[], r2=[])

    if y == :averageTTD
        data = data[data[:name] .!= "Biology - 44.json", :]
    end

    for i=1:length(possible)
        for c in combinations(possible, i)
            pairs = [
                [:complexity, :term_complexity],
                [:blocking, :term_blocking],
                [:delay, :term_delay],
                [:centrality, :term_centrality],
                [:reachability, :term_reachability],
                [:complexity, :blocking],
                [:complexity, :delay],
                [:complexity, :term_blocking],
                [:complexity, :term_delay],
                [:term_complexity, :delay],
                [:term_complexity, :blocking],
                [:term_complexity, :term_delay],
                [:term_complexity, :term_blocking]
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
                push!(results, [join(c, ",") i maximum(pr) mean(pr) e])
                println("good")
            catch error
                println(error)
            end
        end
    end
    writetable("./results/$(curricula)/$(y)_$(difficulty)_combinations.csv", results)
end