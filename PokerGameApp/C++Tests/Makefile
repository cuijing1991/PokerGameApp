CC = g++ -std=c++11
CFLAGS = -Wall -g
INCLUDES = -I../C++Classes
SRCS = compare_function_test.cpp \
			 ../C++Classes/GameProcedure.cpp \
			 ../C++Classes/Card.cpp \
			 ../C++Classes/CardUnit.cpp \
			 ../C++Classes/CardManager.cpp \
		   ../C++Classes/Constants.cpp \
       ../C++Classes/GameInfo.cpp \

OBJS = $(SRCS:.c=.o)
MAIN = compare_function_test

all: $(MAIN)
	@echo Compiled

$(MAIN): $(OBJS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $(MAIN) $(OBJS) $(LFLAGS) $(LIBS)

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c $<  -o $@

clean:
	$(RM) *.o *~ $(MAIN)

depend: $(SRCS)
	makedepend $(INCLUDES) $^
