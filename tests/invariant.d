import gretlmat.base;
import core.exception, std.stdio;

void main() {
	auto m = DoubleMatrix(2,2);
	
	// Have not yet defined opIndexAssign
	// Demonstrates underlying storage by column
	m.data[0] = 1.1;
	m.data[1] = 2.2;
	m.data[2] = 3.3;
	m.data[3] = 4.4;
	m.print("Matrix");
	
	m.rows = 4;
	// This would fail due to violating the invariant condition
	// m.print("New matrix");
	//
	// But this is okay, because now the dimensions match the length of the data array
	m.cols = 1;
	m.print("New matrix");
	
	DoubleMatrix mm = m.reshape(1,4);
	mm.print("After reshaping");
	
	DoubleMatrix mmm = m.setColumns(2);
	mmm.print("Back to the original matrix");
	
	void mes(AssertError exc, int j) {
		writeln("Caught expected failure ", j);
		writeln("Message: ", exc.msg);
		writeln("Line ", exc.line, " in ", exc.file);
	}
	
	try {
		DoubleMatrix m2 = m.reshape(-2, 2);
	} catch(AssertError exc) {
		mes(exc, 1);
	}
	try {
		DoubleMatrix m2 = m.reshape(-2, -2);
	} catch(AssertError exc) {
		mes(exc, 2);
	}
	try {
		DoubleMatrix m2 = m.reshape(2, -2);
	} catch(AssertError exc) {
		mes(exc, 3);
	}
	try {
		DoubleMatrix m2 = m.reshape(4, 3);
	} catch(AssertError exc) {
		mes(exc, 4);
	}
	try {
		DoubleMatrix m2 = m.setColumns(0);
	} catch(AssertError exc) {
		mes(exc, 5);
	}
	try {
		DoubleMatrix m2 = m.setColumns(-2);
	} catch(AssertError exc) {
		mes(exc, 6);
	}
	try {
		DoubleMatrix m2 = m.setColumns(3);
	} catch(AssertError exc) {
		mes(exc, 7);
	}
	try {
		DoubleMatrix m2 = m.setColumns(300);
	} catch(AssertError exc) {
		mes(exc, 8);
	}
	try {
		DoubleMatrix m2 = m.setRows(0);
	} catch(AssertError exc) {
		mes(exc, 9);
	}
	try {
		DoubleMatrix m2 = m.setRows(-2);
	} catch(AssertError exc) {
		mes(exc, 10);
	}
	try {
		DoubleMatrix m2 = m.setRows(3);
	} catch(AssertError exc) {
		mes(exc, 11);
	}
	try {
		DoubleMatrix m2 = m.setRows(300);
	} catch(AssertError exc) {
		mes(exc, 12);
	}
	try {
		m.unsafeSetColumns(3);
	} catch(AssertError exc) {
		mes(exc, 100);
	}
	try {
		m.unsafeSetColumns(-2);
	} catch(AssertError exc) {
		mes(exc, 200);
	}
}
