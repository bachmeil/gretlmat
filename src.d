module gretlmat.base;
import std.conv, std.exception, std.stdio;

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
  // Check for overflow just to be safe
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
	
	// Find element number associated with index
	// Include all asserts in here
	int elt(int r, int c) {
		assert(r >= 0, "Cannot have a negative row index");
		assert(c >= 0, "Cannot have a positive row index");
		assert(r < this.rows, "First index exceeds the number of rows");
		assert(c < this.cols, "Second index exceeds the number of columns");
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
  
  void opIndexAssign(double v, int r, int c) {
    ptr[elt(r, c)] = v;
  }
  
  void opIndexAssign(T1, T2)(double v, T1 r, T2 c) {
		ptr[elt(r.to!int, c.to!int)] = v;
	}

  void opAssign(DoubleMatrix m) {
    assert(this.data.length == m.data.length, "Dimensions do not match for matrix assignment");
		this.data[] = m.data[];
  }
  
  // Safe (non-mutating) approach to changing dimensions
  DoubleMatrix reshape(int newrows, int newcols=1) {
    auto result = DoubleMatrix(newrows, newcols);
    assert(result.length == this.length, "Wrong number of elements in call to reshape");
    result.data[] = this.data[];
    return result;
  }
  
  DoubleMatrix setColumns(int newcols) {
		//~ assert(newcols > 0, "Number of columns has to be greater than zero");
		auto result = DoubleMatrix(this.length / newcols, newcols);
    assert(result.length == this.length, "Wrong number of elements in call to setColumns");
		result.data[] = this.data[];
		return result;
	}

  DoubleMatrix setRows(int newrows) {
		//~ assert(newrows > 0, "Number of rows has to be greater than zero");
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

  DoubleMatrix dup() {
		auto result = DoubleMatrix(this.rows, this.cols);
		result.data[] = this.data[];
		return result;
	}
	
	DoubleMatrix unsafeClone() {
		DoubleMatrix result;
		result.rows = this.rows;
		result.cols = this.cols;
		result.data = this.data;
		return result;
	}
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

void print(DoubleMatrix m, string msg="") {
	writeln(msg);
  foreach(row; 0..m.rows) {
    foreach(col; 0..m.cols) {
      write(m[row, col], " ");
    }
    writeln("");
  }
}

