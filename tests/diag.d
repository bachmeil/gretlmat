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
}
