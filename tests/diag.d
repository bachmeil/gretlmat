import gretlmat.base;
import core.exception, std.stdio;

void main() {
	auto m = DoubleMatrix(3,3);
	m.fill([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]);
	m.print("Original matrix");
	
	auto m2 = DoubleMatrix(3,3);
	m2.fillByRow([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]);
	m2.print("Original matrix filled by row");
	
	m.fillByColumn([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]);
	m.print("Original matrix again");

	auto bd = BelowDiagonal(m);
	writeln(bd.elements);
	
	auto m3 = DoubleMatrix(3,3);
	m3.print("Look for zeros, there are none there");
	
	bd.mat.print("Lower diagonal matrix");
	
	bd.fill([10.0, 20.0, 30.0]);
	m.print("After changing the below diagonal elements");
	
	m.print("Before copying part below diagonal");
	BelowDiagonal(m) = BelowDiagonal(m2);
	m.print("After copying");
	
	writeln(BelowDiagonal(m).array);

	// Start over with m and m2
	m.fill([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]);
	m2.fillByRow([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]);
	auto ad = AboveDiagonal(m);
	m.print("Original matrix");
	BelowDiagonal(m) = AboveDiagonal(m);
	m.print("I made m symmetric");

	m.fill([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]);
	AboveDiagonal(m) = BelowDiagonal(m);
	m.print("I made m symmetric the other way");
	
	m.fill([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]);
	foreach(ind; ByIndex(m)) {
		writeln(ind);
	}
	
	foreach(el; ByElement(m)) {
		writeln(el);
	}
	
	writeln(Diagonal(m).array);
	Diagonal(m) = [0.5, 0.6, 0.8];
	m.print("After changing the diagonal");
	Diagonal(m) = 0.0;
	m.print("All diagonal elements set to zero");
	
	// Double every element using ByElement
	m.fill([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]);
	foreach(el; ByElement(m)) {
		m[el.row, el.col] = 2.0*el.val;
	}
	m.print("After doubling all the elements");
}
