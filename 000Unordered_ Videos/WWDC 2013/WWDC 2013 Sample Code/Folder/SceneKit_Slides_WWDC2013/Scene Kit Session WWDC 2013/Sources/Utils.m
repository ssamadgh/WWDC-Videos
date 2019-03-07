/*
     File: Utils.m
 Abstract: n/a
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import "Utils.h"
#import <GLKit/GLKMath.h>

@implementation SCNNode (ASCAdditions)

// add the node named 'name' found in the DAE document located at 'path' as a child of the receiver
- (SCNNode *)asc_addChildNodeNamed:(NSString *)name fromSceneNamed:(NSString *)path withScale:(CGFloat)scale {
    SCNNode *node = nil;
    
    // load the scene from the specified file
    SCNScene *scene = [SCNScene sceneNamed:path];
    
    // retrieve the root node
    node = scene.rootNode;
    
    // search for the node named "childNodeName"
    if (name) {
        node = [node childNodeWithName:name recursively:YES];
    }
    else {
        //take first child if no name is passed
        node = node.childNodes[0];
    }
    
    if (scale != 0) {
        // rescale based on the current bounding box and the desired scale
        // align the node to 0 on the Y axis
        SCNVector3 min, max;
        [node getBoundingBoxMin:&min max:&max];
        
        GLKVector3 mid = GLKVector3Add(SCNVector3ToGLKVector3(min), SCNVector3ToGLKVector3(max));
        mid = GLKVector3MultiplyScalar(mid, 0.5);
        mid.y = min.y; //align on bottom
        
        GLKVector3 size = GLKVector3Subtract(SCNVector3ToGLKVector3(max), SCNVector3ToGLKVector3(min));
        CGFloat maxSize = MAX(MAX(size.x, size.y), size.z);
        
        scale = scale / maxSize;
        mid = GLKVector3MultiplyScalar(mid, scale);
        mid = GLKVector3Negate(mid);
        
        node.scale = SCNVector3Make(scale, scale, scale);
        node.position = SCNVector3FromGLKVector3(mid);
    }
    
    // add to the container passed in argument
    [self addChildNode:node];
    
    // return the added node
    return node;
}

// setup a 3D box with a title
+ (instancetype)asc_boxNodeWithTitle:(NSString *)title frame:(NSRect)frame color:(NSColor *)color cornerRadius:(CGFloat)cornerRadius centered:(BOOL)centered {
#define SHAPE_CHAMFER 0.0
#define SHAPE_FLATNESS 0.05
#define TITLE_LINE_HEIGHT 38
#define TEXTURE_SCALE 1.5
    
    static NSDictionary *titleAttributes = nil;
    static NSDictionary *centeredTitleAttributes = nil;
    
    SCNNode *node = [SCNNode node];
    
    // create and extrude a bezier path to build the box
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:cornerRadius yRadius:cornerRadius];
    SCNShape *shape = [SCNShape shapeWithPath:path extrusionDepth:20];
    
    shape.chamferRadius = SHAPE_CHAMFER;
    shape.flatness = SHAPE_FLATNESS;
    node.geometry = shape;
    
    // create an image and fill with the color and text
    NSSize textureSize;
    textureSize.width = ceilf(frame.size.width * TEXTURE_SCALE);
    textureSize.height = ceilf(frame.size.height * TEXTURE_SCALE);
    
    NSImage *texture = [[NSImage alloc] initWithSize:textureSize];
    
    [texture lockFocus];
    
    NSRect drawFrame = NSMakeRect(0, 0, textureSize.width, textureSize.height);
    
    CGFloat hue, saturation, brightness, alpha;
    [[color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    NSColor *lightColor = [NSColor colorWithDeviceHue:hue saturation:saturation - 0.2 brightness:brightness + 0.3 alpha:alpha];
    [lightColor set];
    NSRectFill(drawFrame);
    
    NSBezierPath *fillpath = nil;
    
    if (cornerRadius == 0 && centered == NO) {
        //special case for the "labs" slide
        fillpath = [NSBezierPath bezierPathWithRoundedRect:NSOffsetRect(drawFrame, 0, -2) xRadius:cornerRadius yRadius:cornerRadius];
    }
    else {
        fillpath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(drawFrame, 3, 3) xRadius:cornerRadius yRadius:cornerRadius];
    }
    
    [color set];
    [fillpath fill];
    
    // draw the title if any
    if (title) {
        if (titleAttributes == nil) {
            NSMutableParagraphStyle *paraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [paraphStyle setAlignment:NSLeftTextAlignment];
            [paraphStyle setMinimumLineHeight:TITLE_LINE_HEIGHT];
            [paraphStyle setMaximumLineHeight:TITLE_LINE_HEIGHT];
            
            NSFont *font = [NSFont fontWithName:@"Myriad Set Semibold" size:34];
            if (!font) {
                font = [NSFont fontWithName:@"Avenir Medium" size:34];
            }
            
            NSShadow *shadow = [[NSShadow alloc] init];
            [shadow setShadowOffset:NSMakeSize(0, -2)];
            [shadow setShadowBlurRadius:4];
            [shadow setShadowColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.5]];
            
            titleAttributes = @{ NSFontAttributeName            : font,
                                 NSForegroundColorAttributeName : [NSColor whiteColor],
                                 NSShadowAttributeName          : shadow,
                                 NSParagraphStyleAttributeName  : paraphStyle};
            
            
            NSMutableParagraphStyle *centeredParaphStyle = [paraphStyle mutableCopy];
            [centeredParaphStyle setAlignment:NSCenterTextAlignment];
            
            centeredTitleAttributes = @{ NSFontAttributeName            : font,
                                         NSForegroundColorAttributeName : [NSColor whiteColor],
                                         NSShadowAttributeName          : shadow,
                                         NSParagraphStyleAttributeName  : centeredParaphStyle};
        }
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:title attributes:centered ? centeredTitleAttributes : titleAttributes];
        NSSize textSize = [attrString size];
        
        //check if we need two lines to draw the text
        BOOL twoLines = [title rangeOfString:@"\n"].length > 0;
        if (!twoLines) {
            twoLines = textSize.width > frame.size.width && [title rangeOfString:@" "].length > 0;
        }
        
        //if so, we need to adjust the size to center vertically
        if (twoLines) {
            textSize.height+=TITLE_LINE_HEIGHT;
        }
        
        if (!centered)
            drawFrame = NSInsetRect(drawFrame, 15, 0);
        
        //center vertically
        float dy = (drawFrame.size.height - textSize.height) * 0.5;
        drawFrame.size.height -= dy;
        [attrString drawInRect:drawFrame];
    }
    
    [texture unlockFocus];
    
    //set the created image as the diffuse texture of our 3D box
    SCNMaterial *front = [SCNMaterial material];
    front.diffuse.contents = texture;
    front.locksAmbientWithDiffuse = YES;
    
    //use a lighter color for the chamfer and sides
    SCNMaterial *sides = [SCNMaterial material];
    sides.diffuse.contents = lightColor;
    node.geometry.materials = @[front, sides, sides, sides, sides];
    
    return node;
}

// creates a 3D plan with the specified image mapped on it
+ (instancetype)asc_planeNodeWithImage:(NSImage *)image size:(CGFloat)size isLit:(BOOL)isLit {
    SCNNode *node = [SCNNode node];
    
    float factor = size / (MAX(image.size.width, image.size.height));
    
    node.geometry = [SCNPlane planeWithWidth:image.size.width*factor height:image.size.height*factor];
    node.geometry.firstMaterial.diffuse.contents = image;
    
    //if we don't want the image to be lit, set the lighting model to "constant"
    if (!isLit)
        node.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    return node;
}

// creates a 3D text node
+ (instancetype)asc_labelNodeWithString:(NSString *)string {
    SCNNode *node = [SCNNode node];
    
    SCNText *text = [SCNText textWithString:string extrusionDepth:0];
    node.geometry = text;
    node.scale = SCNVector3Make(0.02, 0.02, 0.02);
    text.flatness = 0.4;
    
    // use Myriad if available, otherwise Avenir
    NSFont *font = [NSFont fontWithName:@"Myriad Set" size:50] ?: [NSFont fontWithName:@"Avenir Medium" size:50];
    text.font = font;
    
    return node;
}

// creates a 3D gauge
// the node that represents the progress will be named 'progressNodeName'
+ (instancetype)asc_gaugeNodeWithTitle:(NSString *)title progressNodeName:(NSString *)progressNodeName {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0];
    
    SCNNode *gaugeGroup = [SCNNode node];
    
#define gauge_WIDTH 8
#define gauge_RADIUS 0.4
    
    SCNNode *gauge = [SCNNode node];
    gauge.geometry = [SCNCapsule capsuleWithCapRadius:gauge_RADIUS height:gauge_WIDTH];
    gauge.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    gauge.rotation = SCNVector4Make(0, 0, 1, M_PI_2);
    gauge.geometry.firstMaterial.diffuse.contents = [NSColor whiteColor];
    gauge.geometry.firstMaterial.cullMode = SCNCullFront;

    SCNNode *gaugeValue = [SCNNode node];
    gaugeValue.geometry = [SCNCapsule capsuleWithCapRadius:gauge_RADIUS-0.1 height:gauge_WIDTH-0.2];
    gaugeValue.pivot = CATransform3DMakeTranslation(0, (gauge_WIDTH-gauge_RADIUS)/2, 0);
    gaugeValue.position = SCNVector3Make(0, (gauge_WIDTH-gauge_RADIUS)/2, 0);
    gaugeValue.scale = SCNVector3Make(1, 0.01, 1);
    gaugeValue.opacity = 0.0;
    gaugeValue.geometry.firstMaterial.diffuse.contents = [NSColor colorWithDeviceRed:0 green:1 blue:0 alpha:1];
    gaugeValue.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    gaugeValue.name = progressNodeName;
    [gauge addChildNode:gaugeValue];
    
    // add a title on the left
    SCNNode *titleNode = [SCNNode asc_labelNodeWithString:title];
    titleNode.position = SCNVector3Make(-8, -0.55, 0);
    titleNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    [gaugeGroup addChildNode:titleNode];
    [gaugeGroup addChildNode:gauge];
    
    [SCNTransaction commit];
    
    return gaugeGroup;
}

@end

@implementation NSBezierPath (ASCAdditions)

// creates an arrow
+ (instancetype)asc_arrowBezierPathWithBaseSize:(NSSize)baseSize tipSize:(NSSize)tipSize hollow:(CGFloat)hollow twoSides:(BOOL)twoSides {
    NSBezierPath *arrow = [NSBezierPath bezierPath];
    
    float h[5];
    float w[4];
    
    w[0] = 0;
    w[1] = baseSize.width - tipSize.width - hollow;
    w[2] = baseSize.width - tipSize.width;
    w[3] = baseSize.width;
    
    h[0] = 0;
    h[1] = (tipSize.height - baseSize.height) * 0.5;
    h[2] = (tipSize.height) * 0.5;
    h[3] = (tipSize.height + baseSize.height) * 0.5;
    h[4] = tipSize.height;
    
    if (twoSides) {
        [arrow moveToPoint:NSMakePoint(tipSize.width, h[1])];
        [arrow lineToPoint:NSMakePoint(tipSize.width + hollow, h[0])];
        [arrow lineToPoint:NSMakePoint(0, h[2])];
        [arrow lineToPoint:NSMakePoint(tipSize.width + hollow, h[4])];
        [arrow lineToPoint:NSMakePoint(tipSize.width, h[3])];
    }
    else {
        [arrow moveToPoint:NSMakePoint(0, h[1])];
        [arrow lineToPoint:NSMakePoint(0, h[3])];
    }
    
    [arrow lineToPoint:NSMakePoint(w[2], h[3])];
    [arrow lineToPoint:NSMakePoint(w[1], h[4])];
    [arrow lineToPoint:NSMakePoint(w[3], h[2])];
    [arrow lineToPoint:NSMakePoint(w[1], h[0])];
    [arrow lineToPoint:NSMakePoint(w[2], h[1])];
    
    [arrow closePath];
    
    return arrow;
}

@end

@implementation NSImage (ASCAdditions)

//load an image that represents the application named
+ (instancetype)asc_imageForApplicationNamed:(NSString *)name {
    NSImage *image = nil;
    
    NSString *path = [[NSWorkspace sharedWorkspace] fullPathForApplication:name];
    if (path) {
        image = [[NSWorkspace sharedWorkspace] iconForFile:path];
        image = [image asc_copyWithResolution:512];
    }
    
    if (image == nil) {
        image = [NSImage imageNamed:NSImageNameCaution];
    }
    
    return image;
}

// create and return an image with the closest resolution to "size"
- (instancetype)asc_copyWithResolution:(CGFloat)size {
    NSImageRep *rep = [self bestRepresentationForRect:NSMakeRect(0, 0, size, size) context:nil hints:nil];
    if (rep) {
        return [[NSImage alloc] initWithCGImage:[rep CGImageForProposedRect:nil context:nil hints:nil] size:[rep size]];
    }
    return self;
}

@end
