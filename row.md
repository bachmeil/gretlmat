# Working at the level of one row

It's common to work with one or more rows rather than a full matrix. The Row struct is the foundation for working at this level.

# The Row struct

The Row struct allows you to work with one row of a matrix. It provides a convenient way to work with the underlying matrix, m, but it **DOES NOT** make a copy of m, so you're actually changing the elements of m when you assign to elements of a Row.

If this is not what you want, you should call one of these methods: `array`, `dup`, `rowmat`, and `colmat`. (`colmat` is not yet implemented.)

- `array`: Allocates a `double[]` and copies the elements into it.
- `dup`: Allocates a `DoubleMatrix` with one row and copies the elements into it.
- `rowmat`: Same as `dup`.
- `colmat`: (Not yet implemented) Allocates a `DoubleMatrix` with one column and copies the elements into it. This is the equivalent of calling `dup` and then transposing it, but more efficient because it skips the intermediate step of allocating and filling the matrix provided by `dup`.

Examples:

```
auto m = DoubleMatrix(10, 15); // Allocate a (10x15) matrix
// Fill the elements of m

auto r1 = Row(m, 1); // r1 references the second row of m
r1[3] = 4.2; //
writeln(r1[3]); // 4.2
writeln(m[1, 3]); // 4.2

double[] rr = r1.array;
rr[3] = 4.2; // Has no effect on m[1, 3] because rr is a copy of Row(m, 1)

DoubleMatrix rr = r1.dup;
rr[0, 3] = 4.2; // Has no effect on m[1, 3] because rr is a copy of Row(m, 1)

DoubleMatrix rr = r1.rowmat; // Same as r1.dup

DoubleMatrix rr = r1.colmat; // Not yet implemented
rr[3, 0] = 4.2; // Has no effect on m[1, 3] because rr is a copy of Row(m, 1)
```

## Indexing

You index a Row as you would a vector. `x[2]` is the third element of the Row. Note that `x[2]` doesn't necessarily correspond to any particular element of `m` due to slicing.

## Assigning elements

- Assignment of elements is done as for a vector: `x[2] = 1.3`.
- You can assign the same value to all elements of a Row using the syntax `x[] = 9.4`.

## Assigning with opAssign

You can assign anything that can be indexed with one index and has `length` defined. There is a check that the length matches the Row you're assigning to. In this example, we copy the elements of the second row of `x` into the first row:

```
Row(x, 0) = Row(x, 1)
```

## Slicing

You can slice a Row and assign to a slice of a Row:

```
auto r3 = Row(x, 3);
Row r31 = r3[1..$];
auto r4 = Row(x, 4);
Row r41 = r4[1..$];
r31[1..4] = r41[2..5];
r41 = 5.2;
```

A slice of a Row is itself a Row. One implication is that `r31[0..1]` is not the same as `r31[0]`. The latter is a double, while the former is a Row.

## A Row is a range

You can iterate over a Row the same as a `double[]`: `foreach(val; Row(x, 4))`.

## The dollar sign

You can use the dollar sign as you would for a `double[]`: `Row(x, 2)[4..$]`.

## elements

If you want to iterate over all the elements of a Row, you can call `elements`:

```
Elements es = Row(x, 3).elements();
```

## indexes

If you want to iterate over the indexes of all the elements of a Row, you can call `indexes`:

```
int[2][] inds = Row(x, 3).indexes();
```

# FillByRow

This is a utility function for constructing a matrix out of individual Row structs. You allocate a FillByRow struct as you would a DoubleMatrix:

```
auto x = FillByRow(10, 6);
```

`x` is a (10x6) DoubleMatrix that can filled row by row. If `v` is a Row, you add it to the next unfilled row by calling `put`:

```
x.put(v);
```

Two asserts are checked:

- That there is another empty row that you can fill.
- That the you're trying to add a Row with the right number of columns.

In the future, you will be able to call `put` with the following argument types:

- Rows
- Col
- Cols
- double
- double[]
- DoubleMatrix

FillByRow aliases to a DoubleMatrix, but if you want to explicitly return the underlying matrix, you can call .mat directly:

```
x.mat
```

.mat is a field, not a method, so don't use parenthesis.
