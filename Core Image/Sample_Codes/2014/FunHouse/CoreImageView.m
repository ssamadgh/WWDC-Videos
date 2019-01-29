/*
     File: CoreImageView.m
 Abstract: n/a
  Version: 2.1
 
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

#import "CoreImageView.h"
#import "FunHouseWindowController.h"
#import "FunHouseDocument.h"
#import "EffectStack.h"
#import "ParameterView.h"

#define originHandleSize 4.0

@implementation CoreImageView

/*
    Initialzation
*/
    
- (id)initWithFrame: (NSRect)frameRect
{
    if((self = [super initWithFrame:frameRect]) != nil)
    {
    }

    return self;
}

- (void)awakeFromNib
{
    if (initialized)
        return;
    initialized = YES;
    displayingPoints = NO;
    movingNow = NO;
    // we set up a tracking region so we can get mouseEntered and mouseExited events
    lastTrack = [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
    viewTransformScale = 1.0;
    viewTransformOffsetX = 0.0;
    viewTransformOffsetY = 0.0;
}

- (void)dealloc
{
    [super dealloc];
}

/*
    View properties
*/

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (BOOL)isOpaque
{
    return YES;
}


/*
    Accessors and Setters
*/

- (CIContext *)context
{
    return [[NSGraphicsContext currentContext] CIContext];
}

- (void)setFunHouseWindowController:(FunHouseWindowController *)c
{
    controller = c;
}

// set the scale for the view transform
- (void)setViewTransformScale:(CGFloat)scale
{
    viewTransformScale = scale;
}

// set the offset for the view transform
- (void)setViewTransformOffsetX:(CGFloat)x andY:(CGFloat)y
{
    viewTransformOffsetX = x;
    viewTransformOffsetY = y;
}

// return YES if the view transform is not scaled at 1::1
- (BOOL)isScaled
{
    return viewTransformScale != 1.0;
}


// this is our glue for handling undo of filter changes
// call this when we want to set a filter value for a key
- (void)setFilter:(CIFilter *)f value:(id)val forKey:(NSString *)key
{
    FunHouseDocument *d;
    id oldValue;
    
    d = (FunHouseDocument *)[controller document];
    oldValue = [[f valueForKey:key] retain];
    [f setValue:val forKey:key];
    // this is the special way the undo manager saves old object values so it can undo properly
    [[[d undoManager] prepareWithInvocationTarget:self] setFilter:f value:oldValue forKey:key];
    [oldValue release];
}

// call this to get the undo string (shown in the edit menu)
- (NSString *)actionNameForFilter:(CIFilter *)f key:(NSString *)key
{
    NSString *str = unInterCap([key substringFromIndex:5]);
    return [NSString stringWithFormat:@"Change to %@ %@", [CIFilter localizedNameForFilterName:NSStringFromClass([f class])], str, nil];
}

// this is our glue for handling undo image and text placement attribute changes
// call this when we want to set a effect stack dictionary value for a key
- (void)setDict:(NSMutableDictionary *)dict value:(id)val forKey:(NSString *)key
{
    FunHouseDocument *d;
    id oldValue;
    
    d = (FunHouseDocument *)[controller document];
    oldValue = [[dict valueForKey:key] retain];
    [dict setValue:val forKey:key];
    [[[d undoManager] prepareWithInvocationTarget:self] setDict:dict value:oldValue forKey:key];
    [oldValue release];
}

// call this to set the undo string for a filter
- (void)setActionNameForFilter:(CIFilter *)f key:(NSString *)key
{
    FunHouseDocument *d;

    d = (FunHouseDocument *)[controller document];
    [[d undoManager] setActionName:[self actionNameForFilter:f key:key]];
}

// call this when setting a text placement change to an attribute to set the undo string
- (void)setActionNameForTextLayerKey:(NSString *)key
{
    FunHouseDocument *d;

    d = (FunHouseDocument *)[controller document];
    NSString *str = unInterCap([key substringFromIndex:5]);
    [[d undoManager] setActionName:[NSString stringWithFormat:@"Change to Text %@", str, nil]];
}


// glue code to set the image offset, saving the proper info for undo
- (void)setImageByIndex:(NSNumber *)index offsetX:(NSNumber *)x andY:(NSNumber *)y
{
    FunHouseDocument *d;
    EffectStack *es;
    NSPoint oldoffset;

    d = (FunHouseDocument *)[controller document];
    es = [d effectStack];
    oldoffset = [es offsetAtIndex:parmIndex];
    [es setImageLayer:[index integerValue] offset:NSMakePoint([x doubleValue], [y doubleValue])];
    [[[d undoManager] prepareWithInvocationTarget:self] setImageByIndex:index offsetX:[NSNumber numberWithDouble:oldoffset.x] andY:[NSNumber numberWithDouble:oldoffset.y]];
}

// glue code to set the text placement offset (baseline point), saving the proper info for undo
- (void)setTextByIndex:(NSNumber *)index offsetX:(NSNumber *)x andY:(NSNumber *)y
{
    FunHouseDocument *d;
    EffectStack *es;
    NSPoint oldoffset;

    d = (FunHouseDocument *)[controller document];
    es = [d effectStack];
    oldoffset = [es offsetAtIndex:parmIndex];
    [es setTextLayer:[index integerValue] offset:NSMakePoint([x doubleValue], [y doubleValue])];
    [[[d undoManager] prepareWithInvocationTarget:self] setTextByIndex:index offsetX:[NSNumber numberWithDouble:oldoffset.x] andY:[NSNumber numberWithDouble:oldoffset.y]];
}

/*
    Drawing
*/

// draw an onscreen handle for an image origin, text origin, or filter point
// the handle is a "center symbol" - a circle with crosshairs through it.
// the handle is labelled with the string "str".
// all items are "shadowed"
- (void)drawPoint:(NSPoint)pt label:(NSString *)str intoContext:(CGContextRef)cg
{
    CGRect R;
    CGFloat size;    
    pt.x = pt.x * viewTransformScale + viewTransformOffsetX;
    pt.y = pt.y * viewTransformScale + viewTransformOffsetY;
    size = originHandleSize + 0.5;
    pt.x = floor(pt.x) + 0.5;
    pt.y = floor(pt.y) + 0.5;
    CGContextSetRGBStrokeColor(cg, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(cg, 1.0);
    CGContextMoveToPoint(cg, pt.x - originHandleSize * 2.0 + 1.0, pt.y - 1.0);
    CGContextAddLineToPoint(cg, pt.x + originHandleSize * 2.0 + 1.0, pt.y - 1.0);
    CGContextStrokePath(cg);
    R = CGRectMake(pt.x - size + 1.0, pt.y - size - 1.0, size * 2.0, size * 2.0);
    CGContextStrokeEllipseInRect(cg, R);
    CGContextStrokePath(cg);
    CGContextMoveToPoint(cg, pt.x + 1.0, pt.y - originHandleSize * 2.0 - 1.0);
    CGContextAddLineToPoint(cg, pt.x + 1.0, pt.y + originHandleSize * 2.0 - 1.0);
    CGContextStrokePath(cg);
    CGContextSetRGBStrokeColor(cg, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(cg, 1.0);
    CGContextMoveToPoint(cg, pt.x - originHandleSize * 2.0, pt.y);
    CGContextAddLineToPoint(cg, pt.x + originHandleSize * 2.0, pt.y);
    CGContextStrokePath(cg);
    R = CGRectMake(pt.x - size, pt.y - size, size * 2.0, size * 2.0);
    CGContextStrokeEllipseInRect(cg, R);
    CGContextStrokePath(cg);
    CGContextMoveToPoint(cg, pt.x, pt.y - originHandleSize * 2.0);
    CGContextAddLineToPoint(cg, pt.x, pt.y + originHandleSize * 2.0);
    CGContextStrokePath(cg);
    CGContextSetRGBFillColor(cg, 0.0, 0.0, 0.0, 1.0);
    if (!movingNow)
    {
 		NSGraphicsContext	    *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:cg flipped:NO];
   
		[NSGraphicsContext setCurrentContext:graphicsContext];
		[str drawAtPoint:NSMakePoint(pt.x + 4.5, pt.y + 1.5) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13.0], NSFontNameAttribute, [NSColor blackColor], NSForegroundColorAttributeName, nil]];
        CGContextSetRGBFillColor(cg, 1.0, 1.0, 1.0, 1.0);
		[str drawAtPoint:NSMakePoint(pt.x + 3.0, pt.y + 3.0) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13.0], NSFontNameAttribute, [NSColor whiteColor], NSForegroundColorAttributeName, nil]];
	}
}

