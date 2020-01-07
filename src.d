module gretlmat.base;
import std.conv, std.exception, std.range, std.stdio;

extern(C) {
  int gretl_matrix_multiply(const GretlMatrix * a, const GretlMatrix * b, GretlMatrix * c);
  void gretl_matrix_multiply_by_scalar(GretlMatrix * m, double x);
  //~ int gretl_matrix_multiply_mod(const GretlMatrix * a, matmod amod, const GretlMatrix * b, matmod bmod, GretlMatrix * c, matmod cmod);
  int gretl_matrix_cholesky_decomp(GretlMatrix * a);
  int gretl_matrix_kronecker_product(const GretlMatrix * A, const GretlMatrix * B, GretlMatrix * K);
  int gretl_LU_solve(GretlMatrix * a, GretlMatrix * b);
  int gretl_invert_matrix(GretlMatrix * a);
  double gretl_matrix_determinant(GretlMatrix * a, int * err);
  double gretl_matrix_log_determinant(GretlMatrix * a, int * err);
  double gretl_matrix_trace(const GretlMatrix * m);
  void gretl_matrix_raise(GretlMatrix * m, double x);
  void gretl_matrix_free(GretlMatrix * m);
  int gretl_matrix_ols (const GretlMatrix * y, const GretlMatrix * X, GretlMatrix * b, GretlMatrix * vcv, GretlMatrix * uhat, double * s2);
  void gretl_matrix_print(const GretlMatrix * m, const char * msg);
  int gretl_matrix_transpose(GretlMatrix * targ, const GretlMatrix * src);
  GretlMatrix * gretl_matrix_alloc(int rows, int cols);
  double gretl_vector_mean (const GretlMatrix * v);
  double gretl_vector_variance (const GretlMatrix * v);
}

private struct matrix_info {
  int t1;
  int t2;
  char **colnames;
  char **rownames;
}

/* This is used internally
 * The end user should never have a reason to know anything about GretlMatrix.
 */
struct GretlMatrix {
  int rows;
  int cols;
  double * ptr;
  matrix_info * info;

  GretlMatrix * matptr() {
    return &this;
  }
}

struct DoubleMatrix {
  double[] data;
  int rows;
  int cols;
  private GretlMatrix temp;
  alias mat this;

	invariant {
		assert(rows > 0, "Number of rows has to be positive");
		assert(cols > 0, "Number of columns has to be positive");
		assert(rows*cols == data.length, "Dimensions do not match the underlying data array");
	}

  GretlMatrix mat() {
		temp.rows = rows;
		temp.cols = cols;
  	temp.ptr = data.ptr;
  	return temp;
  }
  
  GretlMatrix * matptr() {
		temp.rows = rows;
		temp.cols = cols;
    temp.ptr = data.ptr;
    return &temp;
  }

  double * ptr() {
    return data.ptr;
  }

  this(int r, int c=1) {
		assert(r*c > 0, "Need to allocate a positive number of elements in a DoubleMatrix");
    data = new double[r*c];
    rows = r;
    cols = c;
  }
  
  // Use a template to allow conversion of arguments to int
  this(T1, T2)(T1 r, T2 c=1) {
		assert(r*c > 0, "Need to allocate a positive number of elements in a DoubleMatrix");
		data = new double[r*c];
		rows = r.to!int;
		cols = c.to!int;
	}

  this(double[][] m, bool rowElements=true) {
		data = new double[m.length*m[0].length];
    
    // Treat each element as a row
    if (rowElements) {
      rows = to!int(m.length);
      cols = to!int(m[0].length);
      foreach(row, vals; m) {
        foreach(col; 0..cols) {
          data[elt(row, col)] = vals[col];
        }
      }
    // Treat each element as a column
    } else {
      rows= to!int(m[0].length);
      cols = to!int(m.length);
      foreach(col, vals; m) {
        foreach(row; 0..rows) {
          data[elt(row, col)] = vals[row];
        }
      }
    }
	}
  
	this(GretlMatrix * m) {
		data = new double[m.cols*m.rows];
		rows = m.rows;
		cols = m.cols;
		foreach(row; 0..rows) {
			foreach(col; 0..cols) {
				data[elt(row, col)] = m.ptr[elt(row, col)];
			}
		}
	}
  
  this(double[] v) {
    data = v;
    rows = to!int(v.length);
    cols = 1;
  }
 
  int[2] dim() {
		return [this.rows, this.cols];
	}
	
	int length() {
		return data.length.to!int;
	}
	
	int index(int r, int c) {
		return c*this.rows + r;
	}
	
