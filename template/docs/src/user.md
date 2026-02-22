```@meta
CurrentModule = {{{PKG}}}
```

# User Guide

Before starting the tutorial, please complete the [Installation](@ref) and [Quick Start](@ref) sections first.

## Tutorial

```@repl
import {{{PKG}}}
{{{PKG}}}.hello()
```

## Examples

```@example
text_1 = {{{PKG}}}.hello()
text_2 = "Goodbye, World!"
text_1 * " " * text_2
```
