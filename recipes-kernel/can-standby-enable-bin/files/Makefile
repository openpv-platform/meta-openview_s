LIB_NAME = can-standby-enable-lib
EXEC_NAME = can-standby-enable-bin

all: $(EXEC_NAME)

$(EXEC_NAME):
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(EXEC_NAME) $(EXEC_NAME).c $(LIB_NAME).c $(LIB_OBJ_NAME) -lgpiod -I. -Wall -Os

clean:
	rm $(EXEC_NAME) | true