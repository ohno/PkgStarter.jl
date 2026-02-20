```@meta
CurrentModule = {{{PKG}}}
```

# {{{PKG}}}.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://{{{OWNER}}}.github.io/{{{PKG}}}.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://{{{OWNER}}}.github.io/{{{PKG}}}.jl/dev/)
[![Build Status](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/{{{OWNER}}}/{{{PKG}}}.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/{{{OWNER}}}/{{{PKG}}}.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

Documentation for [{{{PKG}}}.jl](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl).

## Installation

Run the following command in the Julia REPL or in a notebook:

```julia
import Pkg; Pkg.add(url="https://github.com/{{{OWNER}}}/{{{PKG}}}.jl.git")
```

## Quick Start

After installation, run the following example to load the package and verify it works:

```julia
import {{{PKG}}}; {{{PKG}}}.hello()
```

## User Guide

For detailed usage instructions and examples, see the [User Guide](user.md).

## Developer Guide

For information on contributing to this project, see the [Developer Guide](developer.md).

## Support

Feature requests and bug reports are handled via GitHub [Issues](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/issues).

## API Reference

```@index
```

## Citation

[CITATION.bib](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/CITATION.bib) is available for citing this package.

```@example
file = open("../../CITATION.bib", "r") # hide
text = Base.read(file, String) # hide
close(file) # hide
println(text) # hide
```

## License

This package is released under the [MIT License](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/LICENSE).

```@example
file = open("../../LICENSE", "r") # hide
text = Base.read(file, String) # hide
close(file) # hide
println(text) # hide
```

## Acknowledgment

This package is written in the [Julia programming language](https://julialang.org/), built on an initial project template generated using [PkgStarter.jl](https://github.com/ohno/PkgStarter.jl). This repository is hosted on [GitHub](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl), and continuous integration is run using [GitHub Actions](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/actions).
