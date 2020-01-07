import gretlmat.base;
import core.exception, std.stdio;

void main() {
	auto m = DoubleMatrix(3,3);
	Row(m, 0) = [1.1, 2.2, 3.3];
	Row(m, 1) = [4.4, 5.5, 6.6];
	Row(m, 2) = [7.7, 8.8, 9.9];
	m.print("Original matrix");
	
	auto m2 = DoubleMatrix(3,3);
	m2.fillByRow([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]);
	m2.print("That's the same as filling by row");

	auto r0 = Row(m, 0);
	r0.print("First row of m");

	auto m3 = DoubleMatrix(3,3);
	m3.fillByColumn([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]);
	m3.print("Filled instead by column");

	m.print("Original matrix");
	
	writeln("You're working with row number: ", r0.row);
	writeln("Length of that row: ", r0.length);
	writeln(r0.array);
	writeln(r0[2]);
	r0[2] = 14.2856;
	m.print("I changed the last element of the first row!");
	r0[] = 5.24;
	m.print("I changed the first row!");
	r0 = -7.341;
	m.print("I changed the first row again!");
	r0 = [4.6, 9.2, -4.8];
	m.print("I changed the first row one more time!");	
	//~ r0 = [4.7, 8.8]; // This doesn't work
	r0[1..3].print("Slicing");
	Row r01 = r0[1..3];
	r01[0..1].print("Sliced a slice");
	r01[0..1] = 1.7;
	m.print();
	
	Row r1 = Row(m, 1);
	r1[0..$].print("Print a slice using the dollar operator");
	// foreach works because Row is a range
	foreach(val; r1) {
		writeln(val);
	}
	
	writeln("If you want to do arbitrary things with the individual elements of the Row:");
	writeln(r1.elements);
	writeln("Or if you only need the index values:");
	writeln(r1.indexes);
	foreach(ind; r1.indexes) {
		writeln(m[ind]);
	}
}