// render origin handles using AppKit directly
- (CIImage *)drawPoints:(CIImage *)im
{
    NSInteger i, count;
    CGFloat x, y, width, height;
    CIContext *context;
    CIFilter *f;
    NSEnumerator *e;
    CIVector *vec;
    NSDictionary *attr, *parameter;
    NSString *key, *typestring, *classstring, *type;
    NSArray *inputKeys;
    FunHouseDocument *d;
    EffectStack *es;
    NSPoint pt;
    NSAffineTransform *tr;
    NSAffineTransformStruct S;
    NSString *str, *str2, *localizedParameter;
    CGContextRef cg;
    CGLayerRef layer;
    NSRect bounds;
    CIImage *image;
    
	NSGraphicsContext	    *savedContext = [NSGraphicsContext currentContext];
    context = [[NSGraphicsContext currentContext] CIContext];
    bounds = [self bounds];
    layer = [context createCGLayerWithSize:CGSizeMake(NSWidth(bounds), NSHeight(bounds)) info:nil];
    cg = CGLayerGetContext(layer);
    d = (FunHouseDocument *)[controller document];
    // enumerate filters, images, text placements in the effect stack (bottom-to-top)
    es = [d effectStack];
    count = [es layerCount];
    for (i = 0; i < count; i++)
    {
        // if the layer isn't enabled, don't show the handle either
        if (![es layerEnabled:i])
            continue;
        type = [es typeAtIndex:i];
        if ([type isEqualToString:@"filter"])
        {
            // filter effect stack element
            f = [es filterAtIndex:i];
            if (f == nil) {
                CGLayerRelease(layer);
                return nil;
            }
            attr = [f attributes];
            // iterate over parameters, look for parameters containing an origin to be displayed
            inputKeys = [f inputKeys];
            e = [inputKeys objectEnumerator];
            while ((key = [e nextObject]) != nil) 
            {
                parameter = [attr objectForKey:key];
                classstring = [parameter objectForKey:kCIAttributeClass];
                localizedParameter = [parameter objectForKey:kCIAttributeDisplayName];
                str = [NSString stringWithFormat:@"%@ %@", [CIFilter localizedNameForFilterName:NSStringFromClass([f class])],
                  localizedParameter, nil];
                if ([classstring isEqualToString:@"CIVector"])
                {
                    typestring = [parameter objectForKey:kCIAttributeType];
                    if ([typestring isEqualToString:kCIAttributeTypePosition])
                    {
                        // 2D position (point) like a center
                        vec = [f valueForKey:key];
                        pt.x = [vec X];
                        pt.y = [vec Y];
                        [self drawPoint:pt label:str intoContext:cg];
                    }
                    else if ([typestring isEqualToString:kCIAttributeTypeRectangle])
                    {
                        // rectangle - show 4 handles, labelled properly
                        vec = [f valueForKey:key];
                        // make the 4 points
                        x = [vec X];
                        y = [vec Y];
                        width = [vec Z];
                        height = [vec W];
                        pt.x = x;
                        pt.y = y;
                        str2 = [str stringByAppendingString:@" bottom left"];
                        [self drawPoint:pt label:str2 intoContext:cg];
                        pt.x = x + width;
                        pt.y = y;
                        str2 = [str stringByAppendingString:@" bottom right"];
                        [self drawPoint:pt label:str2 intoContext:cg];
                        pt.x = x;
                        pt.y = y + height;
                        str2 = [str stringByAppendingString:@" top left"];
                        [self drawPoint:pt label:str2 intoContext:cg];
                        pt.x = x + width;
                        pt.y = y + height;
                        str2 = [str stringByAppendingString:@" top right"];
                        [self drawPoint:pt label:str2 intoContext:cg];
                    }
                    else if ([typestring isEqualToString:kCIAttributeTypePosition3])
                    {
                        // 3D position, only view the (x,y) components
                        vec = [f valueForKey:key];
                        // make the 4 points
                        x = [vec X];
                        y = [vec Y];
                        pt.x = x;
                        pt.y = y;
                        [self drawPoint:pt label:str intoContext:cg];
                    }
                }
                else if ([classstring isEqualToString:@"NSAffineTransform"])
                {
                    // affine transform origin
                    tr = [f valueForKey:key];
                    S = [tr transformStruct];
                    pt.x = S.tX;
                    pt.y = S.tY;
                    str2 = [str stringByAppendingString:@" origin"];
                    [self drawPoint:pt label:str2 intoContext:cg];
                }
            }
        }
        else if ([type isEqualToString:@"image"])
        {
            // image effect stack element
            // show an image origin (in its center)
            CGRect r = [[es imageAtIndex:i] extent];
            NSPoint offset = [es offsetAtIndex:i];
            pt.x = offset.x + (r.origin.x + r.size.width * 0.5);
            pt.y = offset.y + (r.origin.y + r.size.height * 0.5);
            str = [[es filenameAtIndex:i] stringByAppendingString:@" center"];
            [self drawPoint:pt label:str intoContext:cg];
        }
        else if ([type isEqualToString:@"text"])
        {
            // text effect stack element
            // show a text origin (baseline point)
            NSPoint offset = [es offsetAtIndex:i];
            pt.x = offset.x;
            pt.y = offset.y;
            [self drawPoint:pt label:@"text origin" intoContext:cg];
        }
    }
    image = [[[CIImage alloc] initWithCGLayer:layer] autorelease];
    CGLayerRelease(layer);
    f = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [f setValue:im forKey:@"inputBackgroundImage"];
    [f setValue:image forKey:@"inputImage"];
	[NSGraphicsContext setCurrentContext:savedContext];
    return [f valueForKey:@"outputImage"];
}

