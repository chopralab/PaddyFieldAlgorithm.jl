export LinearSolution,
       LinearSolutionFactory,
       PolynomialSolution,
       PolynomialSolutionFactory,
       TrigonometricSolution,
       TrigonometricSolutionFactory,
       show

"A `RegressionSolution` attempts to fit a function to a set of points."
abstract type RegressionSolution <: Solution end

fitness(s::RegressionSolution, x, y) = -sum((s(x) .- y) .^ 2)

"""
`LinearSolution` contains two variables, a slope(`m`) and an intercept(`b`).

It is a regressive `Solution` which fits the following function:
``y(x) = m*x + b``
"""
struct LinearSolution <: RegressionSolution
    m :: ParameterValue
    b :: ParameterValue
end

(s::LinearSolution)(x) = (s.m.v .* x .+ s.b.v)

distance(s1::LinearSolution, s2::LinearSolution) = (s1.m.v - s2.m.v)^2 + (s1.b.v - s2.b.v)^2

Base.show(io::IO, s::LinearSolution) = print(io, "y(x) = $(s.m.v)*x + $(s.b.v)")

struct LinearSolutionFactory <: SolutionFactory
    m::Parameter
    b::Parameter
    LinearSolutionFactory() = new(
        DefaultParameter(Pair(-100, 100)),
        DefaultParameter(Pair(-100, 100)),
    )
end

create_solution(s::LinearSolutionFactory) = LinearSolution(init(s.m), init(s.b))

function propagate_solution(sf::LinearSolutionFactory, sl::LinearSolution)
    LinearSolution(seed(sf.m, sl.m), seed(sf.b, sl.b))
end

"""
`PolynomialSolution` contains a variable number of coefficients.

It is a regressive `Solution` which fits the following function:
``y(x) = c0 * x^0 + c1 * x^1 + c2 * x^2 + c3 * x^3 + ... + cn * x^n``
"""
struct PolynomialSolution <: RegressionSolution
    coefficients :: Vector{ParameterValue}
end

(s::PolynomialSolution)(x) = sum([ c.v .* x.^(p-1) for (p, c) in enumerate(s.coefficients)])

distance(s1::PolynomialSolution, s2::PolynomialSolution) = sum((Real.(s1.coefficients) .- Real.(s2.coefficients)).^2)

struct PolynomialSolutionFactory <: SolutionFactory
    coefficients::Vector{Parameter}
    PolynomialSolutionFactory(degree :: Int) = new(
        [DefaultParameter(Pair(-10,10)) for _ in 1:(degree+1)],
    )
end

create_solution(s::PolynomialSolutionFactory) = PolynomialSolution([init(c) for c in s.coefficients])

function propagate_solution(sf::PolynomialSolutionFactory, sl::PolynomialSolution)
    PolynomialSolution([seed(sfc, slp) for (sfc, slp) in zip(sf.coefficients, sl.coefficients)])
end

"""
`TrigonometricSolution` contains a variable number of coefficients.

It is a regressive `Solution` which fits the following function:
``y(x) = c0 * x^0 + c1 * x^1 + c2 * x^2 + c3 * x^3 + ... + cn * x^n``
"""
struct TrigonometricSolution <: RegressionSolution
    b_0 :: ParameterValue
    cos_coef :: Vector{ParameterValue}
    sin_coef :: Vector{ParameterValue}
end

(s::TrigonometricSolution)(x) = s.b_0.v .+
                                sum([c.v .* cos.(k.*x.*2 .*pi) for (k,c) in enumerate(s.cos_coef)]) +
                                sum([c.v .* sin.(k.*x.*2 .*pi) for (k,c) in enumerate(s.sin_coef)])

distance(s1::TrigonometricSolution, s2::TrigonometricSolution) = (s1.b_0.v - s2.b_0.v)^2 +
                                                                 sum((Real.(s1.cos_coef) .- Real.(s2.cos_coef)).^2) +
                                                                 sum((Real.(s1.sin_coef) .- Real.(s2.sin_coef)).^2)

struct TrigonometricSolutionFactory <: SolutionFactory
    b_0 :: Parameter
    cos_coef :: Vector{Parameter}
    sin_coef :: Vector{Parameter}
    TrigonometricSolutionFactory(degree :: Int) = new(
        DefaultParameter(Pair(-10,10)),
        [DefaultParameter(Pair(-10,10)) for _ in 1:degree],
        [DefaultParameter(Pair(-10,10)) for _ in 1:degree],
    )
end

function create_solution(s::TrigonometricSolutionFactory)
    TrigonometricSolution(
        init(s.b_0),
        [init(c) for c in s.cos_coef],
        [init(s) for s in s.sin_coef],
    )
end

function propagate_solution(sf::TrigonometricSolutionFactory, sl::TrigonometricSolution)
    TrigonometricSolution(
        seed(sf.b_0, sl.b_0),
        [seed(sfc, slp) for (sfc, slp) in zip(sf.cos_coef, sl.cos_coef)],
        [seed(sfc, slp) for (sfc, slp) in zip(sf.sin_coef, sl.sin_coef)],
    )
end
