using PkgStarter
using Test

@testset "PkgStarter.jl" begin
    @test PkgStarter.check_status_code()
end
