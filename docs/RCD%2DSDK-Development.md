# RCD SDK Design

## Meeting notes between Allison, Doug, and Jordan (12/29/2021)
We had a brainstorming session on exactly what the sdk/developer experience should look like for the RCD platform. Specifically, what the layer between the kernel/distro and the application code should look like.


### Key Questions
**What does the developer experience look like?**

+ We talked some about what the developer should "see". Should we be writing an Eclipse/VisualStudio/VSCode extension? How much should we be hiding from the user?
+ No resolution was made on what we should use as our IDE/extension/whatever. Jordan suggested that perhaps looking at how the developer experience for the Raspberry Pi works could be a good starting point. Given that we are making our own linux box, Pi is probably a good comparison point versus something like the Esp32 or Nordic chips. 
+ In term of how much should be hidden from the user, we agreed that the user should know they are running a linux box and we don't need to discourage them from doing linux-style things like editing files in `/etc/conf` or whatever. That being said, it shouldn't be necessary for most purposes. Jordan made the analogy of an onion - "It has layers, and as you peel back layers it gets more smelly". In this context, that means we can provide nice high-level apis (in the form of header files/dlls that can be linked) that have a lot of the details of what they do in config files or lower-level libraries. If you need to mess with the lower level stuff, feel free to, but it will be a worse experience.

**What should be in this layer?**
+ This is still somewhat up in the air, but I think the important thing to keep track of is we are building a toolbox that application developers can effectively utilize. Things that should be in that toolbox (probably) include
+ Wifi/Ethernet
+ OTA
+ rs45
+ CAN
+ J1939
+ BLE
+ Analog/Digital Pin I/O
+ Audio (both mics/line in and out)
+ Watchdogs?
+ Threading support?
+ PubSub?
+ File I/O, Variable persistence

**So what does the layer look like from the point of view of the app developer**
+ To start, I imagine it will be some header files that you can "#include" into your app code. These header files then include handy functions for doing whatever you need with that part of the hardware.
+ C seems like the appropriate language for this layer, at least for the core business logic. The advantage of C being it is performant and can be easily ported to any other environment that people might want to write applications in (C++/Python/Node/Java/C#).

**How does this fit in with the Spa-Touch work we've been doing so far**
+ There probably won't be a ton that can be transferred from the spa-touch to this layer. The main value-add of the spa-touch demo is to show that our platform does work, we can wrap C modules in Node, and develop UIs using web tech. It's more of a proof-of-concept than a tool in our toolbox.

**So how much do we actually need to write?**
+ Hopefully not a ton. Many of these functionalities already exist elsewhere. For example, we already have a C api for CAN messaging through `SocketCan` The value added from our api is it can provide some higher-level function calls where possible, and the exercise of writing our apis provides an easy way for us to validate these functionalities are working. If an api we wrote exists, app developers can be confident that it will "just work" and all the low-level/hardware intricacies are in its implementation.

## Testing/Proving out functionality
+ We proposed two ways to prove out our functionality. Allison made the recommendation of a sample app that can run on the board where we see the low-level chips working. For example, there can be a BLE tab on this sample app where you can have buttons to do things like turn on the ble chip, scan for devices, connect to a device, and see packets fly back and forth.
+ Allison then had the brilliant idea of putting two boards next to each other to have the testing automated. For example, we can have a program that is a tester and another that is being tested, and one board send CAN packets to the other while the other receives CAN packets and both can validate that what the test expects is happening. 
+ Testing could be more fully fleshed out and developed by Berni/Ryan

## Actionable items:
+ Steve spent some time trying to get the BLE/Esp32 chip talking to the main cpu. However, he was running into issues. This will need to be resumed later.
+ A conversation with Jake Pratt should happen to see what code/libraries they may have that can be brought over.
+ Meet with Berni/Ryan to talk about testing setups.
+ Jordan will start on developing a module for messing with Analog/Digital Pin I/O. Somewhere along the way this will involve starting to flesh out the sample application.

