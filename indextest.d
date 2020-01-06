import gretlmat.base;
import std.stdio;

void main() {
	auto m = DoubleMatrix(3,2);
	// m[0..3, 0] = [1.1, 2.2, 3.3];
	// m[_all, 0] = [1.1, 2.2, 3.3];
	// m[0, "gdp"] = 7.2;
	// m["dogs", 3] = 8.7;
	foreach(row; 0..3) {
		foreach(col; 0..2) {
			m[row, col] = 1.1*(row+col);
		}
	}
	m.print("Original matrix");
	m[2,1] = 0.5;
	m.print("Updated matrix");
	try {
		m[-1, 1] = 1.4;
	} catch(Throwable) {
		writeln("Caught negative index");
	}
	try {
		m[1, -1] = 1.4;
	} catch(Throwable) {
		writeln("Caught negative index");
	}
	try {
		m[1, 2] = 1.4;
	} catch(Throwable) {
		writeln("Caught out of bounds");
	}
	try {
		m[3, 1] = 1.4;
	} catch(Throwable) {
		writeln("Caught out of bounds");
	}
}
