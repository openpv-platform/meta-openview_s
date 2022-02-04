LIB_NAME = type-c-role-switch
LIB_OBJ_NAME = lib$(LIB_NAME).so.1.0

all: $(LIB_OBJ_NAME)

$(LIB_OBJ_NAME):
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $(LIB_OBJ_NAME) -fPIC $(LIB_NAME).c -I. -Wall -Os

clean:
	rm $(LIB_OBJ_NAME) | true