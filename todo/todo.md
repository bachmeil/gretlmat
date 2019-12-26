Things not yet finished. I'd like to incorporate all of this before
calling the project finished and doing a 1.0 release. Most of this
functionality already exists in my other projects, so it's just a matter
of pulling it in, testing, and making necessary adjustments.

- `Row` and `Col`. This would allow access to individual rows and columns
    without copying.
- `Rows` and `Columns`. This would allow access to multiple rows and
    columns without copying.
- `ByRow` and `ByColumn`. Iterate over a matrix by row or by column.
- `ByElement`. Iterate over a matrix without nested loops. This is one
    that I haven't actually done before, and I'm still working out the
    details. This will require another overload of the opIndex functions.
- `_all` as a way to index an entire row or column, like

    ```
    m[_all, 3] // All rows of the fourth column
    m[3, _all] // All columns of the fourth row
    ```
    
    This would differ from the `Row` and `Col` types by returning a `DoubleMatrix`.
- `Submatrix` type. It's important to be able to do things like
    
    ```
    m[0..3, 0..3] = m2[1..4, 1..4];
    ```
    
    A `Submatrix` holds a reference to the data.
- Generalized `Submatrix` types. We can take the `Submatrix` concept a
    step further. Suppose you want to set the diagonal of matrix `m1`
    equal to the diagonal of matrix `m2`. You could set up a `foreach`
    loop to do that. Or you could copy the elements of the diagonal into
    a new vector and then copy that vector into the diagonal. A better,
    and more efficient, approach is to do something like this:
    
    ```
    Diag(m1) = Diag(m2);
    ```
    
    By defining `opAssign` with `Diag` as an argument, we can implement
    the copying in any way desired, and the user does not have
    to know anything about what is going on. You can go further, allowing
    the diagonal to be set to a slice of an array, or even a function
    that generates random elements, like this
    
    ```
    Diag(m1) = RandomVector(4);
    ```
    
    If `RandomVector` holds a random number generator and its state,
    an appropriate `opAssign` can be defined to do the placement of those
    elements efficiently.
    
    Other examples where this might be useful are when you want to work
    with the portion of the matrix above or below the diagonal, a random
    subset of the elements, or the transpose of the matrix, such as
    
    ```
    m[3:6, 3:6] = Transpose(m2);
    ```
    
    It would possible to avoid explicitly allocating a new matrix and
    copying the elements in for this case. 
    
    A final example would be a `Submatrix` holding only some of the columns
    in the matrix.
    
    The number of generalized
    `Submatrix` types in gretlmat will be limited, but they would provide a
    foundation to build on.
    
    The transpose operation can be handled lazily, i.e., you don't need to
    actually deal with it until it's used in an operation.
    
- `NamedMatrix` and `NamedVector`. This would allow indexing by name rather
    than number, which is less error-prone.
- Ability to add and remove columns from a matrix. This is quite simple - the data is
    stored by column, so it's nothing more than adding elements to the end
    of the data array, or taking a slice if you want to drop the initial
    elements. You can even reserve additional elements upon allocation,
    so you can add later without concern that there will be copying.
- Row and Col for Submatrix
