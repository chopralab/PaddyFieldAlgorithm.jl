@testset "Linear fit" begin
    import Random

    xs = [i for i in 1.0:9.0]
    ys = xs .* 2.0 .+ 3.0

    Random.seed!(1)
    linear_factory = LinearSolutionFactory()
    fit, mse = optimize_function(linear_factory, xs, ys; iterations=50)

    @test fit.m.v ≈ 2.0 atol = 1e-4
    @test fit.b.v ≈ 3.0 atol = 1e-4
    @test mse < abs(1.0e-4)

    linear_factory = LinearSolutionFactory(
        RangeNormalizedParameter(Pair(-100, 100)),
        RangeNormalizedParameter(Pair(-100, 100)),
    )

    fit, mse = optimize_function(linear_factory, xs, ys; iterations=50)

    @test fit.m.v ≈ 2.0 atol = 1e-3
    @test fit.b.v ≈ 3.0 atol = 1e-3
    @test mse < abs(1.0e-4)

    linear_factory = LinearSolutionFactory(
        ZNormalizedParameter( Pair(-5, 5), 1, 4),
        ZNormalizedParameter( Pair(-5, 5), 1, 4),
    )

    fit, mse = optimize_function(linear_factory, xs, ys; iterations=50)

    @test fit.m.v ≈ 2.0 atol = 1e-3
    @test fit.b.v ≈ 3.0 atol = 1e-3
    @test mse < abs(1.0e-4)

    repr(fit)
end

@testset "Polynomial fit" begin
    import Random

    xs = [i for i in -3.0:0.01:3.0]
    ys = 4.0 .* xs .^ 3 .- 5.0 .* xs .^ 2 .+ 3.0 .* xs .+ 1.0

    Random.seed!(20)
    poly_fact = PolynomialSolutionFactory(3)
    fit, mse = optimize_function(poly_fact, xs, ys; iterations = 100)

    @test fit.coefficients[1].v ≈ +1.0 atol = 1e-4
    @test fit.coefficients[2].v ≈ +3.0 atol = 1e-4
    @test fit.coefficients[3].v ≈ -5.0 atol = 1e-4
    @test fit.coefficients[4].v ≈ +4.0 atol = 1e-4
    @test mse < abs(1.0e-4)

    # Doesn't fail
    repr(fit)
end

@testset "Trigonometric fit" begin
    import Random

    xs = [i for i in -pi:0.01:pi]
    ys = 5.0 .+ 2.0 .* cos.(xs .* pi .* 2) .- sin.(xs .* pi .* 2 .* 2)

    Random.seed!(1)
    trig_fact = TrigonometricSolutionFactory(2)
    fit, mse = optimize_function(trig_fact, xs, ys; iterations = 100)

    @test fit.c_0.v ≈ 5.0 atol = 1e-4
    @test fit.cos_coef[1].v ≈ +2.0 atol = 1e-3
    @test fit.cos_coef[2].v ≈ +0.0 atol = 1e-3
    @test fit.sin_coef[1].v ≈ +0.0 atol = 1e-3
    @test fit.sin_coef[2].v ≈ -1.0 atol = 1e-3
    @test mse < abs(1.0e-4)
    # gramacy_lee(x) = (sin.(10 .* pi .* x) ./ (2 .* x)) + ((x .- 1) .^ 4)

    repr(fit)
end