	// Find element number associated with index
	// Include all asserts in here
  // These are stripped out in release mode
	int elt(int r, int c) {
		assert(r >= 0, "Cannot have a negative row index");
		assert(c >= 0, "Cannot have a positive row index");
		assert(r < this.rows, "First index (" ~ r.to!string ~ ") exceeds the number of rows");
		assert(c < this.cols, "Second index (" ~ c.to!string ~ ") exceeds the number of columns");
		return c*this.rows + r;
	}

	int elt(T1, T2)(T1 r, T2 c) {
		return elt(r.to!int, c.to!int);
	}
	
  double opIndex(int r, int c) {
    return data[elt(r, c)];
  }

  double opIndex(T1, T2)(T1 r, T2 c) {
    return data[elt(r.to!int, c.to!int)];
  }
  
  double opIndex(int[2] ind) {
		return data[elt(ind[0], ind[1])];
	}
  
  // Support for multidimensional indexing
  int[2] opSlice(int dim)(int begin, int end) {
    return [begin, end];
  }
  
  Submatrix opIndex(int[2] rr, int[2] cc) {
    return Submatrix(this, rr[0], cc[0], rr[1], cc[1]);
  }

  void opIndexAssign(double v, int r, int c) {
    ptr[elt(r, c)] = v;
  }
  
  void opIndexAssign(double v, int[2] ind) {
		opIndexAssign(v, ind[0], ind[1]);
	}
  
  void opIndexAssign(T1, T2)(double v, T1 r, T2 c) {
		ptr[elt(r.to!int, c.to!int)] = v;
	}

  void opAssign(DoubleMatrix m) {
    assert(this.data.length == m.data.length, "Dimensions do not match for matrix assignment");
		this.data[] = m.data[];
  }
  
  void fill(double[] v) {
		assert(this.data.length == v.length, "Argument to fill has length different from the number of elements in the matrix");
		this.data[] = v[];
	}
	
	void fillByColumn(double[] v) {
		fill(v);
	}
  
	void fillByRow(double[] v) {
		assert(this.data.length == v.length, "Argument to fill has length different from the number of elements in the matrix");
		foreach(row; 0..rows) {
			foreach(col; 0..cols) {
				this[row, col] = v[index(col, row)];
			}
		}				
	}
	
  // Safe (non-mutating) approaches to changing dimensions
  DoubleMatrix reshape(int newrows, int newcols=1) {
    auto result = DoubleMatrix(newrows, newcols);
    assert(result.length == this.length, "Wrong number of elements in call to reshape");
    result.data[] = this.data[];
    return result;
  }
  
  DoubleMatrix setColumns(int newcols) {
		assert(newcols > 0, "Number of columns has to be greater than zero");
		auto result = DoubleMatrix(this.length / newcols, newcols);
    assert(result.length == this.length, "Wrong number of elements in call to setColumns");
		result.data[] = this.data[];
		return result;
	}

  DoubleMatrix setRows(int newrows) {
		assert(newrows > 0, "Number of rows has to be greater than zero");
		auto result = DoubleMatrix(newrows, this.rows*this.cols / newrows);
    assert(result.length == this.length, "Wrong number of elements in call to setRows");
		result.data[] = this.data[];
		return result;
	}

	// Templated versions of the above functions to handle non-int input
  DoubleMatrix reshape(T1, T2)(T1 nr, T2 nc=1) {
    return reshape(nr.to!int, nc.to!int);
  }
  
  DoubleMatrix setColumns(T)(T nc) {
		return setColumns(nc.to!int);
	}

  DoubleMatrix setRows(T)(T nr) {
		return setRows(nr.to!int);
	}

  // No need for assert/enforce statements inside this method
  // Invariant conditions and existing asserts for DoubleMatrix should 
  // catch all possible invalid data
  void unsafeReshape(int newrows, int newcols=1) {
    rows = newrows;
    cols = newcols;
  }
  
  void unsafeSetColumns(int newcols) {
		rows = this.length / newcols;
		cols = newcols;
	}
	
  void unsafeSetRows(int newrows) {
		cols = this.length / newrows;
		rows = newrows;
	}

	// Use templates for non-int arguments
  void unsafeReshape(T1, T2)(T1 nr, T2 nc=1) {
    rows = nr.to!int;
    cols = nc.to!int;
  }
  
  void unsafeSetColumns(T)(T nc) {
		int newcols = nc.to!int;
		// Do this calculation first!
		rows = this.length / newcols;
		cols = newcols;
	}
	
  void unsafeSetRows(T)(T nr) {
		int newrows = nr.to!int;
		cols = this.rows*this.cols / newrows;
		rows = newrows;
	}

