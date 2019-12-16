module gretlmat.base;
import std.stdio;

extern(C) {
  int gretl_matrix_multiply(const GretlMatrix * a, const GretlMatrix * b, GretlMatrix * c);
  void gretl_matrix_multiply_by_scalar(GretlMatrix * m, double x);
  int gretl_matrix_multiply_mod(const GretlMatrix * a, matmod amod, const GretlMatrix * b, matmod bmod, GretlMatrix * c, matmod cmod);
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
    data = new double[r*c];
    rows = r;
    cols = c;
  }
  
  // Use a template to allow conversion of arguments to int
  // Check for overflow just to be safe
  this(T1, T2)(T1 r, T2 c=1) {
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
          data[col*rows+row.to!int] = vals[col];
        }
      }
    // Treat each element as a column
    } else {
      rows= to!int(m[0].length);
      cols = to!int(m.length);
      foreach(col, vals; m) {
        foreach(row; 0..rows) {
          data[col*rows + row.to!int] = vals[row];
        }
      }
	
	int[2] dim() {
		return [rows, cols];
	}
    }
	}
  
	this(GretlMatrix * m) {
		data = new double[m.cols*m.rows];
		rows = m.rows;
		cols = m.cols;
		foreach(row; 0..rows) {
			foreach(col; 0..cols) {
				data[col*rows+row] = m.ptr[col*rows+row];
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
	
  void opAssign(DoubleMatrix m) {
    assert(this.rows*this.cols == m.rows*m.cols, "Dimensions do not match for matrix assignment");
		this.data[] = m.data[];
  }
  
  void unsafeReshape(int newrows, int newcols) {
    assert(this.rows*this.cols == newrows*newcols, "Cannot use unsafeReshape: Dimensions do not match");
    rows = newrows;
    cols = newcols;
  }
  
  unsafeSetColumns(int newcols) {
		assert(this.rows*this.cols % newcols == 0, "argument to unsafeSetColumns is not compatible with current dimensions");
		cols = newcols;
		rows = this.rows*this.cols / newcols;
	}
	
  unsafeSetRows(int newrows) {
		assert(this.rows*this.cols % newrows == 0, "argument to unsafeSetRows is not compatible with current dimensions");
		cols = this.rows*this.cols / newrows;
		rows = newrows;
	}

	// In case a non-int was passed in, use templates for these functions
  void unsafeReshape(T1, T2)(T1 nr, T2 nc) {
		int newrows = nr.to!int;
		int newcols = nc.to!int;
    assert(this.rows*this.cols == newrows*newcols, "Cannot use unsafeReshape: Dimensions do not match");
    rows = newrows;
    cols = newcols;
  }
  
  unsafeSetColumns(T)(T nc) {
		int newcols = nc.to!int;
		assert(this.rows*this.cols % newcols == 0, "argument to unsafeSetColumns is not compatible with current dimensions");
		cols = newcols;
		rows = this.rows*this.cols / newcols;
	}
	
  unsafeSetRows(T)(T nr) {
		int newrows = nr.to!int;
		assert(this.rows*this.cols % newrows == 0, "argument to unsafeSetRows is not compatible with current dimensions");
		cols = this.rows*this.cols / newrows;
		rows = newrows;
	}

  DoubleMatrix reshape(int newrows, int newcols) {
    assert(this.rows*this.cols == newrows*newcols, "Cannot use reshape: Dimensions do not match");
    auto result = DoubleMatrix(newrows, newcols);
    result.data[] = this.data[];
    return result;
  }
  
  DoubleMatrix setColumns(int newcols) {
		assert(this.rows*this.cols % newcols == 0, "argument to setColumns is not compatible with current dimensions");
		auto result = DoubleMatrix(this.rows*this.cols / newcols, newcols);
		result.data[] = this.data[];
		return result;
	}

  DoubleMatrix setRows(int newrows) {
		assert(this.rows*this.cols % newrows == 0, "argument to setRows is not compatible with current dimensions");
		auto result = DoubleMatrix(newrows, this.rows*this.cols / newrows);
		result.data[] = this.data[];
		return result;
	}

	// Templated versions of these functions to handle non-int input
  DoubleMatrix reshape(T1, T2)(T1 nr, T2 nc) {
		int newrows = nr.to!int;
		int newcols = nc.to!int;
    assert(this.rows*this.cols == newrows*newcols, "Cannot use reshape: Dimensions do not match");
    auto result = DoubleMatrix(newrows, newcols);
    result.data[] = this.data[];
    return result;
  }
  
  DoubleMatrix setColumns(T)(T nc) {
		int newcols = nc.to!int;
		assert(this.rows*this.cols % newcols == 0, "argument to setColumns is not compatible with current dimensions");
		auto result = DoubleMatrix(this.rows*this.cols / newcols, newcols);
		result.data[] = this.data[];
		return result;
	}

  DoubleMatrix setRows(T)(T nr) {
		int newrows = nr.to!int;
		assert(this.rows*this.cols % newrows == 0, "argument to setRows is not compatible with current dimensions");
		auto result = DoubleMatrix(newrows, this.rows*this.cols / newrows);
		result.data[] = this.data[];
		return result;
	}

  DoubleMatrix dup() {
		auto result = DoubleMatrix(this.rows, this.cols);
		result.data[] = this.data[];
		return result;
	}
	
	DoubleMatrix unsafeClone() {
		auto result = DoubleMatrix;
		result.rows = this.rows;
		result.cols = this.cols;
		result.data = this.data;
	}
}

DoubleMatrix stack(DoubleMatrix m) {
	auto result = DoubleMatrix(m.rows*m.cols);
	result.data[] = m.data[];
	return result;
}

DoubleMatrix transpose(DoubleMatrix m) {
  auto result = DoubleMatrix(m.cols, m.rows);
  int err = gretl_matrix_transpose(result.matptr, m.matptr);
  enforce(err == 0, "Taking the transpose of a matrix failed");
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

