.PHONY: tasks

tasks:
	# Build library
	gcc -c libraries/debug.c
	# Archive library
	ar rvs libdebug.a debug.o

	# Build library
	gcc -c ppos_core.c
	# Archive library
	ar rvs libppos_core.a ppos_core.o

	gcc -o test1 pingpong-tasks1.c -L. -lm -lppos_core -ldebug
	gcc -o test2 pingpong-tasks2.c -L. -lm -lppos_core -ldebug
	gcc -o test3 pingpong-tasks3.c -L. -lm -lppos_core -ldebug

	# Move ouputs to /out
	rm -rf out
	mkdir out
	mv *.o test1 test2 test3 *.a ./out
