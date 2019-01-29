/*
     File: Utils.m
 Abstract: n/a
  Version: 1.1
 
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
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "Utils.h"
#import <GLKit/GLKMath.h>

@implementation SCNNode (ASCAdditions)

- (SCNNode *)asc_addChildNodeNamed:(NSString *)name fromSceneNamed:(NSString *)path withScale:(CGFloat)scale {
    // Load the scene from the specified file
    SCNScene *scene = [SCNScene sceneNamed:path];
    
    // Retrieve the root node
    SCNNode *node = scene.rootNode;
    
    // Search for the node named "name"
    if (name) {
        node = [node childNodeWithName:name recursively:YES];
    }
    else {
        // Take the first child if no name is passed
        node = node.childNodes[0];
    }
    
    if (scale != 0) {
        // Rescale based on the current bounding box and the desired scale
        // Align the node to 0 on the Y axis
        SCNVector3 min, max;
        [node getBoundingBoxMin:&min max:&max];
        
        GLKVector3 mid = GLKVector3Add(SCNVector3ToGLKVector3(min), SCNVector3ToGLKVector3(max));
        mid = GLKVector3MultiplyScalar(mid, 0.5);
        mid.y = min.y; // Align on bottom
        
        GLKVector3 size = GLKVector3Subtract(SCNVector3ToGLKVector3(max), SCNVector3ToGLKVector3(min));
        CGFloat maxSize = MAX(MAX(size.x, size.y), size.z);
        
        scale = scale / maxSize;
        mid = GLKVector3MultiplyScalar(mid, scale);
        mid = GLKVector3Negate(mid);
        
        node.scale = SCNVector3Make(scale, scale, scale);
        node.position = SCNVector3FromGLKVector3(mid);
    }
    
    // Add to the container passed in argument
    [self addChildNode:node];
    
    return node;
}

+ (instancetype)asc_boxNodeWithTitle:(NSString *)title frame:(NSRect)frame color:(NSColor *)color cornerRadius:(CGFloat)cornerRadius centered:(BOOL)centered {
    static NSDictionary *titleAttributes = nil;
    static NSDictionary *centeredTitleAttributes = nil;
    
    // create and extrude a bezier path to build the box
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:cornerRadius yRadius:cornerRadius];
    path.flatness = 0.05;
    
    SCNShape *shape = [SCNShape shapeWithPath:path extrusionDepth:20];
    shape.chamferRadius = 0.0;
    
    SCNNode *node = [SCNNode node];
    node.geometry = shape;
    
    // create an image and fill with the color and text
    NSSize textureSize;
    textureSize.width = ceilf(frame.size.width * 1.5);
    textureSize.height = ceilf(frame.size.height * 1.5);
    
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
            [paraphStyle setMinimumLineHeight:38];
            [paraphStyle setMaximumLineHeight:38];
            
            NSFont *font = [NSFont fontWithName:@"Myriad Set Semibold" size:34] ?: [NSFont fontWithName:@"Avenir Medium" size:34];
            
            NSShadow *shadow = [[NSShadow alloc] init];
            [shadow setShadowOffset:NSMakeSize(0, -2)];
            [shadow setShadowBlurRadius:4];
            [shadow setShadowColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.5]];
            
            titleAttributes = @{ NSFontAttributeName            : font,
                                 NSForegroundColorAttributeName : [NSColor whiteColor],
                                 NSShadowAttributeName          : shadow,
                                 NSParagraphStyleAttributeName  : paraphStyle };
            
            
            NSMutableParagraphStyle *centeredParaphStyle = [paraphStyle mutableCopy];
            [centeredParaphStyle setAlignment:NSCenterTextAlignment];
            
            centeredTitleAttributes = @{ NSFontAttributeName            : font,
                                         NSForegroundColorAttributeName : [NSColor whiteColor],
                                         NSShadowAttributeName          : shadow,
                                         NSParagraphStyleAttributeName  : centeredParaphStyle };
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
            textSize.height += 38;
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

+ (instancetype)asc_planeNodeWithImageNamed:(NSString *)imageName size:(CGFloat)size isLit:(BOOL)isLit {
    return [self asc_planeNodeWithImage:[NSImage imageNamed:imageName] size:size isLit:isLit];
}

+ (instancetype)asc_labelNodeWithString:(NSString *)string size:(ASCLabelSize)size isLit:(BOOL)isLit {
    SCNNode *node = [SCNNode node];
    
    SCNText *text = [SCNText textWithString:string extrusionDepth:0];
    node.geometry = text;
    node.scale = SCNVector3Make(0.01 * size, 0.01 * size, 0.01 * size);
    text.flatness = 0.4;
    
    // Use Myriad it's if available, otherwise Avenir
    text.font = [NSFont fontWithName:@"Myriad Set" size:50] ?: [NSFont fontWithName:@"Avenir Medium" size:50];
    
    if (!isLit) {
        text.firstMaterial.lightingModelName = SCNLightingModelConstant;
    }
    
    return node;
}

+ (instancetype)asc_gaugeNodeWithTitle:(NSString *)title progressNode:(SCNNode * __strong *)progressNode {
    SCNNode *gaugeGroup = [SCNNode node];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0];
    {
        SCNNode *gauge = [SCNNode node];
        gauge.geometry = [SCNCapsule capsuleWithCapRadius:0.4 height:8];
        gauge.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
        gauge.rotation = SCNVector4Make(0, 0, 1, M_PI_2);
        gauge.geometry.firstMaterial.diffuse.contents = [NSColor whiteColor];
        gauge.geometry.firstMaterial.cullMode = SCNCullFront;
        
        SCNNode *gaugeValue = [SCNNode node];
        gaugeValue.geometry = [SCNCapsule capsuleWithCapRadius:0.3 height:7.8];
        gaugeValue.pivot = CATransform3DMakeTranslation(0, 3.8, 0);
        gaugeValue.position = SCNVector3Make(0, 3.8, 0);
        gaugeValue.scale = SCNVector3Make(1, 0.01, 1);
        gaugeValue.opacity = 0.0;
        gaugeValue.geometry.firstMaterial.diffuse.contents = [NSColor colorWithDeviceRed:0 green:1 blue:0 alpha:1];
        gaugeValue.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
        [gauge addChildNode:gaugeValue];
        
        if (progressNode) {
            *progressNode = gaugeValue;
        }
        
        SCNNode *titleNode = [SCNNode asc_labelNodeWithString:title  size:ASCLabelSizeNormal isLit:NO];
        titleNode.position = SCNVector3Make(-8, -0.55, 0);
        
        [gaugeGroup addChildNode:titleNode];
        [gaugeGroup addChildNode:gauge];
    }
    [SCNTransaction commit];
    
    return gaugeGroup;
}

@end

@implementation NSBezierPath (ASCAdditions)

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

- (instancetype)asc_copyWithResolution:(CGFloat)size {
    NSImageRep *imageRep = [self bestRepresentationForRect:NSMakeRect(0, 0, size, size) context:nil hints:nil];
    if (imageRep) {
        return [[NSImage alloc] initWithCGImage:[imageRep CGImageForProposedRect:nil context:nil hints:nil] size:imageRep.size];
    }
    return self;
}

@end
