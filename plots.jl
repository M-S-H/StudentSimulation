using GLM
using DataFrames
using Gadfly
include("./helpers/gadfly_theme.jl")


# R2
function r2_measure(y, f)
    y_hat = sum(y)/length(y)
    ss_tot = sum((y .- y_hat).^2)
    ss_res = sum((y - f).^2)
    return 1 - (ss_res/ss_tot)
end


# Helper Function
function regressionPlot(Y, X, ylabel, xlabel, data)
    Ysym = Symbol(Y)
    Xsym = Symbol(X)
    fm = Formula(Ysym, Xsym)
    ols = glm(fm, data, Normal(), IdentityLink())
    er = round(r2_measure(data[Ysym], predict(ols)), 2)
    
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
    
    p = plot(l1,l2,Coord.cartesian(ymin=Ymin, ymax=Ymax, xmin=Xmin, xmax=Xmax), Stat.yticks(ticks=yTicks), Guide.xlabel(xlabel), Guide.ylabel(ylabel), Guide.manual_color_key("", ["R^2: $(er)"], ["red"]), Theme(theme))
    
    return (ols, p)
end

# Multiple Features
function multipleRegressionPlot(Y, features, ylabel, xlabel, data)
    Ysym = Symbol(Y)
    # Xsym = Symbol(X)

    fm = Formula(Ysym, Expr(:call, :+, features...))

    # fm = Formula(Ysym, Xsym)
    ols = glm(fm, data, Normal(), IdentityLink())
    er = round(r2_measure(data[Ysym], predict(ols)), 2)

    c = coef(ols)
    newX = zeros(size(data)[1])
    # newX .+= c[1]
    for (i, f) in enumerate(features)
        newX += data[f] * -c[i+1]
    end

    tempData = DataFrame()
    tempData[:Y] = data[Ysym]
    tempData[:X] = newX

    regressionPlot(:Y, :X, ylabel, xlabel, tempData)

    # l1 = layer(tempData, x="X", y="Y", Geom.point)
    
    # Xmin = minimum(tempData[:X])
    # Xmax = maximum(tempData[:X])
    # Ymin = minimum(tempData[:Y])
    # Ymax = maximum(tempData[:Y])

    # newData = DataFrame()
    # newData[:X] = [Xmin, Xmax]
    # newols = glm(Y ~ X, tempData, Normal(), IdentityLink())
    # newData[Ysym] = predict(newols, newData)
    
    # l2 = layer(newData, x="X", y=Y, Geom.line, Theme(default_color=colorant"red"))
    
    # p = plot(l1,l2,Coord.cartesian(ymin=Ymin, ymax=Ymax, xmin=Xmin, xmax=Xmax), Guide.xlabel(xlabel), Guide.ylabel(ylabel), Guide.manual_color_key("", ["R^2: $(er)"], ["red"]), Theme(theme))
    
    # return (ols, p)
end

# Simple Curriculum Plots
# 50% Complexity
data = readtable("./results/simple/rates/rates_50.0.csv")
data[:gradRate5] *= 100
ols, p = regressionPlot(:gradRate5, :complexity, "5th Term Completion Rate", "Complexity", data)
draw(PNG("./results/simple/complexity_50.png", 1920px, 1080px), p)

# 85% Complexity
data = readtable("./results/simple/rates/rates_80.0.csv")
data[:gradRate5] *= 100
ols, p = regressionPlot(:gradRate5, :complexity, "5th Term Completion Rate", "Complexity", data)
draw(PNG("./results/simple/complexity_80.png", 1920px, 1080px), p)

# Web Curricula Plots
# 80% Complexity
data = readtable("./results/web/rates/rates_80.0.csv")
data[:gradRate10] *= 100
ols, p = regressionPlot(:gradRate10, :complexity, "5th Term Completion Rate", "Complexity", data)
draw(PNG("./results/web/complexity_80.png", 1920px, 1080px), p)

# Web Curricula Plots
# 80% Complexity With Credits
data = readtable("./results/web/rates/rates_80.0.csv")
data[:gradRate10] *= 100
ols, p = multipleRegressionPlot(:gradRate10, [:complexity, :credits], "5th Term Completion Rate", "Complexity, Credit Hours", data)
draw(PNG("./results/web/complexity_credits_80.png", 1920px, 1080px), p)


# # Web Curricula Plots
# # 85% Complexity
# data = readtable("./results/web/rates/rates_85.0.csv")
# data[:gradRate10] *= 100
# ols, p = regressionPlot(:gradRate10, :complexity, "5th Term Completion Rate", "Complexity", data)
# draw(PNG("./results/web/complexity_85.png", 1920px, 1080px), p)

# # Web Curricula Plots
# # 85% Complexity With Credits
# data = readtable("./results/web/rates/rates_85.0.csv")
# data[:gradRate10] *= 100
# ols, p = multipleRegressionPlot(:gradRate10, [:complexity, :credits], "5th Term Completion Rate", "Complexity, Credit Hours", data)
# draw(PNG("./results/web/complexity_credits_85.png", 1920px, 1080px), p)