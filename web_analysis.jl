using DataFrames
using Combinatorics
using GLM

data = readtable("./results/web/rates.csv");
data = data[data[:creditHours] .< 150, :]

Y = [:gradRate10, :averageTTD]
possible = [:complexity, :blocking, :delay, :inverseBlocking, :centrality, :creditHours, :free, :timeComp1]

function r2_measure(y, f)
    y_hat = sum(y)/length(y)
    ss_tot = sum((y .- y_hat).^2)
    ss_res = sum((y - f).^2)
    return 1 - (ss_res/ss_tot)
end

function rse_measure(y, f, p)
    rss = sum((y - f).^2)
    return sqrt(rss/(length(y)-p-1))
end

for y in Y
    results = DataFrame(combinations=[], n=[], pMax=[], pAvg=[], r2=[], rse1=[], rse2=[])
    for i=1:length(possible)        
        for c in combinations(possible, i)

            if in(:complexity, c) && in(:timeComp1, c)
                continue
            elseif in(:complexity, c) && in(:blocking, c)
                continue
            elseif in(:complexity, c) && in(:delay, c)
                continue
            elseif in(:timeComp1, c) && in(:blocking, c)
                continue
            elseif in(:timeComp1, c) && in(:delay, c)
                continue
            end

            fm = 0
            if (i==1)
                fm = Formula(y, c[1])
            else
                fm = Formula(y, Expr(:call, :+, c...))
            end

            try
                model = glm(fm, data, Normal(), IdentityLink())

                # Pr
                cc = coef(model)
                se = stderr(model)
                zz = cc ./ se
                pr = 2.0 * ccdf(Normal(), abs.(zz))

                e = r2_measure(data[y], predict(model))
                rse = rse_measure(data[y], predict(model), i)
                rse2 = rse_measure(data[y], predict(model), i+1)
                push!(results, [join(c, ",") i maximum(pr) mean(pr) e rse rse2])
            catch error
            end
        end
    end
    writetable("./results/web/$(y)Analysis_100_150.csv", results)
end