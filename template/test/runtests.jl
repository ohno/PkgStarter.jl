using {{{PKG}}}
using Aqua
using Test

@testset "Aqua.jl" begin
    Aqua.test_all({{{PKG}}})
end

@testset "{{{PKG}}}.hello" begin
    @test {{{PKG}}}.hello() == "Hello, World!"
end
