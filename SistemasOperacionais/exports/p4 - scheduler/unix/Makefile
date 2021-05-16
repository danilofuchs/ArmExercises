.PHONY: tasks

debug.o: libraries/debug.c libraries/debug.h
	# Build library
	gcc -c libraries/debug.c
	# Archive library
	ar rvs libdebug.a debug.o

queue.o: libraries/queue.c libraries/queue.h
	# Build library
	gcc -c libraries/queue.c
	# Archive library
	ar rvs libqueue.a queue.o

ppos_core.o: ppos_core.c ppos_data.h ppos.h
	# Build library
	gcc -c ppos_core.c
	# Archive library
	ar rvs libppos_core.a ppos_core.o

main: debug.o queue.o ppos_core.o
	gcc -o main main.c -L. -lm -lppos_core -ldebug -lqueue

	# Move ouputs to /out
	rm -rf out
	mkdir out
	mv *.o main *.a ./out
