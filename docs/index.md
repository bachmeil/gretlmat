---
layout: default
---

# Overview

gretlmat is a D library providing a wrapper for the matrix functionality in [Gretl](http://gretl.sourceforge.net/), which is itself a C library providing a wrapper for BLAS and LAPACK.

The goal of this project is to make it **as easy as possible to add matrix support to an existing D program**. It should be easy to use the gretlmat library, but it should also be easy to modify the library for your own needs. The full library is a single .d source file and the only dependency is libgretl. It is written in a style that should be approachable even for those new to the language.

gretlmat targets **beginners to the D programming language**. When there's a conflict between performance and ease of use, I go for ease of use. This isn't as important as you might think. Since the underlying matrix operations are done by BLAS and LAPACK, the performance of your program is mostly dependent on having performant BLAS and LAPACK, and not so much on the wrapper that sits on top of it.

# OS support

At this time, gretlmat supports only Linux (and by extension, Windows with WSL).

There's no reason it can't be used on Mac or natively on Windows. All you have to do is link to libgretl. That should be trivial on a Mac - it most likely works out of the box by adding the correct linker command when compiling - but you'll need to create an import library for libgretl on Windows.

I plan to spend my limited time finishing the library for use in my own projects rather than figuring out how to support operating systems I'll never use. Let me know if you're willing to volunteer to support native Windows or Mac users.

# Documentation

- [Installation](install.html)
- [Usage](usage.html)
- [The DoubleMatrix struct](doublemat.html) - Start here. The DoubleMatrix struct is the central data structure for this library.