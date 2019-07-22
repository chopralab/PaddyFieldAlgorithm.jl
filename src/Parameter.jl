import Base.clamp

export Parameter,
       DefaultParameter,
       RangeNormalizedParameter,
       ZNormalizedParameter,
       seed

"This represents a parameter which can be optimized by the Paddy Field Algorithm"
abstract type Parameter{T <: Real} end

"Normalizes a value with the rules provided by a `Parameter`"
norm(v::Parameter, value::Real) = value

"Inverses the normalization"
unnorm(v::Parameter, value::Real) = value

"Ensures that value is an allowed value for a parameter"
clamp(v::Parameter, value::Real) = value

"Initializes a random parameter"
init(v::Parameter) = rand()

struct DefaultParameter{T<:Real} <: Parameter{T}
    limits :: Pair{T, T}
end

clamp(v::DefaultParameter, value::Real) = clamp(value, v.limits.first, v.limits.second)

init(v::DefaultParameter) = rand() * (v.limits.second - v.limits.first) + v.limits.first

struct RangeNormalizedParameter{T<:Real} <: Parameter{T}
    limits :: Pair{T, T}
end

norm(v::RangeNormalizedParameter, value::Real) = (value - v.limits.first) / (v.limits.second - v.limits.first)

unnorm(v::RangeNormalizedParameter, value::Real) = value * (v.limits.second - v.limits.second) + v.limits.first

clamp(v::RangeNormalizedParameter, value::Real) = clamp(value, v.limits.first, v.limits.second)

init(v::RangeNormalizedParameter) = rand() * (v.limits.second - v.limits.first) + v.limits.first

struct ZNormalizedParameter{T <: Real} <: Parameter{T}
    limits :: Pair{T, T}
    μ :: T
    σ :: T
end

norm(v::ZNormalizedParameter, value::Real) = (value - v.μ) / v.σ

unnorm(v::ZNormalizedParameter, value::Real) = value * v.σ + v.μ

clamp(v::ZNormalizedParameter, value::Real) = clamp(value, v.limits.first, v.limits.second)

init(v::ZNormalizedParameter) = clamp(v, randn() * v.σ + v.μ)

function seed(v::T, param::Real, gaussian::Real; scale::Real = 0.2, scaled = true) where T <: Parameter
    b_norm = norm(v, param) + scale^(10^gaussian) * randn()
    g = unnorm(v, b_norm)
    g = clamp(v, g)

    if scaled
        (g, gaussian + scale * randn())
    else
        (g, 0.0)
    end
end
