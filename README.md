# test_SuperLU_DIST_jll.jl
This uses CI to test the locally installed [SuperLU_DIST_jll](https://github.com/boriskaus/LibSuperLU_DIST_jll.jl) package, before I deploy it on Yggdrasil. 


## Installation and deployment 
As this might be useful for others as well, here some steps in how to get this (and other packages) working:

1. Create a GitHub token on your github account
2. Modify the file `.julia/dev/startup.jl` on the machine where you'll build the libraries to include this line: `ENV["GITHUB_TOKEN"] = "..."` where `...` is the case-sensitive token generated on GitHub.
3. Compile local versions of the library which you compile on the most powerful local computer to which you have access. I generally build a few versions for local machines to which I have access, as well as for the github runners that do the CI testing:  
```julia
julia build_tarballs.jl --debug --verbose --deploy="boriskaus/LibSuperLU_DIST_jll.jl" aarch64-apple-darwin-libgfortran5-mpi+mpich,x86_64-linux-gnu-libgfortran5-mpi+mpich,x86_64-w64-mingw32-libgfortran5-mpi+microsoftmpi,x86_64-apple-darwin-libgfortran5-mpi+mpich
```
4. Note that if you generate a release with the same tag twice (because you are testing stuff, or changing compiler), you'll need to delete the release first on the github page.

