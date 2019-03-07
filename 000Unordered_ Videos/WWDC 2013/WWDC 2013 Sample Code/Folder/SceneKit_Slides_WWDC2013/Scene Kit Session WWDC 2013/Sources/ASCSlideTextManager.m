/*
     File: ASCSlideTextManager.m
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

#import "ASCSlideTextManager.h"
#import "ASCSlide.h"

// some constants to controls the size / chamfer / extrusion and smoothness of the 3D text
#define TEXT_SCALE  0.02
#define TEXT_CHAMFER 1
#define TEXT_DEPTH 0.0
#define TEXT_FLATNESS 0.4

@implementation ASCSlideTextManager {
    // internal states to manage the spacing between two different types of text
    ASCTextType _previousType;
    
    // an array of node per type of text
    SCNNode *_subGroups[ASCTextTypeCount];
    
    // cache the current baseline per type of text
    CGFloat _currentBaseline;
    float   _baselinePerType[ASCTextTypeCount];
    
    //myriad support
    BOOL myriadIsSupported;
}

- (id) init
{
    if (self = [super init]) {
        //create a node that will contain every text nodes
        self.textNode = [SCNNode node];
        
        //initialize baseline to the top of the slide
        //the value is approximative - it should be computed based on the field of view of the camera and the distance of the text from the camera
        _currentBaseline = 14;
    }
    
    return self;
}

//check if the myriad font is installed
- (BOOL)isMyriadInstalled {
    NSFont *font = [NSFont fontWithName:@"Myriad Set" size:54];
    return font != nil;
}

// color per type of text
- (NSColor *) colorForTextType:(ASCTextType) type level:(int) level
{
    switch (type) {
        case ASCTextTypeSubTitle:
            return [NSColor colorWithDeviceRed:160/255.0 green:182/255.0 blue:203/255.0 alpha:1];
        case ASCTextTypeCode:
            if (level == 0)
                return [NSColor whiteColor];
            return [NSColor colorWithDeviceRed:242/255.0 green:173/255.0 blue:24/255.0 alpha:1];
        case ASCTextTypeBody:
            if (level == 2)
                return [NSColor colorWithDeviceRed:115/255.0 green:170/255.0 blue:230/255.0 alpha:1];
        default:
            break;
    }
    
    return [NSColor whiteColor];
}

// extrusion per type of text
- (CGFloat) extrusionDepthForTextType:(ASCTextType) type
{
    if (type == ASCTextTypeChapter)
        return 10.0;
    
    return TEXT_DEPTH;
}

// font per type of text
- (NSString *) fontNameForTextType:(ASCTextType) type level:(NSUInteger) level
{
    
    switch (type) {
        case ASCTextTypeCode:
            return @"Menlo";
        case ASCTextTypeBullet:
            if ([self isMyriadInstalled])
                return @"Myriad Set";
            return @"Avenir Medium";
        case ASCTextTypeBody:
            if (level!=0) {
                if ([self isMyriadInstalled])
                    return @"Myriad Set";
                return @"Avenir Medium";
            }
        default:
            break;
    }
    
    if (type == ASCTextTypeCode) return @"Menlo";
    
    if ([self isMyriadInstalled])
        return @"Myriad Set Semibold";
    
    return @"Avenir Medium";
}

// font size per type of text
- (int) fontSizeForTextType:(ASCTextType) type level:(NSUInteger) level
{
    switch (type) {
        case ASCTextTypeTitle:
            return 88;
        case ASCTextTypeChapter:
            return 94;
        case ASCTextTypeCode:
            return 36;
        case ASCTextTypeSubTitle:
            return 64;
        case ASCTextTypeBody:
        {
            switch (level) {
                case 0:
                    return 50;
                default:
                    return 40;
            }
        }
        default:
            break;
    }
    
    return 56;
}

// line height per type of text
- (CGFloat) lineHeightForTextType:(ASCTextType) type level:(NSUInteger) level
{
    switch (type) {
        case ASCTextTypeTitle:
            return 2.26;
        case ASCTextTypeChapter:
            return 3;
        case ASCTextTypeCode:
            return 1.22;
        case ASCTextTypeSubTitle:
            return 1.78;
        case ASCTextTypeBody:
        {
            switch (level) {
                case 0:
                    return 1.2;
                default:
                    return 1.0;
            }
        }
        default:
            break;
    }
    
    return 1.65;
}

// create (if needed) and return the node that will own the texts for a specific type
- (SCNNode *) textBlockForType:(ASCTextType) type
{
    if (type == ASCTextTypeChapter)
        return [self.textNode parentNode]; //place chapter text at slide root level
    
    if (_subGroups[type])
        return _subGroups[type];
    
    //create a container
    SCNNode *container = [SCNNode node];
    
    [self.textNode addChildNode:container];
    
    _subGroups[type] = container;
    _baselinePerType[type] = _currentBaseline;
    
    return container;
}

// jump new line
- (void)addEmptyLine
{
    _currentBaseline -= 1.2;
}

// create a 3D text with the specified string, type and level and return the newly created node
- (SCNNode *) _addText:(NSString *)string withType:(ASCTextType) type level:(NSUInteger)level
{
    SCNNode *textNode = [SCNNode node];
    
    // for bullet we need to insert a character and also have to manage the indentation based on the level
    if (type == ASCTextTypeBullet) {
        if (level == 0) {
            string = [NSString stringWithFormat:@"• %@", string];
        }
        else {
            SCNNode *bullet = [SCNNode node];
            bullet.geometry = [SCNPlane planeWithWidth:10.0 height:10.0];
            bullet.geometry.firstMaterial.diffuse.contents = [NSColor colorWithDeviceRed:160.0/255 green:182.0/255 blue:203.0/255 alpha:1.0];
            bullet.position = SCNVector3Make(80, 30, 0);
            bullet.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
            bullet.geometry.firstMaterial.writesToDepthBuffer = NO;
            bullet.renderingOrder = 1;
            [textNode addChildNode:bullet];
            string = [NSString stringWithFormat:@"\t\t\t\t%@", string];
        }
    }
    
    // configure the text (color / extrusion etc...)
    float extrusion = [self extrusionDepthForTextType:type];
    SCNText *text = [SCNText textWithString:string extrusionDepth:extrusion];
    textNode.geometry = text;
    text.flatness = TEXT_FLATNESS;
    text.chamferRadius = extrusion == 0 ? 0 : TEXT_CHAMFER;
    text.font = [NSFont fontWithName:[self fontNameForTextType:type level:level] size:[self fontSizeForTextType:type level:level]];
    
    // place it
    if (type == ASCTextTypeChapter) {
        //special case for chapters
        SCNVector3 min, max;
        [textNode getBoundingBoxMin:&min max:&max];
        textNode.position = SCNVector3Make(-11,  -min.y*TEXT_SCALE, 7);
        textNode.scale = SCNVector3Make(TEXT_SCALE, TEXT_SCALE, TEXT_SCALE);
        textNode.rotation = SCNVector4Make(0, 1, 0, M_PI/270.0);
    }
    else {
        // use the current baseline to place it vertically
        textNode.position = SCNVector3Make(-16,  _currentBaseline, 0);
        textNode.scale = SCNVector3Make(TEXT_SCALE, TEXT_SCALE, TEXT_SCALE);
    }
    
    // configure the material of the text
    if (type == ASCTextTypeChapter) {
        SCNMaterial *front = [SCNMaterial material];
        SCNMaterial *side = [SCNMaterial material];
        
        //for chapters we use a different color for the front, chamfer and the side part of the 3d text
        front.emission.contents = [NSColor darkGrayColor];
        front.diffuse.contents = [self colorForTextType:type level:level];
        side.diffuse.contents = [NSColor lightGrayColor];
        textNode.geometry.materials = @[front, front, side, front, front];
    }
    else{
        // use a full white emissive material (visible even when there is no lighting)
        textNode.geometry.firstMaterial = [SCNMaterial material];
        textNode.geometry.firstMaterial.diffuse.contents = [NSColor blackColor];
        textNode.geometry.firstMaterial.emission.contents = [self colorForTextType:type level:level];
        
        // don't write to the z buffer because we don't want the text to be reflected
        textNode.geometry.firstMaterial.writesToDepthBuffer = NO;
        
        // render last
        textNode.renderingOrder = 1;
    }
    
    return textNode;
}

- (SCNNode *) _addCode:(NSString *)string
{
    //initial x position
    float dx=0;
    
    //start with no emphasis
    BOOL emphasis = NO;
    
    //create a group to own the code
    SCNNode *codeNode = [SCNNode node];
    
    /*
     Automatically highlight the part of the code that are inside '#'
     */
    while ([string length] > 0) {
        //split the string at each occurence of '#'
        NSRange r = [string rangeOfString:@"#"];
        NSString *code = nil;
        if (r.length == 1) {
            code = [string substringToIndex:r.location];
            string = [string substringFromIndex:r.location+1];
        }
        else{
            code = string;
            string = nil;
        }
        
        //create a new node for this text
        SCNNode *subNode = [self _addText:code withType:ASCTextTypeCode level:emphasis];
        subNode.name = emphasis ? @"emphasis" : @"regular";
        
        //layout the text
        [codeNode addChildNode:subNode];
        subNode.position = SCNVector3Make(subNode.position.x+dx, subNode.position.y, subNode.position.z);
        
        //we use a fixed size font, so ues a simple multiplication to layout our text
        dx += (21.7 * [code length]) * subNode.scale.x;
        
        //alternate emphasis each time we find an occurence of '#'
        emphasis = !emphasis;
    }
    
    return codeNode;
}

