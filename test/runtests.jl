using PkgStarter
using Test

@testset "PkgStarter.check_status_code" begin
    @test PkgStarter.check_status_code()
end

@testset "PkgStarter.verify_package_name" begin
    @test "OK" == PkgStarter.verify_package_name("Physics")
    @test "OK" != PkgStarter.verify_package_name("")
    @test "OK" != PkgStarter.verify_package_name("JuliaPkg")
    @test "OK" != PkgStarter.verify_package_name("JustInTime")
    @test "OK" != PkgStarter.verify_package_name("algebra")
    @test "OK" != PkgStarter.verify_package_name("Linear_algebra")
    @test "OK" != PkgStarter.verify_package_name("Math+Physics")
    @test "OK" != PkgStarter.verify_package_name("algebra")
    @test "OK" != PkgStarter.verify_package_name("Eigen京")
    @test "OK" != PkgStarter.verify_package_name("VMC")
    @test "OK" != PkgStarter.verify_package_name("Cake")
    @test "OK" != PkgStarter.verify_package_name("juliaCI")
    @test "OK" != PkgStarter.verify_package_name("Jump")
    @test "OK" != PkgStarter.verify_package_name("VMCjl")
    @test "OK" != PkgStarter.verify_package_name("VMC.jl")
    @test "OK" != PkgStarter.verify_package_name("Eigen京")
end
