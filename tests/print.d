import gretlmat.base;

void main() {
	auto m = DoubleMatrix(2,2);
	
	// Have not yet sdefined opIndexAssign
	// Demonstrates underlying storage by column
	m.data[0] = 1.1;
	m.data[1] = 2.2;
	m.data[2] = 3.3;
	m.data[3] = 4.4;
	m.print("Elements of m");
}
	