- (SCNNode *) addText:(NSString *)string withType:(ASCTextType) type level:(NSUInteger)level
{
    SCNNode *textNode;
    
    // get the container for this text type
    SCNNode *parentNode = [self textBlockForType:type];
    
    /*update baseline: each time we add a new text we decrement the current y position for the next text */
    _currentBaseline-= [self lineHeightForTextType:type level:level];
    
    //automatically space out titles/subtitles and the other text
    if (type > ASCTextTypeSubTitle) {
        if(_previousType <= ASCTextTypeTitle){
            _currentBaseline -= 1.0;
        }
        if (_previousType <= ASCTextTypeSubTitle && type > ASCTextTypeSubTitle) {
            _currentBaseline -= 1.3;
        }
        else if (_previousType != type) {
            _currentBaseline -= 1.0;
        }
    }
    
    // type 'code' need special threatment (split and highlight part of the code)
    if (type == ASCTextTypeCode) {
        textNode = [self _addCode:string];
    }
    else{
        textNode = [self _addText:string withType:type level:level];
    }
    
    //add the new text to the parent node
    [parentNode addChildNode:textNode];
    
    //if "fadeIn" is set to yes, then animate the opacity to fade in
    if (self.fadeIn) {
        textNode.opacity = 0;
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:1.0];
        textNode.opacity = 1;
        [SCNTransaction commit];
    }
    
    //remember last text type to update the baseline correctly next time
    _previousType = type;
    
    //return the text node
    return textNode;
}

