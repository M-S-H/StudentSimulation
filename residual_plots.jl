using GLM
using DataFrames
using Gadfly
include("./helpers/gadfly_theme.jl")


function regressionPlot(Y, X, ylabel, xlabel, data)
    Ysym = Symbol(Y)
    Xsym = Symbol(X)
    fm = Formula(Ysym, Xsym)
    ols = glm(fm, data, Normal(), IdentityLink())
    # er = round(r2_measure(data[Ysym], predict(ols)), 3)
    println("---------")
    # println(er)
    println(ols)
    println("---------")
    
    l1 = layer(data, x=X, y=Y, Geom.point)
    
    Xmin = minimum(data[Xsym])
    Xmax = maximum(data[Xsym])
    Ymin = minimum(data[Ysym])
    Ymax = maximum(data[Ysym])
    
    newData = DataFrame()
    newData[Xsym] = [Xmin, Xmax]
    newData[Ysym] = predict(ols, newData)
    
    l2 = layer(newData, x=X, y=Y, Geom.line, Theme(default_color=colorant"red"))
    yTicks = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    filter!(y->y > Ymin && y < Ymax, yTicks)
    
    p = plot(l1,l2,Coord.cartesian(ymin=Ymin, ymax=Ymax, xmin=Xmin, xmax=Xmax), Stat.yticks(ticks=yTicks), Guide.xlabel(xlabel), Guide.ylabel(ylabel), Theme(theme))
    
    return (ols, p)
end



# Just Complexity
data = readtable("./results/web/rates/rates_80.0.csv") 
data[:gradRate10] *= 100
ols = glm(gradRate10 ~ complexity, data, Normal(), IdentityLink())
yhat = predict(ols)
r = yhat - data[:gradRate10]
newData = DataFrame(resid=r, pred=yhat)
ols, p = regressionPlot(:resid, :pred, "Residual", "Predicted 10th Term Completion Rate", newData)
draw(PNG("./results/web/complexity_80_residual.png", 1920px, 1080px), p)

# p = plot(x=yhat, y=r, Guide.xlabel("Predicted 10th Term Completion"), Guide.ylabel("Residual"), Theme(theme))
# draw(PNG("./results/web/complexity_80_residual.png", 1920px, 1080px), p)


data = readtable("./results/web/rates/rates_80.0.csv") 
data[:gradRate10] *= 100
ols = glm(gradRate10 ~ credits + complexity + centrality + reachability + edges, data, Normal(), IdentityLink())
yhat = predict(ols)
r = yhat - data[:gradRate10]
newData = DataFrame(resid=r, pred=yhat)
# p = plot(x=yhat, y=r, Guide.xlabel("Predicted 10th Term Completion"), Guide.ylabel("Residual"), Theme(theme))
# draw(PNG("./results/web/complexity_optimal_residual.png", 1920px, 1080px), p)
ols, p = regressionPlot(:resid, :pred, "Residual", "Predicted 10th Term Completion Rate", newData)
draw(PNG("./results/web/complexity_optimal_residual.png", 1920px, 1080px), p)