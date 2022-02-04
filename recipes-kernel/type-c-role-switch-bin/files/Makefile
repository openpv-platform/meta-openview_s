LIB_NAME = type-c-role-switch
EXEC_NAME = $(LIB_NAME)-bin

all: $(EXEC_NAME)

$(EXEC_NAME):
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(EXEC_NAME) $(EXEC_NAME).c $(LIB_NAME).c $(LIB_OBJ_NAME) -I. -Wall -Os

clean:
	rm $(EXEC_NAME) | true