@testset "Single Objective Extrema optimization" begin
    @testset "Gramacy-Lee function" begin
        import Random
        f(x) = (sin.(10 .* pi .* x) ./ (2 .* x)) + ((x .- 1) .^ 4)
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(0.5,2.5)

        Random.seed!(1)
        point, min_val = optimize_function(extrema_fact, fitness_function)
        @test point.inputs[1].v ≈ 0.54856 atol = 1e-4
        @test min_val ≈ 0.8690 atol = 1.0e-4
    end

    @testset "Ackley function" begin
        import Random
        f(x,y) = -20.0*exp(-0.2*sqrt(0.5*(x^2 + y^2)))-exp(0.5*(cos(2*pi*x) + cos(2*pi*y))) + exp(1.0) + 20.0
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-5,5,-5,5)

        Random.seed!(1)
        point, min_val = optimize_function(extrema_fact, fitness_function)
        @test point.inputs[1].v ≈ 0.0 atol = 1e-4
        @test point.inputs[2].v ≈ 0.0 atol = 1e-4
        @test abs(min_val) < 1.0e-4
    end

    @testset "Beale function" begin
        import Random
        f(x, y) = (1.5 - x + x*y)^2 + (2.25 -x + x*y^2)^2 + (2.625 -x + x*y^3)^2
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-4.5,4.5,-4.5,4.5)

        Random.seed!(2)
        point, min_val = optimize_function(extrema_fact, fitness_function)
        @test point.inputs[1].v ≈ 3.0 atol = 2e-2
        @test point.inputs[2].v ≈ 0.5 atol = 2e-2
        @test abs(min_val) < 1.0e-4
    end

    @testset "Goldstein-Price function" begin
        import Random
        f(x, y) = (1 + ((x + y + 1)^2) * (19 - 14x + 3x^2 - 14y + 6x*y + 3y^2)) *
                  (30 + ((2x - 3y)^2) * (18 - 32x + 12x^2 + 48y - 36x*y + 27y^2))
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-2.0,2.0,-2.0,2.0)

        Random.seed!(20)
        point, min_val = optimize_function(extrema_fact, fitness_function; iterations = 100)
        @test point.inputs[1].v ≈ 0.0 atol = 2e-2
        @test point.inputs[2].v ≈ -1 atol = 2e-2
        @test min_val ≈ -3 atol = 2e-2   
    end

    @testset "Booth function" begin
        import Random
        f(x, y) = (x + 2y -7)^2 + (2x + y - 5)^2
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-10.0,10.0,-10.0,10.0)

        Random.seed!(2)
        point, min_val = optimize_function(extrema_fact, fitness_function)
        @test point.inputs[1].v ≈ 1.0 atol = 2e-2
        @test point.inputs[2].v ≈ 3.0 atol = 2e-2
        @test abs(min_val) < 1.0e-4
    end

    @testset "Bukin function N. 6" begin
        import Random
        f(x, y) = 100*sqrt(abs(y - 0.01x^2)) + 0.01*abs(x + 10)
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-15.0,-5.0, -3.0,3.0)

        # We get lucky......
        Random.seed!(202)
        point, min_val = optimize_function(extrema_fact, fitness_function; iterations = 1000)
        @test point.inputs[1].v ≈ -10.0 atol = 0.1
        @test point.inputs[2].v ≈  1.0 atol = 0.1
        @test abs(min_val) < 0.1
    end

    @testset "Matyas function" begin
        import Random
        f(x, y) = 0.26*(x^2 + y^2) - 0.48*x*y
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-10.0,10.0,-10.0,10.0)

        Random.seed!(2)
        point, min_val = optimize_function(extrema_fact, fitness_function; iterations = 100)
        @test point.inputs[1].v ≈ 0.0 atol = 2e-2
        @test point.inputs[2].v ≈ 0.0 atol = 2e-2
        @test abs(min_val) < 1.0e-4
    end
    @testset "Levi function N. 13" begin
        import Random
        f(x, y) = sin(3pi*x)^2 + (x-1)^2*(1 + sin(3pi*y)) + (y - 1)^2*(1+sin(2pi*2)^2)
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-10,10,-10,10)

        Random.seed!(1)
        point, min_val = optimize_function(extrema_fact, fitness_function; iterations = 100)
        @test point.inputs[1].v ≈ 1.0 atol = 1e-4
        @test point.inputs[2].v ≈ 1.0 atol = 1e-4
        @test abs(min_val) < 1.0e-4
    end
    @testset "Three-hump camel function" begin
        import Random
        f(x, y) = 2x^2 - 1.05x^4 + x^6/6 + x*y + y^2
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-5.0,5.0,-5.0,5.0)

        Random.seed!(2)
        point, min_val = optimize_function(extrema_fact, fitness_function; iterations = 100)
        @test point.inputs[1].v ≈ 0.0 atol = 2e-2
        @test point.inputs[2].v ≈ 0.0 atol = 2e-2
        @test abs(min_val) < 1.0e-4
    end
    @testset "Easom function" begin
        import Random
        f(x, y) = -cos(x) * cos(y) * exp( -((x - pi)^2 + (y- pi)^2))
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-100.0,100.0,-100.0,100.0)

        Random.seed!(2)
        point, min_val = optimize_function(extrema_fact, fitness_function; iterations = 100)
        @test point.inputs[1].v ≈ pi atol = 2e-2
        @test point.inputs[2].v ≈ pi atol = 2e-2
        @test min_val ≈ 1 atol = 1.0e-4
    end
    @testset "Eggholder function" begin
        import Random
        f(x, y) = -(y+47)*sin(sqrt(abs(x/2 + (y+47)))) - x*sin(sqrt(abs(x - (y+47))))
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-512.0,512.0,-512.0,512.0)

        Random.seed!(201)
        point, min_val = optimize_function(extrema_fact, fitness_function; iterations = 10)
        @test point.inputs[1].v ≈ 512 atol = 2e-2
        @test point.inputs[2].v ≈ 404.2319 atol = 2e-2
        @test min_val ≈ 959.6407 atol = 0.01
    end
    @testset "McCormick function" begin
        import Random
        f(x, y) = sin(x + y) + (x - y)^2 - 1.5x + 2.5y + 1
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-1.5,4.0,-3.0,4.0)

        Random.seed!(201)
        point, min_val = optimize_function(extrema_fact, fitness_function; iterations = 10)
        @test point.inputs[1].v ≈ -0.54719 atol = 2e-2
        @test point.inputs[2].v ≈ -1.54719 atol = 2e-2
        @test min_val ≈ 1.9133 atol = 0.01
    end
    @testset "Schaffer function N. 2" begin
        import Random
        f(x, y) = 0.5 + (sin(x^2 - y^2)^2 -0.5) / ( (1 + 0.001(x^2 + y^2))^2 )
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(-100.0,100.0,-100.0,100.0)

        Random.seed!(202)
        point, min_val = optimize_function(extrema_fact, fitness_function; iterations = 1000)
        @test point.inputs[1].v ≈ 0 atol = 2e-2
        @test point.inputs[2].v ≈ 0 atol = 2e-2
        @test min_val ≈ 0 atol = 0.01
    end
    @testset "Wolfe function" begin
        import Random
        f(x, y, z) = 4/3 * (x^2 + y^2 -x*y)^(0.75) + z
        fitness_function(s::ExtremaSolution) = -fitness(s, f)
        extrema_fact = ExtremaSolutionFactory(0.0,2.0, 0.0,2.0, 0.0,2.0)

        Random.seed!(201)
        point, min_val = optimize_function(extrema_fact, fitness_function; iterations = 10)
        @test point.inputs[1].v ≈ 0.0 atol = 2e-2
        @test point.inputs[2].v ≈ 0.0 atol = 2e-2
        @test point.inputs[3].v ≈ 0.0 atol = 2e-2
        @test min_val ≈ 0.0 atol = 0.01
    end
end