// compute the whole core image graph for the view (not yet evaluated!)
- (CIImage *)coreImageResult
{
    FunHouseDocument *d = (FunHouseDocument *)[controller document];
    EffectStack *es = [d effectStack];
    // if the effect stack core image graph isn't complete (dued to a missing image) then
    // we do not redraw
    if ([es hasMissingImage])
        return nil;
    // compute the core image graph for our view
    CIImage *res = [es coreImageResultForRect:[self bounds]];
    // overlay onto a constant color (black) to show alpha
    CIFilter *f = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    [f setValue:[CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] forKey:@"inputColor"];
    CIImage *black = [f valueForKey:@"outputImage"];
    if (res == nil)
        return black;
    f = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [f setValue:black forKey:@"inputBackgroundImage"];
    [f setValue:res forKey:@"inputImage"];
    res = [f valueForKey:@"outputImage"];
    if (viewTransformScale != 1.0 || viewTransformOffsetX != 0.0 || viewTransformOffsetY != 0.0)
    {
        // if the view transform is not unity, apply an affine transform to view the result
        // this is necessary when the input image is larger than the screen...
        f = [CIFilter filterWithName:@"CIAffineTransform"];
        NSAffineTransform *t = [NSAffineTransform transform];
        [t scaleBy:viewTransformScale];
        [t translateXBy:viewTransformOffsetX yBy:viewTransformOffsetY];
        [f setValue:t forKey:@"inputTransform"];
        [f setValue:res forKey:@"inputImage"];
        res = [f valueForKey:@"outputImage"];
    }
    return res;
}