	DoubleMatrix unsafeClone() {
		DoubleMatrix result;
		result.rows = this.rows;
		result.cols = this.cols;
		result.data = this.data;
		return result;
	}
}

DoubleMatrix dup(DoubleMatrix m) {
  auto result = DoubleMatrix(m.rows, m.cols);
  result.data[] = m.data[];
  return result;
}
	
DoubleMatrix stack(DoubleMatrix m) {
	auto result = DoubleMatrix(m.length);
	result.data[] = m.data[];
	return result;
}

DoubleMatrix t(DoubleMatrix m) {
  auto result = DoubleMatrix(m.cols, m.rows);
  int err = gretl_matrix_transpose(result.matptr, m.matptr);
  enforce(err == 0, "Taking the transpose of a matrix failed with error code " ~ err.to!string);
  return result;
}

DoubleMatrix chol(DoubleMatrix m) {
  assert(m.rows == m.cols, "You are trying to compute a Cholesky decomposition of a non-square matrix");
  auto result = dup(m);
  int err = gretl_matrix_cholesky_decomp(result.matptr);
  enforce(err == 0, "Cholesky decomposition failed");
  return result;
}

void print(DoubleMatrix m, string msg="") {
	writeln(msg);
  foreach(row; 0..m.rows) {
    foreach(col; 0..m.cols) {
      write(m[row, col], " ");
    }
    writeln("");
  }
}


// This struct holds a reference to the data in a matrix.
// It's up to the user to make sure the reference doesn't outlive the underlying matrix.
// They are designed to be short-lived, for convenience, not for actual data storage.
// The user should normally not be using Submatrix types directly
struct Submatrix {
  // Original matrix
  double * ptr;
  int rows;

  // The submatrix
  int rowOffset;
  int colOffset;
  int subRows;
  int subCols;
  alias dup this;

  DoubleMatrix dup() {
    auto result = DoubleMatrix(subRows, subCols);
    foreach(col; 0..subCols) {
      foreach(row; 0..subRows) {
        result[row, col] = this[row, col];
      }
    }
    return result;
  }

  this(DoubleMatrix m, int r0, int c0, int r1, int c1) {
    ptr = m.ptr;
    rows = m.rows;
    subRows = r1-r0;
    subCols = c1-c0;
    rowOffset = r0;
    colOffset = c0;
  }

  this(T1, T2, T3, T4)(DoubleMatrix m, T1 r0, T2 c0, T3 r1, T4 c1) {
    this(m, r0.to!int, c0.to!int, r1.to!int, c1.to!int);
  }

  this(DoubleMatrix m) {
    ptr = m.ptr;
    rows = m.rows;
    subRows = m.rows;
    subCols = m.cols;
    rowOffset = 0;
    colOffset = 0;
  }

  this(GretlMatrix m, int r0, int c0, int r1, int c1) {
    ptr = m.ptr;
    rows = m.rows;
    subRows = r1-r0;
    subCols = c1-c0;
    rowOffset = r0;
    colOffset = c0;
  }

  this(T1, T2, T3, T4)(GretlMatrix m, T1 r0, T2 c0, T3 r1, T4 c1) {
    this(m, r0.to!int, c0.to!int, r1.to!int, c1.to!int);
  }

  this(GretlMatrix m) {
    ptr = m.ptr;
    rows = m.rows;
    subRows = m.rows;
    subCols = m.cols;
    rowOffset = 0;
    colOffset = 0;
  }

  double opIndex(int r, int c) {
    assert(r >= 0, "Row index cannot be negative");
    assert(c >= 0, "Column index cannot be negative");
    assert(r < subRows, "First index on Submatrix has to be less than the number of rows");
    assert(c < subCols, "Second index on Submatrix has to be less than the number of columns");
    int newr = r+rowOffset;
    int newc = c+colOffset;
    return ptr[newc*rows + newr];
  }
  
  double opIndex(T1, T2)(T1 r, T2 c) {
    opIndex(r.to!int, c.to!int);
  }

  void opIndexAssign(double v, int r, int c) {
    assert(r >= 0, "Row index cannot be negative");
    assert(c >= 0, "Column index cannot be negative");
    assert(r < subRows, "First index on Submatrix has to be less than the number of rows");
    assert(c < subCols, "Second index on Submatrix has to be less than the number of columns");
    int newr = r+rowOffset;
    int newc = c+colOffset;
    ptr[newc*rows + newr] = v;
  }

  void opIndexAssign(T1, T2)(double v, T1 r, T2 c) {
    opIndexAssign(v, r.to!int, c.to!int);
  }
  
