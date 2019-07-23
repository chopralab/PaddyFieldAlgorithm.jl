import Base.clamp

export Parameter,
       ParameterValue,
       DefaultParameter,
       RangeNormalizedParameter,
       ZNormalizedParameter,
       seed

"This represents a parameter which can be optimized by the Paddy Field Algorithm"
abstract type Parameter{T <: Real} end

"""
    norm(v, value)

Normalizes a `Real` value with the rules provided by `Parameter` v
"""
function norm end

"""
    unnorm(v, value)

Inverses the normalization performed on a `Real` value provided by `Parameter` v
"""
function unnorm end

"""
    clamp(v, value)

Ensures that a `Real` value is an allowed value for `Parameter` v
"""
function clamp end

"""
    init(v)

Initializes a random value for `Parameter` v
"""
function init end

"A `ParameterValue` is a combination of a value(`v`) and a gaussian."
struct ParameterValue
    v :: Real
    gaussian :: AbstractFloat
end

ParameterValue(v::Real) = ParameterValue(v, 0.0)

Base.Real(pv::ParameterValue) = pv.v

Base.convert(::Type{ParameterValue}, x::Real) = ParameterValue(x, 0.0)

"A `Parameter` that is not normalized, but is limited by bounds (limit)"
struct DefaultParameter{T<:Real} <: Parameter{T}
    limits :: Pair{T, T}
end

norm(v::DefaultParameter, value::Real) = value

unnorm(v::DefaultParameter, value::Real) = value

clamp(v::DefaultParameter, value::Real) = clamp(value, v.limits.first, v.limits.second)

init(v::DefaultParameter) = ParameterValue(rand() * (v.limits.second - v.limits.first) + v.limits.first, 0.0)

"A `Parameter` that is normalized to be in a linear range."
struct RangeNormalizedParameter{T<:Real} <: Parameter{T}
    limits :: Pair{T, T}
end

norm(v::RangeNormalizedParameter, value::Real) = (value - v.limits.first) / (v.limits.second - v.limits.first)

unnorm(v::RangeNormalizedParameter, value::Real) = value * (v.limits.second - v.limits.first) + v.limits.first

clamp(v::RangeNormalizedParameter, value::Real) = clamp(value, v.limits.first, v.limits.second)

init(v::RangeNormalizedParameter) = ParameterValue(rand() * (v.limits.second - v.limits.first) + v.limits.first, 0.0)

"A `Parameter` that is normalized to be normally distributed with a mean and standard deviation"
struct ZNormalizedParameter{T <: Real} <: Parameter{T}
    limits :: Pair{T, T}
    μ :: T
    σ :: T
end

norm(v::ZNormalizedParameter, value::Real) = (value - v.μ) / v.σ

unnorm(v::ZNormalizedParameter, value::Real) = value * v.σ + v.μ

clamp(v::ZNormalizedParameter, value::Real) = clamp(value, v.limits.first, v.limits.second)

init(v::ZNormalizedParameter) = ParameterValue(clamp(v, randn() * v.σ + v.μ), 0.0)

"""
    seed(param, value; scale, scaled)

Mutates a `ParameterValue` value using the rules defined by `Parameter` param
"""
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