- (void)viewBoundsDidChange:(NSRect)bounds
{
    // we set up a tracking region so we can get mouseEntered and mouseExited events
    [self removeTrackingRect:lastTrack];
    lastTrack = [self addTrackingRect:bounds owner:self userData:nil assumeInside:NO];
}

- (void)drawRect:(NSRect)r inCIContext:(CIContext *)context
{
    CGRect cgr;
    CIImage *im;

    cgr = CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height);
    // note: surround a core image evaluation with its own autorelease pool to prevent a huge amount of buildup
    // during a slider drag, for instance.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // compute the core image graph for the view (based on the effect stack)
    im = [self coreImageResult];
    // display origin handles when the mouse is inside the view, and when a modal vwindow isn't present...
    if (displayingPoints && [NSApp modalWindow] == nil)
        im = [self drawPoints:im];
    // if successful, draw the image
    if (im != nil && context != nil)
    {
	if ([NSGraphicsContext currentContextDrawingToScreen])
	{
        [context drawImage:im inRect:cgr fromRect:cgr];
	}
	else
	{
	    CGImageRef cgImage;

	    cgImage = [context createCGImage:im fromRect:cgr format:kCIFormatRGBA16 colorSpace:nil];

	    if (cgImage != NULL)
	    {
            CGContextDrawImage ([[NSGraphicsContext currentContext]
                                 graphicsPort], cgr, cgImage);
            CGImageRelease (cgImage);
	    }
	}
    }
    [pool release];
}

