/*
     File: QuartzBlending.m
 Abstract: Demonstrates Quartz Blend modes (QuartzBlendingView).
  Version: 2.5
 
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
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import "QuartzBlending.h"


@interface QuartzBlendingView()
@end

@implementation QuartzBlendingView

@synthesize sourceColor, destinationColor, blendMode;

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self != nil)
	{
		sourceColor = [UIColor whiteColor];
		destinationColor = [UIColor blackColor];
		blendMode = kCGBlendModeNormal;
	}
	return self;
}

-(void)dealloc
{
	[sourceColor release];
	[destinationColor release];
	[super dealloc];
}

-(void)setSourceColor:(UIColor*)src
{
	if(src != sourceColor)
	{
		[sourceColor release];
		sourceColor = [src retain];
		[self setNeedsDisplay];
	}
}

-(void)setDestinationColor:(UIColor*)dest
{
	if(dest != destinationColor)
	{
		[destinationColor release];
		destinationColor = [dest retain];
		[self setNeedsDisplay];
	}
}

-(void)setBlendMode:(CGBlendMode)mode
{
	if(mode != blendMode)
	{
		blendMode = mode;
		[self setNeedsDisplay];
	}
}

-(void)drawInContext:(CGContextRef)context
{
	// Start with a background whose color we don't use in the demo
	CGContextSetGrayFillColor(context, 0.2, 1.0);
	CGContextFillRect(context, self.bounds);
	// We want to just lay down the background without any blending so we use the Copy mode rather than Normal
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	// Draw a rect with the "background" color - this is the "Destination" for the blending formulas
	CGContextSetFillColorWithColor(context, destinationColor.CGColor);
	CGContextFillRect(context, CGRectMake(110.0, 20.0, 100.0, 100.0));
	// Set up our blend mode
	CGContextSetBlendMode(context, blendMode);
	// And draw a rect with the "foreground" color - this is the "Source" for the blending formulas
	CGContextSetFillColorWithColor(context, sourceColor.CGColor);
	CGContextFillRect(context, CGRectMake(60.0, 45.0, 200.0, 50.0));
}

@end
