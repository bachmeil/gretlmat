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

# License

GPLv2

# Design Principles

- Optimized for *ease of use* rather than *speed of execution*.
- Full documentation, with a usage example for every feature.
- The entire library goes in one file. No dependencies other than Gretl.
- Works with any modern release of DMD, LDC, or GDC on any OS supported by D.
- No understanding of memory management required to use the library.
- No knowledge of C required to use the library.
- Code that's easy to read and extend with no more than an intermediate
    knowledge of D. Templates and metaprogramming might be great fun,
    but they can make the code hard to read and work with. They should
    be used only when it really is the simplest solution, and there
    should be comments in the code for someone that doesn't have that
    knowledge.
- Stability - only bug fixes after the 1.0 release. It should be possible
    to use this library ten years in the future even if I make no updates.
    Users can write code knowing that it will work even if I disappear.
    In the extremely unlikely case that a change in the language itself 
    breaks something, see the previous item. If I decide to make major
    changes, I'll start a new project with a new name - something I wish
    other projects would do.
- Compilation of programs with one simple line in the terminal.
    This reduces the need to learn new
    things, but there's a larger advantage. I can't guarantee
    stability (write code today and run it five years from now) if I
    rely on a build system that doesn't offer the same guarantee. Github
    will probably still be around in five years. The compiler will probably
    still compile programs the same way in five years. Gretl is heavily
    used and won't change the functionality I'm wrapping in the next five
    years.

# Nongoals

- Optimize for speed of execution.
- Avoid the garbage collector.
- Demonstrate the power of the D programming language.
- Handle all use cases.
- Adoption outside of academic research and students.
- Non-GPL license. If for some reason the GPL bothers you, this is not 
    the right library for you. Gretl is GPL and my code is not 
    independent of the Gretl code. If you are selling a commercial
    product and do not want to release the source code under the GPL or
    a compatible license, don't use this library. If it's for your 
    personal use, commercial or otherwise, the GPL lets you do whatever
    you want. I understand that some companies want a more freeloader-friendly
    license. I'm available for hire as a consultant if you want me to do
    related work under a different license.
