# DoubleMatrix

This is the matrix struct that is the centerpiece of gretlmat.

## Public Members

- `double[] data`: The data array
- `int rows`: Number of rows
- `int cols`: Number of columns

Examples:

```
auto m = DoubleMatrix(3, 2);
writeln("Number of rows: ", m.rows);
writeln("Number of columns: ", m.cols);

// Directly access an element of the matrix
// Better to use the index operators, but this works
m.data[0] = 4.5;
```

## Calling Gretl Functions

*None of the information in this section is required to use gretlmat. It is provided in case you want to go beyond the functionality provided by gretlmat.*

If there is functionality provided by libgretl that is not available in gretlmat (normally this would be for statistical analysis) it is possible to call those functions by passing a `DoubleMatrix` as an argument, as it aliases to a Gretl matrix. As is common in C libraries, it is common for functions to take a pointer to a matrix as the argument. If `m` is a `DoubleMatrix`, you can pass a pointer to the matrix as a function argument by using `m.matptr`. Alternatively, the function might take a pointer to the underlying data array. Consistent with D practice, you can get that pointer (a `double *`) using `m.ptr`.

## Constructor

Examples:

```
// Allocate a (6x2) matrix
auto m = DoubleMatrix(6,2);

// Allocate a (6x1) matrix, aka a vector
// The default is 1 column
auto v = DoubleMatrix(6);
```

The dimensions you pass to the constructor can be of any type that converts to int using `std.conv.to`. This restriction ensures that the conversion makes sense (no strings, for instance) and checks for overflow (the leading case being arguments that are long, as you'd have if you call `length` on a `double[]`).

```
double[] a = [1.2, 3.4, 5.6];
auto m = DoubleMatrix(a.length);
```

# dim

Returns the dimensions of the vector as an array.

```
auto m = DoubleMatrix(3,2);
writeln(m.dim); // [3, 2]
```
