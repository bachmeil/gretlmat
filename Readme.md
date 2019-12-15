# gretlmat

This library makes it as easy as possible to add matrix and vector support to a D program on Linux, Mac, or Windows.

# Features

- Matrix and vector types.
- Operators for common operations like addition, subtraction, and multiplication.
- Support for common linear algebra operations.
- Vectors are ranges that support `foreach`.
- Rows and columns have their own types and are ranges that support `foreach`.
- Matrices can be used as ranges to iterate over rows or columns to support `foreach`.
- Multidimensional slicing provides convenient submatrix selection.

# Design Principles

- A libary optimized for *ease of use* rather than *speed of execution*.
- Full documentation with an example of usage for every feature.
- One file that holds everything.
- Works with any modern D compiler on any OS supported by D, using DMD, LDC, or GDC.
- No understanding of memory management required.
- No knowledge of C required.
- Code that is easy to read and extend with intermediate knowledge of D.
- Backward compatibility after the 1.0 release.
- Stability - only bug fixes after the 1.0 release.
- Independence from the build system.

# Nongoals

- Optimize for speed of execution.
- Avoid the garbage collector.
- Extensive template usage/metaprogramming.
- Expand to cover all use cases.
- Non-GPL license. If for some reason the GPL bothers you, this is not your library. Gretl is GPL and my code is not independent of the Gretl code. This is only relevant if you plan to distribute code that is a derived work of gretlmat.
