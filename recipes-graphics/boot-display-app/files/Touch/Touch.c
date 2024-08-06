#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <semaphore.h>
#include <signal.h>

#include "Touch.h"

TAILQ_HEAD(TouchHead, TouchEntry);
static struct TouchHead head;
static sem_t touch_sem;
static pthread_mutex_t touch_mtx;

void createTouchQueue() {
    pthread_mutex_init(&touch_mtx, NULL);
    sem_init(&touch_sem, 0, 0);
    TAILQ_INIT(&head);
    printf("[] Done creating Touch input queue\r\n");
}


void enqueue(TouchEvent *item) {
    pthread_mutex_lock(&touch_mtx);
    struct TouchEntry *entry = malloc(sizeof(struct TouchEntry));
    entry->data = *item;
    TAILQ_INSERT_TAIL(&head, entry, entries);
    pthread_mutex_unlock(&touch_mtx);
    sem_post(&touch_sem);
}

void loadItem(TouchEvent *item)
{
    pthread_mutex_lock(&touch_mtx);
    struct TouchEntry *entry;
    entry = TAILQ_FIRST(&head);
    item->id = entry->data.id;
    item->x = entry->data.x;
    item->y = entry->data.y;
    item->type = entry->data.type;
    TAILQ_REMOVE(&head, entry, entries);
    free(entry);
    pthread_mutex_unlock(&touch_mtx);
}


bool dequeue(TouchEvent *item, unsigned int timeoutMS) {
    int s;
    struct timespec ts;
    bool itemDequeued = false;

    clock_gettime(CLOCK_REALTIME, &ts);
    // convert from milli sec to nanosec
    if (timeoutMS < 1000)
    {
        ts.tv_sec += 0;
        ts.tv_nsec += (timeoutMS * 1000000);
    }
    else    // Max timeout allowed is 1 second
    {
        ts.tv_sec += 1;
        ts.tv_nsec += 0;
    }
    s = sem_timedwait(&touch_sem, &ts);
    if (!TAILQ_EMPTY(&head))
    {
        loadItem(item);
        itemDequeued = true;
    }
    return itemDequeued;
}

