#ifndef TOUCH_H_
#define TOUCH_H_

#ifdef  __cplusplus
extern "C" {
#endif

#include <pthread.h>
#include <sys/queue.h>
#include <stdbool.h>

#define Q_CAP 10000

enum TouchType 
{
    touch_none = 0,
    touch_down,
    touch_up,
    touch_continue
};

typedef struct {
    enum TouchType type;
    int x;
    int y;
    int id;
} TouchEvent;

struct TouchEntry {
    TouchEvent data;
    TAILQ_ENTRY(TouchEntry) entries;
};

void createTouchQueue();

void enqueue(TouchEvent *item);
bool dequeue(TouchEvent *item, unsigned int timeoutMS);


#ifdef  __cplusplus
}
#endif
#endif