- (SCNNode *)setTitle:(NSString *)title {
    return [self addText:title withType:ASCTextTypeTitle level:0];
}

- (SCNNode *)setSubtitle:(NSString *)title {
    return [self addText:title withType:ASCTextTypeSubTitle level:0];
}

- (SCNNode *)setChapterTitle:(NSString *)title {
    return [self addText:title withType:ASCTextTypeChapter level:0];
}

- (SCNNode *)addText:(NSString *)text atLevel:(NSUInteger)level {
    return [self addText:text withType:ASCTextTypeBody level:level];
}

- (SCNNode *)addBullet:(NSString *)text atLevel:(NSUInteger)level {
    return [self addText:text withType:ASCTextTypeBullet level:level];
}

- (SCNNode *) addCode:(NSString *)string
{
    return [self addText:string withType:ASCTextTypeCode level:0];
}

#pragma mark -
#pragma mark - Animating text

#define PIVOT_X 16
#define FLIP_ANGLE M_PI_2
#define FLIP_DURATION 1.0

// simple fade out to remove the texts with the specified type
- (void)fadeOutTextType:(ASCTextType) type
{
    //get the node that owns the text with the specified type
    SCNNode *node = _subGroups[type];
    _subGroups[type] = nil;
    
    if (node) {
        //fade out
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:FLIP_DURATION];
        [SCNTransaction setCompletionBlock:^{
            //remove on completion
            [node removeFromParentNode];
        }];
        
        node.opacity = 0;
        
        [SCNTransaction commit];
        
        //restore baseline as it was before adding this text
        _currentBaseline = MAX(_currentBaseline, _baselinePerType[type]);
    }
}