/*
    Event handling
*/

// when entering the view, turn on origin handle display
- (void)mouseEntered:(NSEvent *)theEvent
{
    displayingPoints = YES;
    [self setNeedsDisplay:YES];
}

// when exiting the view, turn off origin handle display
- (void)mouseExited:(NSEvent *)theEvent
{
    displayingPoints = NO;
    [self setNeedsDisplay:YES];
}

// standard procedure for view subclasses to handle mouse down events
- (void)mouseDown:(NSEvent *)event
{
    NSInteger i, count;
    CGFloat dx, dy, dist, closest, x, y, width, height;
    CIFilter *f;
    NSEnumerator *e;
    CIVector *vec;
    NSDictionary *attr, *parameter;
    NSString *key, *typestring, *classstring, *type;
    NSArray *inputKeys;
    NSPoint pt, pp;
    CGPoint p;
    FunHouseDocument *d;
    EffectStack *es;
    NSAffineTransform *tr;
    NSAffineTransformStruct S;
    
    movingNow = YES;
    pt = [self convertPoint:[event locationInWindow] fromView: nil];
    d = (FunHouseDocument *)[controller document];
    es = [d effectStack];
    p = CGPointMake(pt.x, pt.y);
    // account for the view transform
    pt.x = (p.x - viewTransformOffsetX) / viewTransformScale;
    pt.y = (p.y - viewTransformOffsetY) / viewTransformScale;
    parmIndex = -1;
    parmKey = nil;
    parmMode = pmNone;
    count = [es layerCount];
    // explicitly group all the changes during the entire mouse move
    [[d undoManager] beginUndoGrouping];
    savedActionName = nil;
    // pick which origin handle is nearest the mouse point, identify its type for
    // easy handling in the mouseDragged code
    // enumerate the effect stack layers (filter, image, text)
    // this is a pick, so we operate in inverted (front-to-back) order
    // note: this must exactly match the drawPoints: method
    for (i = count - 1; i >= 0; i--)
    {
        type = [es typeAtIndex:i];
        if ([type isEqualToString:@"filter"])
        {
            // filter effect stack element
            f = [es filterAtIndex:i];
            if (f == nil)
                return;
            attr = [f attributes];
            // iterate over parameters, decide which parameter we are closest to, set up to modify it in mouse loop
            inputKeys = [f inputKeys];
            e = [inputKeys objectEnumerator];
            while ((key = [e nextObject]) != nil) 
                {
                parameter = [attr objectForKey:key];
                classstring = [parameter objectForKey:kCIAttributeClass];
                if ([classstring isEqualToString:@"CIVector"])
                {
                    typestring = [parameter objectForKey: kCIAttributeType];
                    if ([typestring isEqualToString: kCIAttributeTypePosition])
                    {
                        // 2D position (point) such as an inputCenter
                        vec = [f valueForKey:key];
                        pp.x = [vec X];
                        pp.y = [vec Y];
                        dx = pp.x - pt.x;
                        dy = pp.y - pt.y;
                        dist = dx*dx + dy*dy;
                        if (parmMode == pmNone || dist < closest)
                        {
                            parmIndex = i;
                            parmKey = key;
                            closest = dist;
                            parmMode = pmPoint;
                        }
                    }
                    else if ([typestring isEqualToString: kCIAttributeTypeRectangle])
                    {
                        // rectangle such as an inputRectangle
                        // enumerate the 4 points
                        vec = [f valueForKey:key];
                        // make the 4 points
                        x = [vec X];
                        y = [vec Y];
                        width = [vec Z];
                        height = [vec W];
                        pp.x = x + width;
                        pp.y = y + height;
                        dx = pp.x - pt.x;
                        dy = pp.y - pt.y;
                        dist = dx*dx + dy*dy;
                        if (parmMode == pmNone || dist < closest)
                        {
                            parmIndex = i;
                            parmKey = key;
                            closest = dist;
                            parmMode = pmTopRight;
                        }
                        pp.x = x;
                        pp.y = y + height;
                        dx = pp.x - pt.x;
                        dy = pp.y - pt.y;
                        dist = dx*dx + dy*dy;
                        if (parmMode == pmNone || dist < closest)
                        {
                            parmIndex = i;
                            parmKey = key;
                            closest = dist;
                            parmMode = pmTopLeft;
                        }
                        pp.x = x + width;
                        pp.y = y;
                        dx = pp.x - pt.x;
                        dy = pp.y - pt.y;
                        dist = dx*dx + dy*dy;
                        if (parmMode == pmNone || dist < closest)
                        {
                            parmIndex = i;
                            parmKey = key;
                            closest = dist;
                            parmMode = pmBottomRight;
                        }
                        pp.x = x;
                        pp.y = y;
                        dx = pp.x - pt.x;
                        dy = pp.y - pt.y;
                        dist = dx*dx + dy*dy;
                        if (parmMode == pmNone || dist < closest)
                        {
                            parmIndex = i;
                            parmKey = key;
                            closest = dist;
                            parmMode = pmBottomLeft;
                        }
                    }
                    else if ([typestring isEqualToString:kCIAttributeTypePosition3])
                    {
                        // 3D position (we only care about x and y in this code)
                        vec = [f valueForKey:key];
                        // make the 4 points
                        x = [vec X];
                        y = [vec Y];
                        pp.x = x;
                        pp.y = y;
                        dx = pp.x - pt.x;
                        dy = pp.y - pt.y;
                        dist = dx*dx + dy*dy;
                        if (parmMode == pmNone || dist < closest)
                        {
                            parmIndex = i;
                            parmKey = key;
                            closest = dist;
                            parmMode = pm3DPoint;
                        }
                    }
                }
                else if ([classstring isEqualToString:@"NSAffineTransform"])
                {
                    // affine transform origin
                    tr = [f valueForKey:key];
                    S = [tr transformStruct];
                    pp.x = S.tX;
                    pp.y = S.tY;
                    dx = pp.x - pt.x;
                    dy = pp.y - pt.y;
                    dist = dx*dx + dy*dy;
                    if (parmMode == pmNone || dist < closest)
                    {
                        parmIndex = i;
                        parmKey = key;
                        closest = dist;
                        parmMode = pmTransformOffset;
                    }
                }
            }
        }
        else if ([type isEqualToString:@"image"])
        {
            // image effect stack element
            CGRect r = [[es imageAtIndex:i] extent];
            NSPoint offset = [es offsetAtIndex:i];
            pp.x = offset.x + (r.origin.x + r.size.width * 0.5);
            pp.y = offset.y + (r.origin.y + r.size.height * 0.5);
            dx = pp.x - pt.x;
            dy = pp.y - pt.y;
            dist = dx*dx + dy*dy;
            if (parmMode == pmNone || dist < closest)
            {
                parmIndex = i;
                closest = dist;
                parmMode = pmImageOffset;
            }
        }
        else if ([type isEqualToString:@"text"])
        {
            // text effect stack element
            NSPoint offset = [es offsetAtIndex:i];
            pp.x = offset.x;
            pp.y = offset.y;
            dx = pp.x - pt.x;
            dy = pp.y - pt.y;
            dist = dx*dx + dy*dy;
            if (parmMode == pmNone || dist < closest)
            {
                parmIndex = i;
                closest = dist;
                parmMode = pmTextOffset;
            }
        }
    }
    // save a string so we have an easier time evaluating the undo string at mouse up
    if (parmMode == pmImageOffset)
        savedActionName = @"Image Move";
    else if (parmMode == pmTextOffset)
        savedActionName = @"Text Move";
    else if (parmMode!= pmNone)
        savedActionName = [[self actionNameForFilter:f key:parmKey] retain];
    [self setNeedsDisplay:YES];
}

