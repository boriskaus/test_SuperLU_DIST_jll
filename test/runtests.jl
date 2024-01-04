using Test, SuperLU_DIST_jll


"""
Runs a test
"""
function test_pdtest_32(; r=1, c=1, s=1, b=2, x=8, m=20)
    file = joinpath(SuperLU_DIST_jll.artifact_dir,"include","g20.rua") 

    cmd = `$(SuperLU_DIST_jll.pdtest_32()) -r $r -c $c -s $s -b $b -x $x -m $m -f $file`
    
    r = run(cmd)
    return  r
end



r = test_pdtest_32(r=1, c=1, s=1, b=2, x=8, m=20);
@test  r.exitcode==0
