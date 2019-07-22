@testset "Linear fit" begin
    import Random

    xs = [i for i in 1.0:9.0]
    ys = xs .* 2.0 .+ 3.0

    Random.seed!(1)
    linear_factory = LinearSolutionFactory()
    fit, mse = optimize_function(linear_factory, xs, ys; iterations=200)

    @test fit.m ≈ 2.0 atol = 1e-4
    @test fit.b ≈ 3.0 atol = 1e-4
    @test mse < abs(1.0e-4)
end

@testset "Polynomial fit" begin
    import Random

    xs = [i for i in -3.0:0.01:3.0]
    ys = 4.0 .* xs .^ 3 .- 5.0 .* xs .^ 2 .+ 3.0 .* xs .+ 1.0

    Random.seed!(20)
    poly_fact = PolynomialSolutionFactory(3)
    fit, mse = optimize_function(poly_fact, xs, ys; iterations = 200)

    @test fit.coefficients[1] ≈ +1.0 atol = 1e-4
    @test fit.coefficients[2] ≈ +3.0 atol = 1e-4
    @test fit.coefficients[3] ≈ -5.0 atol = 1e-4
    @test fit.coefficients[4] ≈ +4.0 atol = 1e-4
    @test mse < abs(1.0e-4)
end

@testset "Trigonometric fit" begin
    import Random

    gramacy_lee(x) = (sin.(10 .* pi .* x) ./ (2 .* x)) + ((x .- 1) .^ 4)
end