// flip out to remove the texts with the specified type
- (void)flipOutTextType:(ASCTextType) type
{
    //get the node that owns the text with the specified type
    SCNNode *node = _subGroups[type];
    _subGroups[type] = nil;
    
    if (node) {
        //set the pivot at the left of the geometry and rotate
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0];
        node.position = SCNVector3Make(-PIVOT_X, 0, 0);
        node.pivot = CATransform3DMakeTranslation(-PIVOT_X, 0, 0);
        [SCNTransaction commit];
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:FLIP_DURATION];
        [SCNTransaction setCompletionBlock:^{
            //on compression remove the node
            [node removeFromParentNode];
        }];
        
        node.rotation = SCNVector4Make(0, 1, 0, FLIP_ANGLE);
        node.opacity = 0;
        
        [SCNTransaction commit];
        
        //restore baseline as it was before adding this text
        _currentBaseline = MAX(_currentBaseline, _baselinePerType[type]);
    }
}

// flip in to show the texts with the specified type
- (void)flipInTextType:(ASCTextType) type
{
    //get the node that owns the text with the specified type
    SCNNode *node = _subGroups[type];
    
    if (node) {
        //set the pivot at the left of the geometry and initial angle
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0];
        
        node.position = SCNVector3Make(-PIVOT_X, 0, 0);
        node.pivot = CATransform3DMakeTranslation(-PIVOT_X, 0, 0);
        node.opacity = 0;
        node.rotation = SCNVector4Make(0, 1, 0, -FLIP_ANGLE);
        
        [SCNTransaction commit];
        
        //rotate with an animation
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:FLIP_DURATION];
        
        node.rotation = SCNVector4Make(0, 1, 0, 0);
        node.opacity = 1;
        
        [SCNTransaction commit];
    }
}

#pragma mark -
#pragma mark Highlighting text

// highlight the bullet at the specified index
- (void)highlightBulletAtIndex:(NSUInteger) index
{
    SCNNode *node = _subGroups[ASCTextTypeBullet];
    
    /* the highlight is done changing the emission color
     white = regular text (highlighted)
     dark gray = dimmed text
     */
    
    if (node) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.75];
        
        //reset all
        for (SCNNode *child in node.childNodes) {
            child.geometry.firstMaterial.emission.contents = [NSColor whiteColor];
        }
        
        if (index != NSNotFound) {
            //unhighlight all but index
            NSUInteger i = 0;
            for (SCNNode *child in node.childNodes) {
                if (i!=index)
                    child.geometry.firstMaterial.emission.contents = [NSColor darkGrayColor];
                i++;
            }
        }
        
        [SCNTransaction commit];
    }
}

// highlight code. "range" specifies the lines of code to highlight
- (void)highlightCodeLinesInRange:(NSRange) range
{
    SCNNode *node = _subGroups[ASCTextTypeCode];
    
    //1) unhighlight all
    [node childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        child.geometry.firstMaterial.emission.contents = [self colorForTextType:ASCTextTypeCode level:0];
        return NO;
    }];
    
    //2) highlight text inside range
    NSArray *childs = node.childNodes;
    NSUInteger count = [childs count];
    for (NSUInteger index=range.location; index<count && index<range.location+range.length; index++) {
        SCNNode *line = childs[index];
        
        for (SCNNode *segment in line.childNodes) {
            if ([segment.name isEqualToString:@"emphasis"]) {
                segment.geometry.firstMaterial.emission.contents = [self colorForTextType:ASCTextTypeCode level:1];
            }
        }
    }
}

@end