  DoubleMatrix opBinary(string op)(Submatrix sm) {
    static if(op == "+") {
      return SubmatrixAddition(this, sm);
    }
    static if(op == "-") {
      return SubmatrixSubtraction(this, sm);
    }
    static if(op == "*") {
      return SubmatrixMultiplication(this, sm);
    }
    static if(op == "/") {
      return SubmatrixDivision(this, sm);
    }
  }
  

  /* It's handy to be able to convert a submatrix that has only one row
   * or one column into an array.
   */
  double[] array() {
		enforce( (subCols == 1) | (subRows == 1), "Cannot convert a submatrix with multiple rows and columns into an array");
		double[] result;
		if (subCols == 1) {
			foreach(row; 0..subRows) {
				result ~= this[row,0];
			}
		} else {
			foreach(col; 0..subCols) {
				result ~= this[0,col];
			}
		}
		return result;
	}

  void opAssign(double v) {
    foreach(col; 0..subCols) {
      foreach(row; 0..subRows) {
        this[row, col] = v;
      }
    }
  }

  void opAssign(Submatrix m) {
    enforce(m.subRows == this.subRows, "Number of rows does not match");
    enforce(m.subCols == this.subCols, "Number of columns does not match");
    foreach(col; 0..subCols) {
      foreach(row; 0..subRows) {
        this[row, col] = m[row, col];
      }
    }
  }

  //~ void opAssign(GretlMatrix m) {
    //~ enforce(m.rows == this.subRows, "Number of rows does not match");
    //~ enforce(m.cols == this.subCols, "Number of columns does not match");
    //~ foreach(col; 0..m.cols) {
      //~ foreach(row; 0..m.rows) {
        //~ this[row, col] = m[row, col];
      //~ }
    //~ }
  //~ }

  // We have this function defined because there is some overhead to using alias this with a DoubleMatrix.
  // No such overhead with an RMatrix.
  void opAssign(DoubleMatrix m) {
    enforce(m.rows == this.subRows, "Number of rows does not match");
    enforce(m.cols == this.subCols, "Number of columns does not match");
    foreach(col; 0..m.cols) {
      foreach(row; 0..m.rows) {
        this[row, col] = m[row, col];
      }
    }
  }
  
  double[] opSlice(int i0, int i1) {
		enforce( (subCols == 1) | (subRows == 1), "Can only slice a submatrix with one row or one column. Other slicing of a Submatrix is not supported at this time.");
		double[] result;
		if (subCols == 1) {
			foreach(row; i0..i1) {
				result ~= this[row,0];
			}
		} else {
			foreach(col; i0..i1) {
				result ~= this[0,col];
			}
		}
		return result;
	}
}

DoubleMatrix SubmatrixAddition(Submatrix x, Submatrix y) {
  assert(x.subRows == y.subRows, "Rows for Submatrix addition do not match");
  assert(x.subCols == y.subCols, "Rows for Submatrix addition do not match");
  auto result = DoubleMatrix(x.subRows, x.subCols);
  foreach(c; 0..result.cols) {
    foreach(r; 0..result.rows) {
      result[r, c] = x[r, c]+y[r, c];
    }
  }
  return result;
}

struct All {};
All _;

struct Element {
	double val;
	int row;
	int col;
	
	this(double _val, int _row, int _col) {
		val = _val;
		row = _row;
		col = _col;
	}
	
	this(double _val, int[2] ind) {
		val = _val;
		row = ind[0];
		col = ind[1];
	}
}

alias Elements = Element[];

struct BelowDiagonal {
	DoubleMatrix m;
	alias elements this;
	
	invariant {
		assert(m.rows == m.cols, "BelowDiagonal is only defined for square matrices. "
			~ "If you want the main diagonal, use a Submatrix.");
	}
	
	Elements elements() {
		Elements result;
		foreach(cc; 0..m.cols) {
			foreach(rr; cc+1..m.rows) {
				result ~= Element(m[rr, cc], rr, cc);
			}
		}
		return result;
	}
	
	DoubleMatrix mat() {
		auto result = DoubleMatrix(m.rows, m.cols);
		foreach(col; 0..m.cols) {
			foreach(row; 0..m.rows) {
				if (row <= col) {
					result[row, col] = 0.0;
				} else {
					result[row, col] = m[row, col];
				}
			}
		}
		return result;
	}
	
	double[] array() {
		double[] result;
		int[2] ind = [1, 0];
		foreach(ii; 0..this.length) {
			result ~= this[ind];
			ind = nextIndex(ind);
		}
		return result;
	}
	
