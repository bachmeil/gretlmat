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

