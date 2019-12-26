import gretlmat.base;
import core.exception, std.stdio;

void main() {
  auto m = DoubleMatrix(3,3);
  m[0,0] = 1.1;
  m[0,1] = 2.2;
  m[0,2] = 3.3;
  m[1,0] = 4.4;
  m[1,1] = 5.5;
  m[1,2] = 6.6;
  m[2,0] = 7.7;
  m[2,1] = 8.8;
  m[2,2] = 9.9;
  m.print("Original matrix");
  
  DoubleMatrix m2 = m[0..2, 0..2] + m[1..3, 1..3];
  m2.print("Sum of submatrices");
}
