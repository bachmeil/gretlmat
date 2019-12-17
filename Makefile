basic:
	dmd printtest.d src.d -L-lgretl-1.0 -ofprinttest
	mv printtest /bin
	./bin/printtest
