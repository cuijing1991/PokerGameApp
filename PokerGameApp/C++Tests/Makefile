CC = g++ -std=c++11
CFLAGS = -Wall -g
INCLUDES = -I../C++Classes
SRCS = test_driver.cpp \
			 compare_function_test.cpp \
	     isUniform_function_test.cpp \
			 ../C++Classes/GameProcedure.cpp \
			 ../C++Classes/Card.cpp \
			 ../C++Classes/CardUnit.cpp \
			 ../C++Classes/CardManager.cpp \
		   ../C++Classes/Constants.cpp \
       ../C++Classes/GameInfo.cpp \

OBJS = $(SRCS:.cpp=.o)
MAIN = test_driver

all: $(MAIN)
	@echo Compiled

$(MAIN): $(OBJS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $(MAIN) $(OBJS) $(LFLAGS) $(LIBS)

.cpp.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c $<  -o $@

clean:
	$(RM) $(OBJS) $(MAIN)

depend: $(SRCS)
	makedepend $(INCLUDES) $^
