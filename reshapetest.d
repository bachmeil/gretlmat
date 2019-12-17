import gretlmat.base;
import std.stdio;

void main() {
	auto m = DoubleMatrix(2,2);
	
	// Have not yet sdefined opIndexAssign
	// Demonstrates underlying storage by column
	m.data[0] = 1.1;
	m.data[1] = 2.2;
	m.data[2] = 3.3;
	m.data[3] = 4.4;
	m.print("Original m");
	m.unsafeReshape(4,1);
	writeln(m.dim);
	m.print("Reshaped m");
	m.unsafeSetColumns(4);
	writeln(m.dim);
	m.print("Set columns to 4");
	m.unsafeSetRows(2);
	m.print("Set rows to 2");
}
	
