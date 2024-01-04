# test_SuperLU_DIST_jll.jl
This uses CI to test the locally installed [SuperLU_DIST_jll](https://github.com/boriskaus/LibSuperLU_DIST_jll.jl) package, before I deploy it on Yggdrasil. 

I'm using a rather powerful local server for this (apollo), on which I build 3 versions of the package (for the 3 main operating systems) using:
```julia
julia build_tarballs.jl --debug --verbose --deploy="boriskaus/LibSuperLU_DIST_jll.jl" aarch64-apple-darwin-libgfortran5-mpi+mpich,x86_64-linux-gnu-libgfortran5-mpi+mpich,x86_64-w64-mingw32-libgfortran5-mpi+microsoftmpi
```
Note that if you generate a release with the same tag twice (because you are testing stuff), you'll need to delete the release first on github.
