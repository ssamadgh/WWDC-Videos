/*
     File: ASCSlideTextManager.m
 Abstract: ASCSlideTextManager manages the layout of the different types of text presented in the slides.
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

#import "ASCSlideTextManager.h"
#import "ASCSlide.h"

static CGFloat const TEXT_SCALE = 0.02;
static CGFloat const TEXT_CHAMFER = 1;
static CGFloat const TEXT_DEPTH = 0.0;
static CGFloat const TEXT_FLATNESS = 0.4;

@implementation ASCSlideTextManager {
    // The containers for each type of text
    SCNNode *_subGroups[ASCTextTypeCount];
    
    ASCTextType _previousType;
    CGFloat _currentBaseline;
    float   _baselinePerType[ASCTextTypeCount];
}

- (id)init {
    if (self = [super init]) {
        self.textNode = [SCNNode node];
        _currentBaseline = 16;
    }
    
    return self;
}

- (NSColor *)colorForTextType:(ASCTextType)type level:(int)level {
    switch (type) {
        case ASCTextTypeSubtitle:
            return [NSColor colorWithDeviceRed:160/255.0 green:182/255.0 blue:203/255.0 alpha:1];
        case ASCTextTypeCode:
            return level == 0 ? [NSColor whiteColor] : [NSColor colorWithDeviceRed:242/255.0 green:173/255.0 blue:24/255.0 alpha:1];
        case ASCTextTypeBody:
            if (level == 2)
                return [NSColor colorWithDeviceRed:115/255.0 green:170/255.0 blue:230/255.0 alpha:1];
        default:
            return [NSColor whiteColor];
    }
}

- (CGFloat)extrusionDepthForTextType:(ASCTextType)type {
    return type == ASCTextTypeChapter ? 10.0 : TEXT_DEPTH;
}

- (CGFloat)fontSizeForTextType:(ASCTextType)type level:(NSUInteger)level {
    switch (type) {
        case ASCTextTypeTitle:
            return 88;
        case ASCTextTypeChapter:
            return 94;
        case ASCTextTypeCode:
            return 36;
        case ASCTextTypeSubtitle:
            return 64;
        case ASCTextTypeBody:
            return level == 0 ? 50 : 40;
        default:
            return 56;
    }
}

- (NSFont *)fontForTextType:(ASCTextType)type level:(NSUInteger)level {
    CGFloat fontSize = [self fontSizeForTextType:type level:level];
    
    switch (type) {
        case ASCTextTypeCode:
            return [NSFont fontWithName:@"Menlo" size:fontSize];
        case ASCTextTypeBullet:
            return [NSFont fontWithName:@"Myriad Set" size:fontSize] ?: [NSFont fontWithName:@"Avenir Medium" size:fontSize];
        case ASCTextTypeBody:
            if (level != 0)
                return [NSFont fontWithName:@"Myriad Set" size:fontSize] ?: [NSFont fontWithName:@"Avenir Medium" size:fontSize];
        default:
            return [NSFont fontWithName:@"Myriad Set Semibold" size:fontSize] ?: [NSFont fontWithName:@"Avenir Medium" size:fontSize];
    }
}

- (CGFloat)lineHeightForTextType:(ASCTextType)type level:(NSUInteger)level {
    switch (type) {
        case ASCTextTypeTitle:
            return 2.26;
        case ASCTextTypeChapter:
            return 3;
        case ASCTextTypeCode:
            return 1.22;
        case ASCTextTypeSubtitle:
            return 1.78;
        case ASCTextTypeBody:
            return level == 0 ? 1.2 : 1.0;
        default:
            return 1.65;
    }
}

- (SCNNode *)textContainerForType:(ASCTextType)type {
    if (type == ASCTextTypeChapter)
        return self.textNode.parentNode;
    
    if (_subGroups[type])
        return _subGroups[type];
    
    SCNNode *container = [SCNNode node];
    [self.textNode addChildNode:container];
    
    _subGroups[type] = container;
    _baselinePerType[type] = _currentBaseline;
    
    return container;
}

- (void)addEmptyLine {
    _currentBaseline -= 1.2;
}

- (SCNNode *)nodeWithText:(NSString *)string withType:(ASCTextType)type level:(NSUInteger)level {
    SCNNode *textNode = [SCNNode node];
    
    // Bullet
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
    
    // Text attributes
    float extrusion = [self extrusionDepthForTextType:type];
    SCNText *text = [SCNText textWithString:string extrusionDepth:extrusion];
    textNode.geometry = text;
    text.flatness = TEXT_FLATNESS;
    text.chamferRadius = extrusion == 0 ? 0 : TEXT_CHAMFER;
    text.font = [self fontForTextType:type level:level];
    
    // Layout
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    CGFloat leading = [layoutManager defaultLineHeightForFont:text.font];
    CGFloat descender = text.font.descender;
    NSUInteger newlineCount = [[text.string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] count];
    textNode.pivot = CATransform3DMakeTranslation(0, -descender + newlineCount * leading, 0);
    
    if (type == ASCTextTypeChapter) {
        SCNVector3 min, max;
        [textNode getBoundingBoxMin:&min max:&max];
        textNode.position = SCNVector3Make(-11, (-min.y + textNode.pivot.m42) * TEXT_SCALE, 7);
        textNode.scale = SCNVector3Make(TEXT_SCALE, TEXT_SCALE, TEXT_SCALE);
        textNode.rotation = SCNVector4Make(0, 1, 0, M_PI/270.0);
    }
    else {
        textNode.position = SCNVector3Make(-16, _currentBaseline, 0);
        textNode.scale = SCNVector3Make(TEXT_SCALE, TEXT_SCALE, TEXT_SCALE);
    }
    
    // Material
    if (type == ASCTextTypeChapter) {
        SCNMaterial *frontMaterial = [SCNMaterial material];
        SCNMaterial *sideMaterial = [SCNMaterial material];
        
        frontMaterial.emission.contents = [NSColor darkGrayColor];
        frontMaterial.diffuse.contents = [self colorForTextType:type level:level];
        sideMaterial.diffuse.contents = [NSColor lightGrayColor];
        textNode.geometry.materials = @[frontMaterial, frontMaterial, sideMaterial, frontMaterial, frontMaterial];
    }
    else {
        // Full white emissive material (visible even when there is no light)
        textNode.geometry.firstMaterial = [SCNMaterial material];
        textNode.geometry.firstMaterial.diffuse.contents = [NSColor blackColor];
        textNode.geometry.firstMaterial.emission.contents = [self colorForTextType:type level:level];
        
        // Don't write to the depth buffer because we don't want the text to be reflected
        textNode.geometry.firstMaterial.writesToDepthBuffer = NO;
        
        // Render last
        textNode.renderingOrder = 1;
    }
    
    return textNode;
}

- (SCNNode *)nodeWithCode:(NSString *)string {
    // Node hierarchy:
    // codeNode
    // |__ regularCodeNode
    // |__ emphasis-0 (can be highlighted separately)
    // |__ emphasis-1 (can be highlighted separately)
    // |__ emphasis-2 (can be highlighted separately)
    // |__ ...
    
    SCNNode *codeNode = [SCNNode node];
    
    NSUInteger chunk = 0;
    NSString *regularCode = @"";
    NSString *whitespacesCode = @"";
    
    // Automatically highlight the parts of the code that are delimited by '#'
    NSArray *components = [string componentsSeparatedByString:@"#"];
    
    for (NSUInteger i = 0; i < components.count; i++) {
        NSString *component = components[i];
        
        NSString *whitespaces = @"";
        for (NSUInteger j = 0; j < component.length; j++) {
            NSString *character = [component substringWithRange:NSMakeRange(j, 1)];
            if ([character isEqualToString:@"\n"]) {
                whitespaces = [whitespaces stringByAppendingString:@"\n"];
            } else {
                whitespaces = [whitespaces stringByAppendingString:@" "];
            }
        }
        
        if (i % 2) {
            SCNNode *emphasisedCodeNode = [self nodeWithText:[whitespacesCode stringByAppendingString:component] withType:ASCTextTypeCode level:1];
            emphasisedCodeNode.name = [NSString stringWithFormat:@"emphasis-%ld", chunk++];
            [codeNode addChildNode:emphasisedCodeNode];
            
            regularCode = [regularCode stringByAppendingString:whitespaces];
        } else {
            regularCode = [regularCode stringByAppendingString:component];
        }
        
        whitespacesCode = [whitespacesCode stringByAppendingString:whitespaces];
    }
    
    SCNNode *regularCodeNode = [self nodeWithText:regularCode withType:ASCTextTypeCode level:0];
    regularCodeNode.name = @"regular";
    [codeNode addChildNode:regularCodeNode];
    
    return codeNode;
}

- (SCNNode *)addText:(NSString *)string withType:(ASCTextType)type level:(NSUInteger)level {
    SCNNode *parentNode = [self textContainerForType:type];
    
    _currentBaseline -= [self lineHeightForTextType:type level:level];
    
    if (type > ASCTextTypeSubtitle) {
        if (_previousType <= ASCTextTypeTitle) {
            _currentBaseline -= 1.0;
        }
        if (_previousType <= ASCTextTypeSubtitle && type > ASCTextTypeSubtitle) {
            _currentBaseline -= 1.3;
        }
        else if (_previousType != type) {
            _currentBaseline -= 1.0;
        }
    }
    
    SCNNode *textNode = (type == ASCTextTypeCode) ? [self nodeWithCode:string] : [self nodeWithText:string withType:type level:level];
    [parentNode addChildNode:textNode];
    
    if (self.fadesIn) {
        textNode.opacity = 0;
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:1.0];
        {
            textNode.opacity = 1;
        }
        [SCNTransaction commit];
    }
    
    _previousType = type;
    
    return textNode;
}

#pragma mark - Public API

- (SCNNode *)setTitle:(NSString *)title {
    return [self addText:title withType:ASCTextTypeTitle level:0];
}

- (SCNNode *)setSubtitle:(NSString *)title {
    return [self addText:title withType:ASCTextTypeSubtitle level:0];
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

- (SCNNode *)addCode:(NSString *)string {
    return [self addText:string withType:ASCTextTypeCode level:0];
}

#pragma mark - Animations

static CGFloat const PIVOT_X = 16;
static CGFloat const FLIP_ANGLE = M_PI_2;
static CGFloat const FLIP_DURATION = 1.0;

// Animate (fade out) to remove the text of specified type
- (void)fadeOutTextOfType:(ASCTextType)type {
    SCNNode *node = _subGroups[type];
    _subGroups[type] = nil;
    if (node) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:FLIP_DURATION];
        [SCNTransaction setCompletionBlock:^{
            [node removeFromParentNode];
        }];
        {
            node.opacity = 0;
        }
        [SCNTransaction commit];
        
        // Reset the baseline to what it was before adding this text
        _currentBaseline = MAX(_currentBaseline, _baselinePerType[type]);
    }
}

// Animate (flip) to remove the text of specified type
- (void)flipOutTextOfType:(ASCTextType)type {
    SCNNode *node = _subGroups[type];
    _subGroups[type] = nil;
    if (node) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0];
        {
            node.position = SCNVector3Make(-PIVOT_X, 0, 0);
            node.pivot = CATransform3DMakeTranslation(-PIVOT_X, 0, 0);
        }
        [SCNTransaction commit];
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:FLIP_DURATION];
        [SCNTransaction setCompletionBlock:^{
            [node removeFromParentNode];
        }];
        {
            node.rotation = SCNVector4Make(0, 1, 0, FLIP_ANGLE);
            node.opacity = 0;
        }
        [SCNTransaction commit];
        
        // Reset the baseline to what it was before adding this text
        _currentBaseline = MAX(_currentBaseline, _baselinePerType[type]);
    }
}

// Animate to reveal the text of specified type
- (void)flipInTextOfType:(ASCTextType)type {
    SCNNode *node = _subGroups[type];
    if (node) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0];
        {
            node.position = SCNVector3Make(-PIVOT_X, 0, 0);
            node.pivot = CATransform3DMakeTranslation(-PIVOT_X, 0, 0);
            node.rotation = SCNVector4Make(0, 1, 0, -FLIP_ANGLE);
            node.opacity = 0;
        }
        [SCNTransaction commit];
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:FLIP_DURATION];
        {
            node.rotation = SCNVector4Make(0, 1, 0, 0);
            node.opacity = 1;
        }
        [SCNTransaction commit];
    }
}

#pragma mark - Highlighting text

- (void)highlightBulletAtIndex:(NSUInteger)index {
    // Highlight is done by changing the emission color
    SCNNode *node = _subGroups[ASCTextTypeBullet];
    if (node) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.75];
        {
            // Reset all
            for (SCNNode *child in node.childNodes) {
                child.geometry.firstMaterial.emission.contents = [NSColor whiteColor];
            }
            
            // Unhighlight everything but index
            if (index != NSNotFound) {
                NSUInteger i = 0;
                for (SCNNode *child in node.childNodes) {
                    if (i != index)
                        child.geometry.firstMaterial.emission.contents = [NSColor darkGrayColor];
                    i++;
                }
            }
        }
        [SCNTransaction commit];
    }
}

- (void)highlightCodeChunks:(NSArray *)chunks {
    SCNNode *node = _subGroups[ASCTextTypeCode];
    
    // Unhighlight everything
    [node childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        child.geometry.firstMaterial.emission.contents = [self colorForTextType:ASCTextTypeCode level:0];
        return NO;
    }];
    
    // Highlight text inside range
    for (NSNumber *i in chunks) {
        SCNNode *chunkNode = [node childNodeWithName:[NSString stringWithFormat:@"emphasis-%ld", [i unsignedIntegerValue]] recursively:YES];
        chunkNode.geometry.firstMaterial.emission.contents = [self colorForTextType:ASCTextTypeCode level:1];
    }
}

@end
