import Base.clamp

export Parameter,
       DefaultParameter,
       RangeNormalizedParameter,
       ZNormalizedParameter,
       seed

"This represents a parameter which can be optimized by the Paddy Field Algorithm"
abstract type Parameter{T <: Real} end

struct ParameterValue
    v :: Real
    gaussian :: AbstractFloat
end

Real(asdf::PaddyFieldAlgorithm.ParameterValue) = asdf.v

"Normalizes a value with the rules provided by a `Parameter`"
norm(v::Parameter, value::Real) = value

"Inverses the normalization"
unnorm(v::Parameter, value::Real) = value

"Ensures that value is an allowed value for a parameter"
clamp(v::Parameter, value::Real) = value

"Initializes a random parameter"
init(v::Parameter) = ParameterValue(rand(), 0.0)

struct DefaultParameter{T<:Real} <: Parameter{T}
    limits :: Pair{T, T}
end

clamp(v::DefaultParameter, value::Real) = clamp(value, v.limits.first, v.limits.second)

init(v::DefaultParameter) = ParameterValue(rand() * (v.limits.second - v.limits.first) + v.limits.first, 0.0)

struct RangeNormalizedParameter{T<:Real} <: Parameter{T}
    limits :: Pair{T, T}
end

norm(v::RangeNormalizedParameter, value::Real) = (value - v.limits.first) / (v.limits.second - v.limits.first)

unnorm(v::RangeNormalizedParameter, value::Real) = value * (v.limits.second - v.limits.first) + v.limits.first

clamp(v::RangeNormalizedParameter, value::Real) = clamp(value, v.limits.first, v.limits.second)

init(v::RangeNormalizedParameter) = ParameterValue(rand() * (v.limits.second - v.limits.first) + v.limits.first, 0.0)

struct ZNormalizedParameter{T <: Real} <: Parameter{T}
    limits :: Pair{T, T}
    μ :: T
    σ :: T
end

norm(v::ZNormalizedParameter, value::Real) = (value - v.μ) / v.σ

unnorm(v::ZNormalizedParameter, value::Real) = value * v.σ + v.μ

clamp(v::ZNormalizedParameter, value::Real) = clamp(value, v.limits.first, v.limits.second)

init(v::ZNormalizedParameter) = ParameterValue(clamp(v, randn() * v.σ + v.μ), 0.0)

function seed(param::T, value::ParameterValue; scale::Real = 0.2, scaled = true) where T <: Parameter
    b_norm = norm(param, value.v) + scale^(10^value.gaussian) * randn()
    g = unnorm(param, b_norm)
    g = clamp(param, g)

    if scaled
        ParameterValue(g, value.gaussian + scale * randn())
    else
        ParameterValue(g, value.gaussian)
    end
end
