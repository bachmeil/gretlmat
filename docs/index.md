---
layout: default
---

# Overview

gretlmat is a D wrapper over the matrix functionality in [Gretl](http://gretl.sourceforge.net/). Gretl is written in C and provides a simple interface to BLAS and LAPACK.

The goal of this project is to make it **as easy as possible to add matrix support to an existing D program**. It should be easy to use the gretlmat library and easy to modify the library for your needs. The full library is a single .d source file and the only dependency is libgretl. 

gretlmat targets **beginners to the D programming language**. When there's a conflict between performance and ease of use, I go for ease of use. Since the underlying matrix operations are handled by calling BLAS and LAPACK, the performance of your program is mostly dependent on having a good BLAS and LAPACK, not the wrapper that sits on top of it.

# OS support

At this time, gretlmat supports only Linux (and thus Windows with WSL).

There is no reason it can't be used on Mac or natively on Windows. All you have to do is link to libgretl. That shouldn't take much on a Mac - and most likely works out of the box by adding the correct linker command when compiling - but you'll need to create an import library for libgretl on Windows.

I plan to spend my limited time finishing the library for use in my own projects. Let me know if you're willing to volunteer to support native Windows or Mac users.

# Documentation

- [Installation](install.html)
- [Usage](usage.html)
- [The DoubleMatrix struct](doublemat.html) - Start here. The DoubleMatrix struct is the central data structure for this library.