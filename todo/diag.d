// Demonstrate the idea of the generalized Submatrix type
// Implementation of Diag
import std.stdio;

struct Mat {
	double[] array;
	
	this(double[] v) {
		array = v;
	}
}

struct Diag {
	Mat m;
	
	void opAssign(Diag d) {
		m.array[0] = d.m.array[0];
		m.array[3] = d.m.array[3];
	}
}

void main() {
	auto m = Mat([1.1, 2.2, 3.3, 4.4]);
	writeln(m);
	auto m2 = Mat([5.5, 6.6, 7.7, 8.8]);
	writeln(m2);
	Diag(m) = Diag(m2);
	writeln(m);
}