	// Don't try to call this. It's confusing to index this struct!
	private double opIndex(int[2] ind) {
		return m[ind];
	}
	
	private double opIndex(int row, int col) {
		return m[row, col];
	}
	
	// Don't try to call this either.
	private void opIndexAssign(double val, int[2] ind) {
		m[ind] = val;
	}
	
	private void opIndexAssign(double val, int row, int col) {
		m[row, col] = val;
	}

	void opAssign(Elements es) {
		assert(this.length == es.length, "Number of elements doesn't match in assignment involving BelowDiagonal");
		foreach(e; es) {
			m[e.row, e.col] = e.val;
		}
	}
	
	void opAssign(BelowDiagonal bd) {
		assert(this.length == bd.length, "Cannot do BelowDiagonal assignment unless dimensions match");
		int[2] ind = [1,0];
		foreach(ii; 0..bd.length) {
			m[ind] = bd[ind];
			ind = nextIndex(ind);
		}
	}
	
	void opAssign(AboveDiagonal ad) {
		Elements es = ad.elements;
		writeln(es);
		foreach(e; es) {
			m[e.col, e.row] = ad[e.row, e.col];
		}
	}
	
	void opAssign(double a) {}
	
	// Since we know the previous element's index, use that information
	// to calculate the next index
	int[2] nextIndex(int[2] ind) {
		int rowNumber = ind[0];
		int colNumber = ind[1];
		if (rowNumber > m.rows-2) {
			return [colNumber+2, colNumber+1];
		} else {
			return [rowNumber+1, colNumber];
		}
	}

	// For filling with random elements
	void fill(double[] v) {
		assert(this.length == v.length, "Number of elements doesn't match in assignment involving BelowDiagonal");
		int[2] ind = [1,0];
		foreach(ii; 0..v.length) {
			m[ind] = v[ii];
			ind = nextIndex(ind);
		}
	}
	
	int length() {
		return (m.rows^^2 - m.rows)/2;
	}
}

// Should probably do something about the code duplication with BelowDiagonal
// Not going to worry about it right now
struct AboveDiagonal {
	DoubleMatrix m;
	alias elements this;
	
	invariant {
		assert(m.rows == m.cols, "AboveDiagonal is only defined for square matrices. "
			~ "If you want the main diagonal, use a Submatrix.");
	}
	
	Elements elements() {
		Elements result;
		int[2] ind = [0, 1];
		foreach(ii; 0..this.length) {
			writeln(ind);
			result ~= Element(m[ind], ind);
			ind = nextIndex(ind);
		}
		return result;
	}
	
	// Since we know the previous element's index, use that information
	// to calculate the next index
	int[2] nextIndex(int[2] ind) {
		int rowNumber = ind[0];
		int colNumber = ind[1];
		if (rowNumber < colNumber-1) {
			return [rowNumber+1, colNumber];
		} else {
			return [0, colNumber+1];
		}
	}

	DoubleMatrix mat() {
		auto result = DoubleMatrix(m.rows, m.cols);
		foreach(col; 0..m.cols) {
			foreach(row; 0..m.rows) {
				if (row < col) {
					result[row, col] = m[row, col];
				} else {
					result[row, col] = 0.0;
				}
			}
		}
		return result;
	}
	
	double[] array() {
		double[] result;
		int[2] ind = [0, 1];
		foreach(ii; 0..this.length) {
			result ~= this[ind];
			ind = nextIndex(ind);
		}
		return result;
	}
	
	
	// Don't try to call this. It's confusing to index this struct!
	private double opIndex(int[2] ind) {
		return m[ind];
	}
	
	private double opIndex(int row, int col) {
		return m[row, col];
	}
	
	// Don't try to call this either.
	private void opIndexAssign(double val, int[2] ind) {
		m[ind] = val;
	}
	
	private void opIndexAssign(double val, int row, int col) {
		m[row, col] = val;
	}

	void opAssign(Elements es) {
		assert(this.length == es.length, "Number of elements doesn't match in assignment involving AboveDiagonal");
		foreach(e; es) {
			m[e.row, e.col] = e.val;
		}
	}
	
	void opAssign(AboveDiagonal ad) {
		assert(this.length == ad.length, "Cannot do AboveDiagonal assignment unless dimensions match");
		int[2] ind = [0,1];
		foreach(ii; 0..ad.length) {
			m[ind] = ad[ind];
			ind = nextIndex(ind);
		}
	}
	
	void opAssign(BelowDiagonal bd) {
		Elements es = bd.elements;
		foreach(e; es) {
			m[e.col, e.row] = bd[e.row, e.col];
		}
	}
	
