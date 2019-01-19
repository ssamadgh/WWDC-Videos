### LayerBackedOpenGLView ###

===================================================================================================
DESCRIPTION:

The ability to render a Cocoa view hierarchy as a Core Animation layer tree opens the possibility 
of freely combining disparate types of content in ways heretofore difficult. This sample provides 
a simple example of hosting Cocoa controls as subviews of an NSOpenGLView by making the OpenGL 
view layer-backed.

Enabling the "wantsLayer" property of an NSOpenGLView activates layer-backed rendering of the 
OpenGL view. The layer-backed rendering mode uses its own NSOpenGLContext, which is distinct from
the NSOpenGLContext that the view uses for drawing in non-layer-backed mode. AppKit, working in 
concert with CoreAnimation, automatically creates this context and assigns it to the view.

Additional keyboard and mouse controls:
Press [space] to toggle rotation of the globe.
Press [w]/[W] to toggle wireframe rendering.
Press [c]/[C] to toggle displaying the Cocoa controls.
Holding and dragging the mouse to change the roll angle of the globe and the angle from which the 
light is coming.

===================================================================================================
BUILD REQUIREMENTS:

OS X 10.6 or later, Xcode 3.2 or later

===================================================================================================
RUNTIME REQUIREMENTS:

OS X 10.6 or later

===================================================================================================
PACKAGING LIST:

MainController.h/.m
The main controller that handles user interaction.

MouseIgnoringBox.h/.m
A simple NSBox subclass that ignores mouse events.

MyOpenGLView.h/.m
An NSOpenGLView subclass that renders a rotating globe.

Scene.h/.m
Encapsulation of a simple openGL-renderable scene.

Texture.h/.m
A helper class that loads an OpenGL texture from an image path.

===================================================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.1
- Fixed texture issues.

Version 1.0
- First version.

===================================================================================================
Copyright (C) 2007-2013 Apple Inc. All rights reserved.


