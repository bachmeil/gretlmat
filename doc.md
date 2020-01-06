# Installation (Ubuntu)

The only dependency is libgretl. On Ubuntu, this is satisfied by installing the package `libgretl1-dev`.

# Usage (Ubuntu)

You need to do the following to use gretlmat in a D program on Ubuntu:

- Include src.d as a source file. The easiest way to do that is to copy src.d to the project directory and add src.d in the compilation step.
- Tell the linker about libgretl-1.0.so.

Assuming you're compiling a file named foo.d and you've copied src.d into the project directory, compilation with DMD on Ubuntu is done like this:

```
dmd foo.d src.d -L-lgretl-1.0
```

# Compiling in Release Mode

There are lots of assert statements scattered throughout the gretlmat library. If you compile in release mode, they're removed in the name of speed. Notably, there are bounds checks on any indexed accesses to the elements of a DoubleMatrix. Negative index values and index values that exceed the length of that dimension will throw an exception. Once your application is fully tested, there's no reason to include all those checks, and as such you should normally compile in release mode for long-running programs.

# DoubleMatrix

The DoubleMatrix struct is the primary data structure of gretlmat.

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

### Method 1

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
auto m = DoubleMatrix(rs, false); // m is (3x2)
```

### Method 3

You can convert an array into a matrix with one column (a vector).

```
double[] v = [1.1, 2.2, 3.3];
auto m = DoubleMatrix(v); // m is (3x1)
```

# Copying

You can copy the contents of one `DoubleMatrix` into another with simple assignment.

**Warning:** *This can be used to reshape a matrix. Elements are always filled by column, so assigning a (2x2) matrix to a (4x1) matrix is the same as stacking the first column on top of the second column. Use `dup` if you want to guarantee dimensions match.*

Example:

```
auto m = DoubleMatrix(2, 2);
auto m2 = DoubleMatrix(4, 1);
m2 = m; // Works, even though the dimensions are different
```

# Reshaping

You may want to change the dimensions of a matrix. One reason for doing so is to stack the columns of the matrix.

## Mutating functions

One way to change the dimensions would be to directly change the number of rows and columns. It would be pretty easy to mess that up, because there's no guarantee that the total number of elements won't change, and that could even lead to a hard to debug segmentation fault.

To avoid that disaster, you should use one of the mutating functions to change the dimensions. `unsafeReshape` allows you to set both dimensions. `unsafeSetColumns` lets you specify the number of columns, and it sets the number of rows accordingly. `unsafeSetRows` lets you specify that number of rows, and it sets the number of columns accordingly.

Each of these functions checks that the conversion can be done correctly. For `unsafeReshape`, the check is that the total number of elements does not change. For `unsafeSetColumns` and `unsafeSetRows`, the check is that the other dimension is an integer.

```
auto m = DoubleMatrix(10, 20);

// All of these achieve the same thing
m.unsafeReshape(20, 10);
m.unsafeSetColumns(10);
m.unsafeSetRows(20);
```

## Returning a new matrix

A safer, but slower, approach is to avoid mutation by creating a new matrix that holds the reshaped elements.

```
auto m = DoubleMatrix(10, 20);

// All of these achieve the same thing
DoubleMatrix m2 = m.reshape(20, 10);
DoubleMatrix m2 = m.setColumns(10);
DoubleMatrix m2 = m.setRows(20);
```

# Submatrix

In some cases, you want to work with only part of a matrix. Suppose you have a $left(6 \times 6\right)$ matrix $M$. You can take advantage of D's *multidimensional slicing* in this case. To take the sum of the upper left $\left(3 \times 3\right)$ block and the lower right $\left(3 \times 3\right)$ block, you can do

```
Submatrix ul = M[0..3, 0..3];
Submatrix lr = M[3..6, 3..6];
DoubleMatrix sm = ul + lr;
```

There are two advantages of the Submatrix struct.

- It provides convenient notation to refer to part of a matrix.
- It requires less copying. `ul` and `lr` do not create new $\left(3 \times 3\right)$ matrices and copy the elements into them. A Submatrix holds information about the elements of the original matrix and the location of the matrix in memory. It doesn't know or care about the values of the underlying matrix elements. There's no need to know the elements of `ul` or `lr` in order to do the addition that determines `sm`. This might be more efficient for a large matrix. If `M` had a dimension of $\left(1000 \times 1000\right)$, and you were adding $\left(999 \times 999\right)$ submatrices a million times, the cost of copying would add up.

**Warning:** The Submatrix struct holds only a reference to the underlying DoubleMatrix. If the underlying DoubleMatrix is deleted or changed, you might not get the expected result from the Submatrix. If you want to keep a Submatrix around for a long time, it's best to use the `.dup` method to create a new DoubleMatrix and copy in the corresponding elements of the underlying matrix.

## .dup

You can convert a Submatrix into a new DoubleMatrix, copying in the elements, using the `.dup` method. For the above example:

```
Submatrix ul = M[0..3, 0..3];
DoubleMatrix ul2 = ul.dup;
Submatrix lr = M[3..6, 3..6];
DoubleMatrix lr2 = lr.dup;
DoubleMatrix sm = ul2 + lr2;
```

## alias this

The Submatrix struct aliases to a DoubleMatrix. That means that if you call a function taking a DoubleMatrix argument (and there's no overload taking a Submatrix), the Submatrix will be convert automatically to a DoubleMatrix. For the above example:

```
Submatrix ul = M[0..3, 0..3];
DoubleMatrix ch = chol(ul);
```

Since the `chol` function is defined for a DoubleMatrix but not a Submatrix, `ul` is converted to a DoubleMatrix and a Choleski decomposition is taken of the DoubleMatrix.

## What you need to know about the Submatrix struct

The user of the gretlmat library will generally not need to know anything about how a Submatrix works, or even that it exists at all. It may be necessary to understand the Submatrix struct if you want to extend the library.

## opAssign

The Submatrix struct allows you to copy various things into part of a matrix. Continuing on with the example above:

```
// M2 is a 3x3 DoubleMatrix
M[3..6, 3..6] = M2; // Assign a DoubleMatrix
M[3..6, 0..3] = M[0..3, 3..6]; // Assign a Submatrix
M[0..3, 3..6] = 4.5; // Assign a scalar
```

# Working with the diagonal

gretlmat includes structs that make it easy to work with the diagonal, elements below the diagonal, and elements above the diagonal. Everything discussed in this section is intended to be used with square matrices. Everything would generalize easily to non-square matrices and the main diagonal, but that's rarely of interest, so you should pull out an appropriate Submatrix of the data that gives you the main diagonal you want to work with.

## BelowDiagonal

The BelowDiagonal struct allows you to perform operations on the part of a square matrix below the diagonal.

### .mat

This method returns a DoubleMatrix with the same dimensions as the original matrix, but with all elements other than those below the diagonal set equal to zero.

### .fill

Given a double[] with the an appropriate number of elements, fill in the elements below the diagonal by column. This is primarily of interest if you want to fill those elements with random values.

### .array

Return a double[] holding the elements as if you stacked the part of the matrix below the diagonal by column.

### opAssign

You can assign the part of a matrix below the diagonal to the same elements in another matrix. Alternatively, you can assign the part of matrix above the diagonal to the part below the diagonal in another matrix. In that case, the row and column indexes are reversed, so that you get a symmetric matrix if you apply that operation to itself.

### .elements

Return an array of Element structs holding the values and indexes of each element below the diagonal.