	void opAssign(double a) {}
	
	// For filling with random elements
	void fill(double[] v) {
		assert(this.length == v.length, "Number of elements doesn't match in assignment involving AboveDiagonal");
		int[2] ind = [0,1];
		foreach(ii; 0..v.length) {
			m[ind] = v[ii];
			ind = nextIndex(ind);
		}
	}
	
	int length() {
		return (m.rows^^2 - m.rows)/2;
	}
}

struct Diagonal {
	DoubleMatrix m;
	alias array this;
	
	invariant {
		assert(m.rows == m.cols, "Diagonal is only defined for square matrices. "
			~ "If you want the main diagonal, use a Submatrix.");
	}
	
	double[] array() {
		double[] result;
		foreach(ii; 0..m.rows) {
			result ~= this[ii];
		}
		return result;
	}
	
	DoubleMatrix mat() {
		auto result = DoubleMatrix(m.rows, m.cols);
		foreach(ind; ByIndex(m)) {
			if (ind[0] == ind[1]) {
				result[ind] = m[ind];
			} else {
				result[ind] = 0.0;
			}
		}
		return result;
	}
	
	double opIndex(int ii) {
		assert(ii >= 0, "Index on Diagonal cannot be negative");
		assert(ii < m.cols, "Index on Diagonal exceeds dimension");
		return m[ii, ii];
	}
	
	double opIndex(int[2] ind) {
		assert(ind[0] == ind[1], "Index values not the same for an element on the diagonal");
		return opIndex(ind[0]);
	}
	
	void opIndexAssign(double val, int ii) {
		assert(ii >= 0, "Index on Diagonal cannot be negative");
		assert(ii < m.cols, "Index on Diagonal exceeds dimension");
		m[ii, ii] = val;
	}
	
	void opIndexAssign(double val, int[2] ind) {
		assert(ind[0] == ind[1], "Index values not the same for an element on the diagonal");
		return opIndexAssign(val, ind[0]);
	}
	
	void opAssign(Diagonal d) {
		assert(this.length == d.length, "Dimensions for Diagonal assignment don't match");
		foreach(ii; 0..d.length) {
			this[ii] = d[ii];
		}
	}
	
	void opAssign(double[] v) {
		assert(this.length == v.length, "Dimensions for Diagonal assignment don't match");
		foreach(ii; 0..this.length) {
			this[ii] = v[ii];
		}
	}
	
	void opAssign(double a) {
		foreach(ii; 0..this.length) {
			this[ii] = a;
		}
	}
	
	int length() {
		return m.cols;
	}
}

struct ByIndex {
	DoubleMatrix m;
	int rr = 0;
	int cc = 0;
	
  bool empty() {
    return cc >= m.cols; 
  }
  
  int[2] front() {
    return [rr, cc]; 
  }

  void popFront() {
		if (rr == m.rows-1) {
			rr = 0;
			cc += 1;
		} else {
			rr += 1;
		}
  }
}

struct ByElement {
	DoubleMatrix m;
	int rr = 0;
	int cc = 0;
	
  bool empty() {
    return cc >= m.cols; 
  }
  
  Element front() {
    return Element(m[rr, cc], rr, cc); 
  }

  void popFront() {
		if (rr == m.rows-1) {
			rr = 0;
			cc += 1;
		} else {
			rr += 1;
		}
  }
}

struct Row {
  /* lastCol is the last column of m included in this row.
   * It can be less that m.cols.
   * colOffset is what you use to index the first element of the row. */
  DoubleMatrix m;
  int row;
  private int colOffset = 0;
  private int lastColumn;
  
  /* Use a length function because it's too easy to forget to update
   * length if it's treated as data. This always gets it right. */
  int length() {
		return lastColumn - colOffset;
	}
	
	// DoubleMatrix mat() {}
	// alias mat this

	double[] array() {
		double[] result;
		foreach(val; this) {
			result ~= val;
		}
		return result;
	}

	/* Only one way to directly create a Row, using Row(m, 4). Can also
	 * indirectly create a Row using multidimensional slicing of a matrix. */
  this(DoubleMatrix _m, int _row) {
		assert(_row >= 0, "Cannot have a negative row index in Row struct");
		assert(_row < _m.rows, "Attempting to create a Row with row number that exceeds matrix dimensions");
    m = _m;
    row = _row;
    lastColumn = _m.cols;
  }
  
  this(DoubleMatrix _m, int _row, int _colOffset, int _lastColumn) {
		assert(_row >= 0, "Cannot have a negative row index in Row struct");
		assert(_row < _m.rows, "Attempting to create a Row with row number that exceeds matrix dimensions");
    m = _m;
    row = _row;
    colOffset = _colOffset;
    lastColumn = _lastColumn;
  }

