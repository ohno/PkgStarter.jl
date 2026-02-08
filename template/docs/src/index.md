```@meta
CurrentModule = {{{PKG}}}
```

# {{{PKG}}}.jl

Documentation for [{{{PKG}}}.jl](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl).

## Install

```julia
import Pkg; Pkg.add(url="https://github.com/{{{OWNER}}}/{{{PKG}}}.jl.git")
```

## Quick Start

```julia
import {{{PKG}}}; {{{PKG}}}.hello()
```

## API Reference

```@index
```

## Citation

Please use [CITATION.bib](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/CITATION.bib) if you need to cite this package.

```@example
file = open("../../CITATION.bib", "r") # hide
text = Base.read(file, String) # hide
close(file) # hide
println(text) # hide
```