// handle mouse movement
- (void)mouseDragged:(NSEvent *)event
{
    CGFloat left, right, top, bottom, temp;
    CIFilter *f;
    CIVector *vec;
    NSPoint pt, offset;
    CGPoint p;
    CGRect r;
    FunHouseDocument *d;
    EffectStack *es;
    NSAffineTransform *tr;
    NSAffineTransformStruct S;

    pt = [self convertPoint:[event locationInWindow] fromView: nil];
    if (parmMode == pmNone || parmIndex == -1)
        return;
    d = (FunHouseDocument *)[controller document];
    es = [d effectStack];
    p = CGPointMake(pt.x, pt.y);
    // account for the view transform
    pt.x = (p.x - viewTransformOffsetX) / viewTransformScale;
    pt.y = (p.y - viewTransformOffsetY) / viewTransformScale;
    f = [es filterAtIndex:parmIndex];
    if (parmMode != pmNone)
    {
        // dispatch on the type of thing being moved (note: each thing gets an origin handle)
        switch (parmMode)
        {
        case pmPoint:
            // move some filter's point
            [self setFilter:f value:[CIVector vectorWithX:pt.x Y:pt.y Z:0 W:0] forKey:parmKey];
            break;
        case pmBottomLeft:
        case pmBottomRight:
        case pmTopLeft:
        case pmTopRight:
            // move some filter's corner of a rectangle
            // get vector as rectangle
            vec = [f valueForKey:parmKey];
            left = [vec X];
            bottom = [vec Y];
            right = [vec X] + [vec Z];
            top = [vec Y] + [vec W];
            // replace the salient portion
            switch (parmMode)
            {
            case pmBottomLeft:
                left = pt.x;
                bottom = pt.y;
                break;
            case pmBottomRight:
                right = pt.x;
                bottom = pt.y;
                break;
            case pmTopLeft:
                left = pt.x;
                top = pt.y;
                break;
            case pmTopRight:
                right = pt.x;
                top = pt.y;
                break;
            default:
                break;
            }
            // check for inversion along either axis
            if (left > right)
            {
                temp = left;
                left = right;
                right = temp;
                parmMode = ((parmMode - pmBottomLeft) ^ 1) + pmBottomLeft;
            }
            if (bottom > top)
            {
                temp = top;
                top = bottom;
                bottom = temp;
                parmMode = ((parmMode - pmBottomLeft) ^ 2) + pmBottomLeft;
            }
            // pack back into rectangle
            [self setFilter:f value:[CIVector vectorWithX:left Y:bottom Z:right - left W:top - bottom] forKey:parmKey];
            break;
        case pmImageOffset:
            // move an image layer
            r = [[es imageAtIndex:parmIndex] extent];
            offset.x = pt.x - (r.origin.x + r.size.width * 0.5);
            offset.y = pt.y - (r.origin.y + r.size.height * 0.5);
            [self setImageByIndex:[NSNumber numberWithInteger:parmIndex] offsetX:[NSNumber numberWithDouble:offset.x] andY:[NSNumber numberWithDouble:offset.y]];
            break;
        case pmTextOffset:
            // move a text placement
            offset.x = pt.x;
            offset.y = pt.y;
            [self setTextByIndex:[NSNumber numberWithInteger:parmIndex] offsetX:[NSNumber numberWithDouble:offset.x] andY:[NSNumber numberWithDouble:offset.y]];
            break;
        case pmTransformOffset:
            // move an affine transform offset
            tr = [f valueForKey:parmKey];
            S = [tr transformStruct];
            S.tX = pt.x;
            S.tY = pt.y;
            [tr setTransformStruct:S];
            [self setFilter:f value:tr forKey:parmKey];
            break;
        case pm3DPoint:
            // move a 3D point (only the x and y matters)
            vec = [f valueForKey:parmKey];
            temp = [vec Z];
            // pack back into rectangle
            [self setFilter:f value:[CIVector vectorWithX:pt.x Y:pt.y Z:temp] forKey:parmKey];
            break;
        default:
            break;
        }
        [self setNeedsDisplay:YES];
    }
}

// the standard procedure overridden in view subclasses to handle the mouse up event
- (void)mouseUp:(NSEvent *)event
{
    FunHouseDocument *d;
    
    movingNow = NO;
    d = (FunHouseDocument *)[controller document];
    // now that we have finished the move, set the action name for the undo group
    [[d undoManager] setActionName:savedActionName];
    // explicitly group all the changes during the entire mouse move
    [[d undoManager] endUndoGrouping];
    if (savedActionName != nil)
        [savedActionName release];
    [self setNeedsDisplay:YES];
}


@end

