export Solution
export SolutionFactory

export LinearSolution
export LinearSolutionFactory

export distance
export create_solution

"A `Solution` is optimized by the Paddy algorithm to maximize fitness"
abstract type Solution end

"Calculates how fit a given solution is"
fitness(s::Solution) = 0.0

"Calculates the distance between `Solution` s1 and `Solution` s2."
distance(s1::Solution, s2::Solution) = 0.0

"A `SolutionFactory` initialize and mutates a `Solution` randomly."
abstract type SolutionFactory end

"initializes a random `Solution`."
create_solution(s::SolutionFactory) = 0.0

"""
`LinearSolution` contains two variables, a slope(`m`) and an intercept(`b`).

It is a regressive `Solution` which fits the following function:
``y(x) = m*x + b``
"""
struct LinearSolution <: Solution
    m :: Real
    b :: Real
    m_gaussian :: Real
    b_gaussian :: Real
end

(s::LinearSolution)(x) = (s.m .* x .+ s.b)

fitness(s::LinearSolution, x, y) = -sum((s(x) .- y) .^ 2)

distance(s1::LinearSolution, s2::LinearSolution) = (s1.m - s2.m)^2 + (s1.b - s2.b)^2

function show(io::IO, s::LinearSolution)
    println(io, "y(x) = $(s.m)*m + $(s.b)")
end

struct LinearSolutionFactory <: SolutionFactory
    m::Parameter
    b::Parameter
    LinearSolutionFactory() = new(
        DefaultParameter(Pair(-100, 100)),
        DefaultParameter(Pair(-100, 100)),
    )
end

create_solution(s::LinearSolutionFactory) = LinearSolution(init(s.m), init(s.b), 0.0, 0.0)

function propagate_solution(sf::LinearSolutionFactory, sl::LinearSolution)
    m, m_g = seed(sf.m, sl.m, sl.m_gaussian)
    b, b_g = seed(sf.b, sl.b, sl.b_gaussian)
    LinearSolution(m, b, m_g, b_g)
end

"""
`PolynomialSolution` contains a variable number of coefficients.

It is a regressive `Solution` which fits the following function:
``y(x) = c0 * x^0 + c1 * x^1 + c2 * x^2 + c3 * x^3 + ... + cn * x^n``
"""
struct PolynomialSolution <: Solution
    coefficients :: Vector{Real}
    gaussians :: Vector{Real}
end

(s::PolynomialSolution)(x) = sum([ c.*x.^(p-1) for (p, c) in pairs(IndexStyle(s.coefficients), s.coefficients)])

fitness(s::PolynomialSolution, x, y) = -sum((s(x) .- y) .^ 2)

distance(s1::PolynomialSolution, s2::PolynomialSolution) = sum((s1.coefficients .- s2.coefficients).^2)

struct PolynomialSolutionFactory <: SolutionFactory
    coefficients::Vector{Parameter}
    PolynomialSolutionFactory(degree :: Int) = new(
        [DefaultParameter(Pair(-10,10)) for _ in 1:(degree+1)],
    )

    PolynomialSolutionFactory()
end

function create_solution(s::PolynomialSolutionFactory)
    PolynomialSolution([init(c) for c in s.coefficients], repeat([0.0], length(s.coefficients)))
end

function propagate_solution(sf::PolynomialSolutionFactory, sl::PolynomialSolution)
    c = Vector{Real}()
    g = Vector{Real}()
    for (sfc, s1c, s1g) in zip(sf.coefficients, sl.coefficients, sl.gaussians)
        c2, g2 = seed(sfc, s1c, s1g)
        append!(c, [c2])
        append!(g, [g2])
    end
    PolynomialSolution(c, g)
end

"""
`TrigonometricSolution` contains a variable number of coefficients.

It is a regressive `Solution` which fits the following function:
``y(x) = c0 * x^0 + c1 * x^1 + c2 * x^2 + c3 * x^3 + ... + cn * x^n``
"""
struct TrigonometricSolution <: Solution
    b_0 :: Real
    cos_coef :: Vector{Real}
    sin_coef :: Vector{Real}
    gaussian_b :: Real
    gaussian_c :: Vector{Real}
    gaussian_s :: Vector{Real}
end

(s::TrigonometricSolution)(x) = s.b_0 .+
                                sum([c .* cos.(k*x) for (c,k) in enumerate(s.cos_coef)]) +
                                sum([c .* sin.(k*x) for (c,k) in enumerate(s.sin_coef)])

fitness(s::TrigonometricSolution, x, y) = -sum((s(x) .- y) .^ 2)

distance(s1::TrigonometricSolution, s2::TrigonometricSolution) = (s1.b_0 - s2.b_0)^2 +
                                                                 sum((s1.cos_coef .- s2.cos_coef).^2) +
                                                                 sum((s1.sin_coef .- s2.sin_coef).^2)

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
        0.0,
        repeat([0.0], length(s.cos_coef)),
        repeat([0.0], length(s.sin_coef)),
    )
end

function propagate_solution(sf::TrigonometricSolutionFactory, sl::TrigonometricSolution)
    b, bg = seed(sf.b_0, sl.b_0, sl.gaussian_b)
    c = Vector{Real}()
    s = Vector{Real}()
    cg = Vector{Real}()
    sg = Vector{Real}()
    for (sfc, s1c, s1g) in zip(sf.cos_coef, sl.cos_coef, sl.gaussian_c)
        c2, g2 = seed(sfc, s1c, s1g)
        append!(c, [c2])
        append!(cg, [g2])
    end
    for (sfc, s1c, s1g) in zip(sf.sin_coef, sl.sin_coef, sl.gaussian_s)
        c2, g2 = seed(sfc, s1c, s1g)
        append!(s, [c2])
        append!(sg, [g2])
    end
    TrigonometricSolution(b, c, s, bg, cg, sg)
end
