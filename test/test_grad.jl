using Base.Test
using ReverseDiffSparse

x = placeholders(3)

ex = @process sin(x[1])
# genfgrad(ex) # examine symbolic function
fg = genfgrad_simple(ex)

out = zeros(3)
xvals = [1.1,2.2,3.3]
fval = fg(xvals, out)
@test_approx_eq fval sin(xvals[1])
@test_approx_eq out [cos(xvals[1]),0.0,0.0]

ex = @process sin(x[1])^2
fg = genfgrad_simple(ex)
fval = fg(xvals, out)
@test_approx_eq fval sin(xvals[1])^2
@test_approx_eq out[1] sin(2xvals[1])

ex = @process x[1]*x[1]
fg = genfgrad_simple(ex)
fval = fg(xvals, out)
@test_approx_eq fval xvals[1]^2
@test_approx_eq out[1] 2*xvals[1]


ex = @process exp(sin(x[1]*x[2])) 
fg = genfgrad_simple(ex)
xvals = [3.4,2.1,6.7]
fval = fg(xvals, out)
q = xvals[1]*xvals[2] 
@test_approx_eq fval exp(sin(q)) 
@test_approx_eq out[1] xvals[2]*cos(q)*exp(sin(q)) 
@test_approx_eq out[2] xvals[1]*cos(q)*exp(sin(q)) 

ex = @process exp(sin(x[1]*x[2]+x[3]^2)) + 2x[1]*x[1]
fg = genfgrad_simple(ex)
xvals = [3.4,2.1,6.7]
fval = fg(xvals, out)
q = xvals[1]*xvals[2]+xvals[3]^2
@test_approx_eq fval exp(sin(q)) + 2xvals[1]^2
@test_approx_eq out[1] xvals[2]*cos(q)*exp(sin(q)) + 4xvals[1]
@test_approx_eq out[2] xvals[1]*cos(q)*exp(sin(q))
@test_approx_eq out[3] 2xvals[3]*cos(q)*exp(sin(q))

# test reusing the same function
xvals = [35.2,-1.2,3.9]
fval = fg(xvals, out)
q = xvals[1]*xvals[2]+xvals[3]^2
@test_approx_eq fval exp(sin(q)) + 2xvals[1]^2
@test_approx_eq out[1] xvals[2]*cos(q)*exp(sin(q)) + 4xvals[1]
@test_approx_eq out[2] xvals[1]*cos(q)*exp(sin(q))
@test_approx_eq out[3] 2xvals[3]*cos(q)*exp(sin(q))

ex = @process exp(sin(x[1]*x[2]+x[3]^2)) - 2x[1]*x[1]
fg = genfgrad_simple(ex)
xvals = [3.4,2.1,6.7]
fval = fg(xvals, out)
q = xvals[1]*xvals[2]+xvals[3]^2
@test_approx_eq fval exp(sin(q)) - 2xvals[1]^2
@test_approx_eq out[1] xvals[2]*cos(q)*exp(sin(q)) - 4xvals[1]
@test_approx_eq out[2] xvals[1]*cos(q)*exp(sin(q))
@test_approx_eq out[3] 2xvals[3]*cos(q)*exp(sin(q))

# other variables present
y = 10.0
z = 2
ex = @process z*x[1]^y
fg = genfgrad_simple(ex)
fval = fg(xvals,out)
@test_approx_eq fval z*xvals[1]^y
@test_approx_eq out[1] y*z*xvals[1]^(y-1)

# sum syntax
x = placeholders(10)
out = zeros(10)
ex = @process sum{3x[i], i = 1:10}
fg = genfgrad_simple(ex)
xvals = rand(10)
fval = fg(xvals, out)
@test_approx_eq fval 3*sum(xvals)
@test_approx_eq out fill(3.0,10)

vars = placeholders(20)
x = vars[1:10]
y = vars[11:20]
out = zeros(20)
ex = @process sum{x[i]*y[i], i = 1:10} + sin(x[1])
fg = genfgrad_simple(ex)
vals = rand(20)
fval = fg(vals, out)
@test_approx_eq fval sum([vals[i]*vals[i+10] for i in 1:10]) + sin(vals[1])
deriv = [vals[11:20],vals[1:10]]
deriv[1] += cos(vals[1])
@test_approx_eq out deriv

println("Passed tests")
