#SYWireframe

A simple tool which helps to make routing/navigation more easier in iOS apps 

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Wireframe deal with all the view controller initialization, configuration, navigation, transition etc. works.

The basic wireframe rules are configured in the .plist file.
A classic navigation flow from view controller <X> to <Y> will be like this:

- wireframe look up configuration map for X with Port and Gate(optional), result Y
- wireframe initialize Y with relevant builder and params
- wireframe use relevant navigator to do the presentation from X to Y


The Port and Gate are simply string combinations to identiy a navigation for a given view controller,
for example:
if view controller X has three navigation point to three different view controllers
you can define X-Next-A, X-Next-B, X-Next-C or X-List, X-Detail, X-Setting for them, the rules are up to you.
But for a convenience and ease of use, it will be good to follow some certain rules when you define them.
The X is the Code you give to the view controller for short, remember to assign the real class name for it in the .plist setting file (section Decodes), so that the wireframe can find the right code for current navigating view controller automatically.


There are two ways for wirefirm initialize a view controller:
1. by storyboard, you can set the storyboard file name and the view controller's id in the .plist file
2. by code, you can assign a builder name in .plist file, also register that builder to wirefirm by code
Further more, if you want to configure your new view controllers, please subclass wireframe and override  `configureViewController:fromViewController:withParams:`


You can pick any presentation effect as you want for each navigation, assing the navigator name in the .plist file and register the navigator to wirefirm for specific method, the libaray already set up a default navigator set for quick start.
You can also set a transition component for more customized transition animations.