  /* Define the index operators here and then use them everywhere else
   * in order to avoid bugs. Avoid directly indexing mat as much as possible. */
  double opIndex(int ii) {
    assert(ii >= 0, "Index on Row struct can't be negative");
    assert(ii <= this.length, "Index on Row struct out of bounds");
    return m[row, ii+colOffset];
  }
  
  void opIndexAssign(double val, int ii) {
    assert(ii >= 0, "Index on Row struct can't be negative");
    assert(ii <= this.length, "Index on Row struct out of bounds");
    m[row, ii+colOffset] = val;
  }
  
  void opIndexAssign(double val) {
		foreach(ii; 0..this.length) {
			this[ii] = val;
		}
	}
  
  /* This uses a template. Can copy into a Row anything that is a range,
   * including a double[], another Row, a Col, and a DoubleVector. */
  void opAssign(T)(T v) {
    assert(this.length == v.length, "Attempting to copy an object with the wrong number of elements into a Row struct");
    foreach(ii; 0..this.length) {
      this[ii] = v[ii];
    }
  }

  void opAssign(double a) {
    this[] = a;
  }
  
  // i1 is *not* included, following the D convention
  Row opSlice(int i0, int i1) {
		assert(i0 >= 0, "Index on Row struct can't be negative");
    assert(i1 <= this.length, "Index on Row struct out of bounds");
    return Row(this.m, this.row, this.colOffset+i0, this.colOffset+i1);
	}
	
	int opDollar() {
		return length();
	}
	
	// Returns the elements of m associated with this Row
	Elements elements() {
		Elements result;
		foreach(ii; colOffset..lastColumn) {
			result ~= Element(m[row, ii], row, ii);
		}
		return result;
	}
	
	// Returns the indexes of m associated with this Row
	int[2][] indexes() {
		int[2][] result;
		foreach(ii; colOffset..lastColumn) {
			result ~= [row, ii];
		}
		return result;
	}
	
	void print(string msg="") {
		writeln(msg);
		writeln(this.array);
	}

  bool empty() { return colOffset >= lastColumn; }
  double front() { return this[0]; }
  void popFront() {
    colOffset += 1;
  }
}

struct MatrixElements {
	DoubleMatrix m;
	int[2][] indexes;
	
	// nextIndex calculates the next index value, and may not be valid
	// done returns true if the next index value is out of range
	this(DoubleMatrix _m, int[2] ind,
		int[2] function(DoubleMatrix dm, int[2] currentIndex) nextIndex,
		bool function(DoubleMatrix dm, int[2] currentIndex) done) {
			m = _m;
			bool d = false;
			while (!d) {
				indexes ~= ind;
				ind = nextIndex(m, ind);
				d = done(m, ind);
			}
	}
	
	this(DoubleMatrix _m, int[2] ind,
		int[2] delegate(DoubleMatrix dm, int[2] currentIndex) nextIndex,
		bool delegate(DoubleMatrix dm, int[2] currentIndex) done) {
			m = _m;
			bool d = false;
			while (!d) {
				indexes ~= ind;
				ind = nextIndex(m, ind);
				d = done(m, ind);
			}
	}

	this(DoubleMatrix _m, int[2][] _indexes) {
		m = _m;
		indexes = _indexes;
	}
	
	double opIndex(int ii) {
		assert(ii >= 0, "Index on MatrixElements cannot be negative");
		assert(ii < indexes.length, "Index on MatrixElements exceeds the dimension");
		return m[indexes[ii]];
	}
	
	void opIndexAssign(double val, int ii) {
		assert(ii >= 0, "Index on MatrixElements cannot be negative");
		assert(ii < indexes.length, "Index on MatrixElements exceeds the dimension");
		m[indexes[ii]] = val;
	}
	
	void opAssign(double a) {
		foreach(ind; indexes) {
			m[ind] = a;
		}
	}
	
	void opAssign(T)(T v) {
		assert(indexes.length == v.length, "Assigning to a MatrixElements struct with wrong number of elements");
		foreach(ii; 0..indexes.length.to!int) {
			this[ii] = v[ii];
		}
	}
	
	Elements elements() {
		Elements result;
		foreach(ind; indexes) {
			result ~= Element(m[ind], ind);
		}
		return result;
	}
	
	void print(string msg="") {
		if (msg != "") {
			writeln(msg);
		}
		foreach(ind; indexes) {
			writeln(ind, ": ", m[ind]);
		}
	}
	
