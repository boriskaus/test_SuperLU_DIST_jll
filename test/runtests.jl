using Test, SuperLU_DIST_jll
# this runs tests that are basically the same as in the SuperLU_DIST package itself, but with the JLL package

# Show the host platform
@show  SuperLU_DIST_jll.host_platform
@show  names(SuperLU_DIST_jll)

"""
Runs a test
"""
function test_pdtest(; cores=1, r=1, c=1, s=1, b=2, x=8, m=20, int32=true)
    file = joinpath(SuperLU_DIST_jll.artifact_dir,"include","g20.rua") 

    if int32
        exe="$(SuperLU_DIST_jll.pdtest_32_path)"
    else
        exe="$(SuperLU_DIST_jll.pdtest_64_path)"
    end

    cmd = `$mpirun -n $cores $exe -r $r -c $c -s $s -b $b -x $x -m $m -f $file`
    
    # Very important to deactivate this - of not all kinds of issues occur
    cmd = deactivate_multithreading(cmd)

    r = run(cmd)
    return  r
end

#setup MPI
const mpiexec = if isdefined(SuperLU_DIST_jll,:MPICH_jll)
    SuperLU_DIST_jll.MPICH_jll.mpiexec()
elseif isdefined(SuperLU_DIST_jll,:MicrosoftMPI_jll) 
    SuperLU_DIST_jll.MicrosoftMPI_jll.mpiexec()
elseif isdefined(SuperLU_DIST_jll,:OpenMPI_jll) 
    SuperLU_DIST_jll.OpenMPI_jll.mpiexec()
elseif isdefined(SuperLU_DIST_jll,:MPItrampoline_jll) 
    SuperLU_DIST_jll.MPItrampoline_jll.mpiexec()
else
    println("Be careful! No MPI library detected; parallel runs won't work")
    nothing
end
mpirun = setenv(mpiexec, SuperLU_DIST_jll.JLLWrappers.JLLWrappers.LIBPATH_env=>SuperLU_DIST_jll.LIBPATH[]);


function deactivate_multithreading(cmd::Cmd)
    # multithreading of the BLAS libraries that is installed by default with the julia BLAS
    # does not work well. Switch that off:
    cmd = addenv(cmd,"OMP_NUM_THREADS"=>1)
    cmd = addenv(cmd,"VECLIB_MAXIMUM_THREADS"=>1)

    return cmd
end

@testset "int32" begin
    int32=true
    @testset "1x1_1_2_8_20_SP" begin
        r = test_pdtest(cores=1, r=1, c=1, s=1, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end
    @testset "pdtest_1x1_3_2_8_20_SP" begin
        r = test_pdtest(cores=1, r=1, c=1, s=3, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end
    @testset "pdtest_1x2_1_2_8_20_SP" begin
        r = test_pdtest(cores=2, r=1, c=2, s=1, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end
    @testset "pdtest_1x2_3_2_8_20_SP" begin
        r = test_pdtest(cores=2, r=1, c=2, s=3, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end
    @testset "pdtest_1x3_1_2_8_20_SP" begin
        r = test_pdtest(cores=3, r=1, c=3, s=1, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end

    @testset "pdtest_1x3_3_2_8_20_SP" begin
        r = test_pdtest(cores=3, r=1, c=3, s=3, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end

    @testset "pdtest_5x3_3_2_8_20_SP" begin
        r = test_pdtest(cores=15, r=5, c=3, s=3, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end

end

@testset "int64" begin
    int32=false
    @testset "1x1_1_2_8_20_SP" begin
        r = test_pdtest(cores=1, r=1, c=1, s=1, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end
    @testset "pdtest_1x1_3_2_8_20_SP" begin
        r = test_pdtest(cores=1, r=1, c=1, s=3, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end
    @testset "pdtest_1x2_1_2_8_20_SP" begin
        r = test_pdtest(cores=2, r=1, c=2, s=1, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end
    @testset "pdtest_1x2_3_2_8_20_SP" begin
        r = test_pdtest(cores=2, r=1, c=2, s=3, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end
    @testset "pdtest_1x3_1_2_8_20_SP" begin
        r = test_pdtest(cores=3, r=1, c=3, s=1, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end

    @testset "pdtest_1x3_3_2_8_20_SP" begin
        r = test_pdtest(cores=3, r=1, c=3, s=3, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end

    @testset "pdtest_5x3_3_2_8_20_SP" begin
        r = test_pdtest(cores=15, r=5, c=3, s=3, b=2, x=8, m=20, int32=int32);
        @test  r.exitcode==0
    end

end

#=

#add_test(pdtest_1x3_3_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "3" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "1" "-c" "3" "-s" "3" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
#set_tests_properties(pdtest_1x3_3_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_2x1_1_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "2" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "2" "-c" "1" "-s" "1" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_2x1_1_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_2x1_3_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "2" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "2" "-c" "1" "-s" "3" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_2x1_3_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_2x2_1_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "4" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "2" "-c" "2" "-s" "1" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_2x2_1_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_2x2_3_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "4" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "2" "-c" "2" "-s" "3" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_2x2_3_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_2x3_1_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "6" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "2" "-c" "3" "-s" "1" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_2x3_1_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_2x3_3_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "6" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "2" "-c" "3" "-s" "3" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_2x3_3_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_5x1_1_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "5" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "5" "-c" "1" "-s" "1" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_5x1_1_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_5x1_3_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "5" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "5" "-c" "1" "-s" "3" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_5x1_3_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_5x2_1_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "10" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "5" "-c" "2" "-s" "1" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_5x2_1_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_5x2_3_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "10" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "5" "-c" "2" "-s" "3" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_5x2_3_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_5x3_1_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "15" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "5" "-c" "3" "-s" "1" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_5x3_1_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
add_test(pdtest_5x3_3_2_8_20_SP "/opt/petsc/petsc-3.18.6-opt-kokkos-gcc13/bin/mpiexec" "-n" "15" "/Users/kausb/Software/superlu_dist/build/TEST/pdtest" "-r" "5" "-c" "3" "-s" "3" "-b" "2" "-x" "8" "-m" "20" "-f" "/Users/kausb/Software/superlu_dist/EXAMPLE/g20.rua")
set_tests_properties(pdtest_5x3_3_2_8_20_SP PROPERTIES  _BACKTRACE_TRIPLES "/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;47;add_test;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;78;add_superlu_dist_tests;/Users/kausb/Software/superlu_dist/TEST/CMakeLists.txt;0;")
=#