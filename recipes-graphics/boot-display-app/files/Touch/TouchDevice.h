#ifndef TOUCH_DEVICE_H_
#define TOUCH_DEVICE_H_

#include <unistd.h>
#include <stdbool.h>
#include "Touch.h"

#ifdef  __cplusplus
extern "C" {
#endif

int InitTouchDevice();
void DestroyTouchDevice();

#ifdef  __cplusplus
}
#endif
#endif