# RCD SDK Design

## Meeting notes between Allison, Doug, and Jordan (12/29/2021)
We had a brainstorming session on exactly what the sdk/developer experience should look like for the RCD platform. Specifically, what the layer between the kernel/distro and the application code should look like. It was continually mentioned that Jake Pratt and his team are leading the R&D effort for this facet of the project and we'll need to bring them into the fold immediately following the holiday break.


### Key Questions
**What does the developer experience look like?**

+ We talked some about what the developer should "see". Should we be writing an Eclipse/VisualStudio/VSCode extension? How much should we be hiding from the user?
+ No resolution was made on what we should use as our IDE/extension/whatever. Jordan suggested that perhaps looking at how the developer experience for the Raspberry Pi works could be a good starting point. Given that we are making our own linux box, Pi is probably a good comparison point versus something like the Esp32 or Nordic chips. 
+ In term of how much should be hidden from the user, we agreed that the user should know they are running a linux box and we don't need to discourage them from doing linux-style things like editing files in `/etc/conf` or whatever. That being said, it shouldn't be necessary for most purposes. Jordan made the analogy of an onion - "It has layers, and as you peel back layers it gets more smelly". In this context, that means we can provide nice high-level apis (in the form of header files/dlls that can be linked) that have a lot of the details of what they do in config files or lower-level libraries. If you need to mess with the lower level stuff, feel free to, but it will be a worse experience.

**What should be in this layer?**
+ This is still somewhat up in the air, but I think the important thing to keep track of is we are building a toolbox that application developers can effectively utilize. Things that should be in that toolbox (probably) include
+ Wifi/Ethernet
+ OTA
+ [RS-485](https://en.wikipedia.org/wiki/RS-485)
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

# 1/4/22 Jake Pratt Meeting Notes

Attended by Allison Shaw, Doug Conyers, Jordan Koeller, Jake Pratt

Jake has designed out an architecture of services with clients. For example, the rcd could havea Bluetooth service, a J1939 service, a I/O service, etc. And these are all their own processes that start up when you start an app. When an app developer writes their app, they specify what services and any config for those services via a json file that's loaded on init.

Communication with the services happen via ZeroMQ, which has support for communicating over IP or RPC. For each service, we write a client in the target language that hides all the ZeroMQ/event passing with the service internally. From the app developer's perspective, they instantiate a client which will under the hood start up the requested service and open up the communication with it over ZeroMQ.

These services, as well as the development tools to write applications, is what makes the RCD sticky.

As far as supporting different runtimes is concerned (.NET, Crank, Node, etc.), each runtime would have an implementation of a client for the each service they communicate to. These clients all have the same interface across runtimes.

Jake has started writing these services using CSharp. CSharp compiles down to machine code, and when necessary, you can directly embed C code for any lower-level communcation/apis that might be needed.

App messages to a service to access features we expose (ex. hardware, bluetooth, j1939, etc).

Jake has built a framework for making services. You define a protobuffer file for that service and that allows for connecting between a client and server interface. From the customer perspective, we want them to see an sdk. They are not aware that they are talking over IP. They instantiate a client and call functions on it.

When an app developer wants to use a service, they configure their app to start up that service, pull in the dependencies through NuGet, and can start using it. Application developers see an SDK-like interface, where they instantiate a client and start calling functions.

This environment is highly asynchronous. Communication between the client and service is fully duplex, and optionally requires acknowledgement. Some functions may block or asynchronously wait for a response. Others return `void`.

This idea of services is not all-encompassing. For example, serial ports probably don't belong behind a service. App developers just use serial ports directly. In this case, we would need to write a "client" that is just making system calls directly instead of communicating over ZeroMQ to a service that makes system calls.

What is the throughput? Jake has seen ~ 1000 messages per second on our target, As long as message size is below what can be in one TCP packet. Beyond that point, you start trading off the number of messages you can send for the size of the message.

### Is there anything we can reuse from PowerVision?

Jake seems to think not really. He said we can definitely learn from what was done in the core PowerVision modules, but the rcd stuff will be fundamentally new code.


