/*
 
     File: AXEAppDelegate.m
 Abstract: Application delegate.
  Version: 2.0
 
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

#import "AXEAppDelegate.h"
#import "AXEViewController.h"

#define IsDemoVersion           0

#define AXE_CONFIGURATION_NAME  @"Configuration"
#define AXE_CONTROLLER_KEY      @"Controller"
#define AXE_CLASS_KEY           @"Class"
#define AXE_TITLE_KEY           @"Title"
#define AXE_NIB_KEY             @"Nib"
#define AXE_HIDE_KEY            @"Hide"


#if IsDemoVersion
#define AXE_CONTROLLERS_KEY     @"DemoControllers" 
#else
#define AXE_CONTROLLERS_KEY     @"Controllers"
#endif

@implementation AXEAppDelegate

@synthesize viewControllers = _viewControllers;
@synthesize demoViewArea = mDemoViewArea;

- (void)awakeFromNib
{
    [self loadConfiguration];
    [super awakeFromNib];
    [[self window] setAcceptsMouseMovedEvents:YES];
    [[self window] setIgnoresMouseEvents:NO];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    [_sidebarOutlineView reloadData];
    [_sidebarOutlineView setFloatsGroupRows:NO];
    [_sidebarOutlineView expandItem:nil expandChildren:YES];
    [_sidebarOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
}

- (void)unloadCurrentDemoView
{
    for ( NSView *subview in [mDemoViewArea subviews] )
    {
        [subview removeFromSuperview];
    }
}

- (void)showViewWithController:(AXEViewController *)controller
{
    if ( [controller isEqualTo:mCurrentController] )
    {
        return;
    }
    
    [self unloadCurrentDemoView];
    
    NSView *view = [controller view];
    if ( view != nil )
    {
        [[self demoViewArea] addSubview:view];
    }
    mCurrentController = controller;
    
    [[self window] recalculateKeyViewLoop];
}

- (void)showViewWithControllerInfo:(NSMutableDictionary *)controllerInfo
{
    AXEViewController *controller = [controllerInfo objectForKey:AXE_CONTROLLER_KEY];
    
    if ( controller == nil )
    {
        NSString *className = [controllerInfo objectForKey:AXE_CLASS_KEY];
        Class class = NSClassFromString(className);
        controller = (AXEViewController *)[[class alloc] init];
        
        if ( controller != nil )
        {
            [controllerInfo setObject:controller forKey:AXE_CONTROLLER_KEY];
        }
    }
    [self showViewWithController:controller];
}

- (void)loadConfiguration
{
    if ( mConfigLoaded )
    {
        return;
    }
    mConfigLoaded = YES;
    NSString *configPath = [[NSBundle mainBundle] pathForResource:AXE_CONFIGURATION_NAME ofType:@"plist"];
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:configPath];
    NSDictionary *categories = [config objectForKey:AXE_CONTROLLERS_KEY];

    _categories = [[NSArray alloc] initWithArray:[categories allKeys]];
    _viewControllers = [[NSMutableDictionary alloc] init];
    
    for ( NSString *categoryKey in categories )
    {
        NSArray *allControllers = [categories objectForKey:categoryKey];
        NSMutableArray *displayedControllers = [NSMutableArray array];
        
        for ( NSDictionary *controller in allControllers )
        {
            if ( [[controller objectForKey:AXE_HIDE_KEY] boolValue] )
            {
                continue;
            }
            
            NSString *title = [controller objectForKey:AXE_TITLE_KEY];

            NSString *className = [controller objectForKey:AXE_CLASS_KEY];
            if ( [className length] > 0 && [title length] > 0 )
            {
                Class class = NSClassFromString(className);
                if ( class != nil )
                {
                    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:title, AXE_TITLE_KEY, className, AXE_CLASS_KEY, nil];
                    [displayedControllers addObject:entry];
                }
            }
        }
        
        [_viewControllers setObject:displayedControllers forKey:categoryKey];
    }
}

- (BOOL)isViewControllerItem:(id)item
{
    return [item isKindOfClass:[NSDictionary class]];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    if ( [_sidebarOutlineView selectedRow] != -1 )
    {
        id item = [_sidebarOutlineView itemAtRow:[_sidebarOutlineView selectedRow]];
        if ( [_sidebarOutlineView parentForItem:item] != nil )
        {
            [self showViewWithControllerInfo:item];
        }
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    return [_categories containsObject:item];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return [[self _childrenForItem:item] count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    return [[self _childrenForItem:item] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return [self isViewControllerItem:item] ? NO : YES;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    id view = nil;
    if ( [self isViewControllerItem:item] )
    {
        NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"MainCell" owner:self];
        cellView.textField.stringValue = [item objectForKey:AXE_TITLE_KEY];
        view = cellView;
    }
    else if ( [item isKindOfClass:[NSString class]] )
    {
        NSTextField *header = [outlineView makeViewWithIdentifier:@"Header" owner:self];
        [header setStringValue:item];
        view = header;
    }
    return view;
}


- (NSArray *)_childrenForItem:(id)item
{
    NSArray *children = nil;
    
    if ( item == nil )
    {
        children = _categories;
    }
    else if ( [item isKindOfClass:[NSString class]] )
    {
        children = [_viewControllers objectForKey:item];
    }
    
    return children;
}


@end
