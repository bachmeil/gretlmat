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
// Better to use the index operators
m.data[0] = 4.5;
```

## Calling Gretl Functions

*None of the information in this section is required to use gretlmat. It is provided in case you want to go beyond the functionality provided by gretlmat.*

If there is functionality provided by libgretl that is not available in gretlmat (normally this would be for statistical analysis) it is possible to call those functions by passing a `DoubleMatrix` as an argument, as it aliases to a Gretl matrix. As is common in C libraries, it is common for functions to take a pointer to a matrix as the argument. If `m` is a `DoubleMatrix`, you can pass a pointer to the matrix as a function argument by using `m.matptr`. Alternatively, the function might take a pointer to the underlying data array. Consistent with D practice, you can get that pointer (a `double *`) using `m.ptr`.

## Constructor

### Method 1

Examples:

```
// Allocate a (6x2) matrix
auto m = DoubleMatrix(6,2);

// Allocate a (6x1) matrix, aka a vector
// The default is 1 column
auto v = DoubleMatrix(6);
```

The dimensions you pass to the constructor can be of any type that converts to int using `std.conv.to`. This restriction ensures that the conversion makes sense (no strings, for instance) and checks for overflow (the leading case being arguments that are long, as you'd have if you call `length` on a `double[]`.

```
double[] a = [1.2, 3.4, 5.6];
auto m = DoubleMatrix(a.length);
```

### Method 2

You can pass an array of `double[]`, where each element (each `double[]`) is a row. The `[]` notation means you have an array of whatever came before. Thus, `double[][]` is an array of `double[]`. If you want, you can do this to be clearer:

```
alias row = double[];
row[] m;
```

which is the same as

```
double[][] m;
```

Usage example:

```
// Create the rows
double[][] rs;
rs ~= [1.1, 2.2, 3.3];
rs ~= [4.4, 5.5, 6.6];
auto m = DoubleMatrix(rs); // m is (2x3)
```

Note that this copies the data from `rs` into `m`.

If you set the second argument (`rowElements`) to `false`, it treats each element as a column instead of a row:

```
// Create the columns
double[][] rs;
rs ~= [1.1, 2.2, 3.3];
rs ~= [4.4, 5.5, 6.6];
auto m = DoubleMatrix(rs); // m is (3x2)
```

### Method 3

You can convert an array into a matrix with one column (a vector).

```
double[] v = [1.1, 2.2, 3.3];
auto m = DoubleMatrix(v); // m is (3x1)
```