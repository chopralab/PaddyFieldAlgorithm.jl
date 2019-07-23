export LinearSolution,
       LinearSolutionFactory,
       PolynomialSolution,
       PolynomialSolutionFactory,
       TrigonometricSolution,
       TrigonometricSolutionFactory,
       show

"""
A `RegressionSolution` attempts to fit a function to a set of points where the
fitness is defined by the Mean Squared Error between the predicted y and true y

``fitness(x,y) = -\\sum_{i}^{length(x)}(f(x_i) - y_i)^2``

Where **f** is the `Solution`, x is a one dimensional input space, and y is the
output space. *Note* the negative sign in the equation above which is necessary
as the goal of the *Paddy Field Algorithm* is to maximize fitness.
"""
abstract type RegressionSolution <: Solution end

fitness(s::RegressionSolution, x, y) = -sum((s(x) .- y) .^ 2)

"""
`LinearSolution` contains two variables, a slope(`m`) and an intercept(`b`).

It is a regressive `Solution` which fits the following function:
``y(x) = m*x + b``

The distance between a `LinearSolution` and a second `LinearSolution` is
``d(m_1,m_2,b_1,b_2) = (m_1 - m_2)^2 + (b_1 - b_2)^2``
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
end

LinearSolutionFactory() = LinearSolutionFactory(
    DefaultParameter(Pair(-100, 100)),
    DefaultParameter(Pair(-100, 100)),
)

create_solution(s::LinearSolutionFactory) = LinearSolution(init(s.m), init(s.b))

function propagate_solution(sf::LinearSolutionFactory, sl::LinearSolution)
    LinearSolution(seed(sf.m, sl.m), seed(sf.b, sl.b))
end

"""
`PolynomialSolution` is a regressive `Solution` which fits the following function:
``y(x) = \\sum_{i=0}^{Degree}c_i x^i``

Degree is defined by the user to be a positive integer and the distance between
a `PolynomialSolution` and a second `PolynomialSolution` is
``d(c^1,c^2) = \\sum_{i=0}^{Degree}(c_i^1 - c_i^2)^2``
"""
struct PolynomialSolution <: RegressionSolution
    coefficients :: Vector{ParameterValue}
end

(s::PolynomialSolution)(x) = sum([ c.v .* x.^(p-1) for (p, c) in enumerate(s.coefficients)])

distance(s1::PolynomialSolution, s2::PolynomialSolution) = sum((Real.(s1.coefficients) .- Real.(s2.coefficients)).^2)

function Base.show(io::IO, s::PolynomialSolution)
    print(io, "y(x) = Σ(")
    for (k, c) in enumerate(s.coefficients)
        c_print = round(c.v; digits = 4)
        print(io, " $(c_print) * x^$(k-1),")
    end
    print(io, ")")
end                                                                

struct PolynomialSolutionFactory <: SolutionFactory
    coefficients::Vector{Parameter}
end

PolynomialSolutionFactory(degree :: Int) = PolynomialSolutionFactory(
    [DefaultParameter(Pair(-10,10)) for _ in 1:(degree+1)],
)

create_solution(s::PolynomialSolutionFactory) = PolynomialSolution([init(c) for c in s.coefficients])

function propagate_solution(sf::PolynomialSolutionFactory, sl::PolynomialSolution)
    PolynomialSolution([seed(sfc, slp) for (sfc, slp) in zip(sf.coefficients, sl.coefficients)])
end

"""
`TrigonometricSolution` is a regressive `Solution` which fits the following function:
``y(x) = c_0 + \\sum_{j=1}^{Degree/2}(c_{2j} cos(2jπx) + c_{2j+1} sin(2jπx))``

Degree is defined by the user to be a positive integer and the distance between
a `TrigonometricSolution` and a second `TrigonometricSolution` is
``d(c^1,c^2) = (c_0^1 - c_0^2)^2 + \\sum_{i=1}^{Degree}(c_i^1 - c_i^2)^2``
"""
struct TrigonometricSolution <: RegressionSolution
    c_0 :: ParameterValue
    cos_coef :: Vector{ParameterValue}
    sin_coef :: Vector{ParameterValue}
end

(s::TrigonometricSolution)(x) = s.c_0.v .+
                                sum([c.v .* cos.(k.*x.*2 .*pi) for (k,c) in enumerate(s.cos_coef)]) +
                                sum([c.v .* sin.(k.*x.*2 .*pi) for (k,c) in enumerate(s.sin_coef)])

distance(s1::TrigonometricSolution, s2::TrigonometricSolution) = (s1.c_0.v - s2.c_0.v)^2 +
                                                                 sum((Real.(s1.cos_coef) .- Real.(s2.cos_coef)).^2) +
                                                                 sum((Real.(s1.sin_coef) .- Real.(s2.sin_coef)).^2)

function Base.show(io::IO, s::TrigonometricSolution)
    print(io, "y(x) = Σ(")
    for (k, c) in enumerate(s.cos_coef)
        c_print = round(c.v; digits = 4)
        print(io, " $(c_print) * cos(2π*$(k)*x),")
    end
    for (k, c) in enumerate(s.sin_coef)
        c_print = round(c.v; digits = 4)
        print(io, " $(c_print) * sin(2π*$(k)*x),")
    end
    c_0_print = round(s.c_0.v; digits = 4)
    print(io, " $(c_0_print))")
end                                                                
                                                                
struct TrigonometricSolutionFactory <: SolutionFactory
    c_0 :: Parameter
    cos_coef :: Vector{Parameter}
    sin_coef :: Vector{Parameter}
end

TrigonometricSolutionFactory(degree :: Int) = TrigonometricSolutionFactory(
    DefaultParameter(Pair(-10,10)),
    [DefaultParameter(Pair(-10,10)) for _ in 1:degree],
    [DefaultParameter(Pair(-10,10)) for _ in 1:degree],
)

function create_solution(s::TrigonometricSolutionFactory)
    TrigonometricSolution(
        init(s.c_0),
        [init(c) for c in s.cos_coef],
        [init(s) for s in s.sin_coef],
    )
end

function propagate_solution(sf::TrigonometricSolutionFactory, sl::TrigonometricSolution)
    TrigonometricSolution(
        seed(sf.c_0, sl.c_0),
        [seed(sfc, slp) for (sfc, slp) in zip(sf.cos_coef, sl.cos_coef)],
        [seed(sfc, slp) for (sfc, slp) in zip(sf.sin_coef, sl.sin_coef)],
    )
end
