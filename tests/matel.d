import gretlmat.base;
import core.exception, std.stdio;

void main() {
	auto m = DoubleMatrix(3,3);
	Row(m, 0) = [1.1, 2.2, 3.3];
	Row(m, 1) = [4.4, 5.5, 6.6];
	Row(m, 2) = [7.7, 8.8, 9.9];
	m.print("Original matrix");
	
	auto matel1 = MatrixElements(m, [ [0,0], [2,0], [0,2], [2,2] ]);
	matel1 = -3.6;
	m.print("Changed all corner elements");
	
	// Now do the same but for a generic matrix
	// This is a pointless example
	auto matel2 = MatrixElements(m, [0,0], &nextIndex, &done);
	matel2 = -5.7;
	m.print("More changes to the corner elements");
	
	matel2 = [0.0, 0.5, 1.0, 2.6];
	m.print("More changes to the corner elements");
}

int[2] nextIndex(DoubleMatrix dm, int[2] ind) {
	if (ind == [0,0]) {
		return [dm.rows-1, 0];
	} else if (ind == [dm.rows-1, 0]) {
		return [0, dm.cols-1];
	} else if (ind == [0, dm.cols-1]) {
		return [dm.rows-1, dm.cols-1];
	} else {
		return [0, dm.cols*2];
	}
}

bool done(DoubleMatrix dm, int[2] ind) {
	return ind[1] >= dm.cols;
}
	
