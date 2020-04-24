---
layout: page
---

# Usage

You need to do the following to use gretlmat in a D program on Ubuntu. Should work the same for other Linux distributions, but I haven't tested it.

- Include src.d as a source file. The easiest way to do that is to copy src.d to the project directory and add src.d to the compilation command. (If you're using Dub, it should be included automatically if it's in your source directory.)
- Tell the linker about libgretl-1.0.so. (At least the file extension for libgretl will be different on Mac. On Windows, you need to tell it about your import library and have all the .dll files from the Gretl binary in the right place.)

Assuming you're compiling a file named foo.d and you've copied src.d into the project directory, this is how I compile:

```
dmd foo.d src.d -L-lgretl-1.0
```

A similar command should work for LDC or GDC.

# Compiling in Release Mode

There are lots of assert statements scattered throughout the library. I try to catch as many errors as possible. In some cases, I add duplicate error checks so I can provide better error messages. Notably, there are bounds checks on any indexed accesses to the elements of a DoubleMatrix. Negative index values and index values that exceed the length of that dimension will throw an error. You can remove that overhead by compiling in release mode. Once you're confident your code is correct, there's no longer a reason to incur that overhead.