	int opDollar() {
		return indexes.length.to!int;
	}
	
	bool empty() { return indexes.length <= 0; }
  Element front() { return Element(m[indexes[0]], indexes[0]); }
  void popFront() {
    indexes = dropOne(indexes);
  }
}
				

//~ struct Rows {
	//~ DoubleMatrix m;
	//~ int[] rowNumbers;
	
	//~ this(DoubleMatrix m, int r) {}
	//~ this(DoubleMatrix m, int[] rs) {}
	//~ this(DoubleMatrix m, int start, int end) {}
	
	//~ array
	//~ alias array this;
	//~ void opAppend(Row)
	//~ void opAppend(Rows)
	//~ void opAppend(int)
	//~ void opAppend(int[])
	//~ void opAssign(double a)
	//~ void opAssign(T)(anything with the right length) { all rows set to that value }
	//~ void opAssign(double[][]) { if right length (both ways), copy in order into these rows }
	//~ DoubleMatrix mat() { Copy into a DoubleMatrix in order }
//~ }

//~ struct Col {
  //~ GretlMatrix mat;
  //~ int col;
  //~ double * data;
  //~ int length;

  //~ this(GretlMatrix m, int c) {
    //~ mat = m;
    //~ col = c;
    //~ data = &m.ptr[m.rows*c];
    //~ length = m.rows;
  //~ }

  //~ double opIndex(int r) {
    //~ enforce(r < length, "Column index out of bounds");
    //~ return data[r];
  //~ }

  //~ void opIndexAssign(double val, int ii) {
    //~ mat[ii, col] = val;
  //~ }

  //~ void opAssign(T)(T v) {
    //~ enforce(this.length == v.length, "Attempting to copy into Column an object with the wrong number of elements");
    //~ foreach(ii; 0..to!int(this.length)) {
      //~ mat[ii, col] = v[ii];
    //~ }
  //~ }
 
  //~ void opAssign(double x) {
    //~ foreach(ii; 0..this.length) { 
      //~ mat[ii, col] = x;
    //~ }
  //~ }

  //~ void opAssign(GretlMatrix m) {
    //~ enforce(length == m.rows, "Wrong number of elements to copy into Column");
    //~ enforce(m.cols == 1, "Cannot copy into a Column from a matrix with more than one column");
    //~ foreach(ii; 0..this.length) {
      //~ mat[ii, col] = m[ii, 0];
    //~ }
  //~ }

  //~ double[] opSlice(int i0, int i1) {
		//~ double[] result;
		//~ foreach(row; i0..i1) {
			//~ result ~= this[row];
		//~ }
		//~ return result;
	//~ }

  //~ bool empty() { return length == 0; }
  //~ double front() { return data[0]; }
  //~ void popFront() {
    //~ data = &data[1];
    //~ length -= 1;
  //~ }
//~ }

//~ struct ByRow {
  //~ GretlMatrix mat;
  //~ int length;
  //~ private int rowno = 0;
  
  //~ this(GretlMatrix m) {
    //~ mat = m;
    //~ length = m.rows;
  //~ }

  //~ bool empty() { 
    //~ return length == 0; 
  //~ }
  
  //~ Row front() { 
    //~ return Row(mat, rowno); 
  //~ }

  //~ void popFront() {
    //~ rowno += 1;
    //~ length -= 1;
  //~ }
//~ }
  
//~ struct ByRow {
  //~ GretlMatrix mat;
  //~ int length;
  //~ private int rowno = 0;
  
  //~ this(GretlMatrix m) {
    //~ mat = m;
    //~ length = m.rows;
  //~ }

  //~ bool empty() { 
    //~ return length == 0; 
  //~ }
  
  //~ Row front() { 
    //~ return Row(mat, rowno); 
  //~ }

  //~ void popFront() {
    //~ rowno += 1;
    //~ length -= 1;
  //~ }
//~ }

//~ struct ByColumn {
  //~ GretlMatrix mat;
  //~ int colno;
  //~ int length;

  //~ this(GretlMatrix m) {
		//~ writeln("start of constructor");
    //~ mat = m;
    //~ colno = 0;
    //~ length = m.cols;
    //~ writeln("exiting constructor");
  //~ }

  //~ bool empty() { 
    //~ return length == 0; 
  //~ }
  
  //~ Col front() { 
    //~ return Col(mat, colno); 
  //~ }
  
  //~ void popFront() {
    //~ colno += 1;
    //~ length -= 1;
  //~ }
//~ }

//~ struct Row {}
//~ alias Rows = Row[];

//~ struct Col {}
//~ alias Cols = Col[];
