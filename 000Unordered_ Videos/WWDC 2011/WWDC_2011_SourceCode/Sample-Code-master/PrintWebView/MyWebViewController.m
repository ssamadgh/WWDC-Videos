
/*
     File: MyWebViewController.m
 Abstract: The view controller for hosting the UIWebView feature of this sample.
 
  Version: 1.3
 
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
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "MyWebViewController.h"
#import "MyPrintPageRenderer.h"
#import "Constants.h"


@interface MyWebViewController ()

@property (nonatomic, retain) UIWebView *myWebView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIBarButtonItem *printButton;
@property (nonatomic, retain) UITextField *urlField;

@end




@implementation MyWebViewController

@synthesize myWebView;
@synthesize toolbar;
@synthesize printButton;
@synthesize urlField;


#pragma mark -
#pragma mark Toolbar

- (void)setupToolbarItems
{
  // Create a flexible space button to push the print button to the far right.
  UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
  self.printButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(printWebPage:)]autorelease];
  self.toolbar.items = [NSArray arrayWithObjects: flexibleSpace, printButton, nil];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc
{
  self.myWebView.delegate = nil;
  [myWebView  release];
  [toolbar release];
  [urlField release];
  [printButton release];
  [super dealloc];
}

#pragma mark -
#pragma mark View Loading and Unloading

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = NSLocalizedString(@"WebTitle", @"Title for Web Page Window");

  CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
  webFrame.origin.y += kTopMargin + 5.0;	// leave from the URL input field and its label
					  // leave room for toolbar
  webFrame.size.height -= 40.0 + kToolbarHeight;

  self.myWebView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
  self.myWebView.backgroundColor = [UIColor whiteColor];
  self.myWebView.scalesPageToFit = YES;
  self.myWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  self.myWebView.delegate = self;
  [self.view addSubview: self.myWebView];
  
  // Space the text field slightly further away from the top of the view on the iPad; it looks nicer.
  CGFloat textFieldHeightOffset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2*kTweenMargin : kTweenMargin;

  CGRect textFieldFrame = CGRectMake(kLeftMargin, textFieldHeightOffset, self.view.bounds.size.width - (kLeftMargin * 2.0), kTextFieldHeight);
  urlField = [[UITextField alloc] initWithFrame:textFieldFrame];
  urlField.borderStyle = UITextBorderStyleBezel;
  urlField.textColor = [UIColor blackColor];
  urlField.delegate = self;
  urlField.placeholder = @"<enter a complete URL>";
  urlField.text = @"http://www.apple.com";
  urlField.backgroundColor = [UIColor whiteColor];
  urlField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  urlField.returnKeyType = UIReturnKeyGo;
  urlField.keyboardType = UIKeyboardTypeURL;	// this makes the keyboard more friendly for typing URLs
  urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;	// don't capitalize
  urlField.autocorrectionType = UITextAutocorrectionTypeNo;	// we don't like autocompletion while typing
  urlField.clearButtonMode = UITextFieldViewModeAlways;
  [urlField setAccessibilityLabel:NSLocalizedString(@"URLTextField", @"Accessiblity Label for Text Field")];
  [self.view addSubview:urlField];
  [urlField release];

  if([UIPrintInteractionController isPrintingAvailable]){
    CGRect toolbarFrame = CGRectMake(webFrame.origin.x, webFrame.origin.y + webFrame.size.height, webFrame.size.width, kToolbarHeight);
    self.toolbar = [[[UIToolbar alloc] initWithFrame:toolbarFrame] autorelease];
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    // Allow the toolbar location and size to adjust properly as the orientation changes. 
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self setupToolbarItems];
    [self.view addSubview:self.toolbar];
  }

  [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.apple.com/"]]];
}

/*
 Called after the view controller's view is released and set to nil.
 For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
 So release any properties that are loaded in viewDidLoad or can be recreated lazily.
 */
- (void)viewDidUnload
{
  // Release and set to nil.
  self.myWebView = nil;
  self.toolbar = nil;
  self.printButton = nil;
  self.urlField = nil;

  [super viewDidUnload];
}


#pragma mark -
#pragma mark UIViewController delegate methods

- (void)viewWillAppear:(BOOL)animated
{
  self.myWebView.delegate = self;	// Setup the delegate as the web view is shown.
}


- (void)viewWillDisappear:(BOOL)animated
{
  [self.myWebView stopLoading];	// In case the web view is still loading its content.
  self.myWebView.delegate = nil;	// Disconnect the delegate as the webview is hidden.
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // We support rotation in this view controller.
  return YES;
}

// This helps dismiss the keyboard when the "Done" button is clicked.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[textField text]]]];
  return YES;
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
  // Starting the load, show the activity indicator in the status bar.
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  // Finished loading, hide the activity indicator in the status bar.
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  NSURL *url = [webView.request URL];
  urlField.text = [url absoluteString];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  NSURL *url = [request URL];
  urlField.text = [url absoluteString];
  return YES;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  // Load error, hide the activity indicator in the status bar.
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

  // Report the error inside the webview.
  NSString* errorString = [NSString stringWithFormat:
						   @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
						   error.localizedDescription];
  [self.myWebView loadHTMLString:errorString baseURL:nil];
}


#pragma mark -
#pragma mark Printing


- (void)printWebPage:(id)sender
{
  UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
  if(!controller){
    NSLog(@"Couldn't get shared UIPrintInteractionController!");
    return;
  }
  
  UIPrintInteractionCompletionHandler completionHandler = 
			^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
    if(!completed && error){
	NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);	
    }
  };
  
  
  // Obtain a printInfo so that we can set our printing defaults.
  UIPrintInfo *printInfo = [UIPrintInfo printInfo];
  // This application produces General content that contains color.
  printInfo.outputType = UIPrintInfoOutputGeneral;
  // We'll use the URL as the job name.
  printInfo.jobName = [urlField text];
  // Set duplex so that it is available if the printer supports it. We
  // are performing portrait printing so we want to duplex along the long edge.
  printInfo.duplex = UIPrintInfoDuplexLongEdge;
  // Use this printInfo for this print job.
  controller.printInfo = printInfo;

  // Be sure the page range controls are present for documents of > 1 page.
  controller.showsPageRange = YES;

  // This code uses a custom UIPrintPageRenderer so that it can draw a header and footer.
  MyPrintPageRenderer *myRenderer = [[MyPrintPageRenderer alloc] init];
  // The MyPrintPageRenderer class provides a jobtitle that it will label each page with.
  myRenderer.jobTitle = printInfo.jobName;
  // To draw the content of each page, a UIViewPrintFormatter is used.
  UIViewPrintFormatter *viewFormatter = [self.myWebView viewPrintFormatter];

#if SIMPLE_LAYOUT
  /*
    For the simple layout we simply set the header and footer height to the height of the
    text box containing the text content, plus some padding.

    To do a layout that takes into account the paper size, we need to do that 
    at a point where we know that size. The numberOfPages method of the UIPrintPageRenderer 
    gets the paper size and can perform any calculations related to deciding header and
    footer size based on the paper size. We'll do that when we aren't doing the simple 
    layout.
  */
  UIFont *font = [UIFont fontWithName:@"Helvetica" size:HEADER_FOOTER_TEXT_HEIGHT]; 
  CGSize titleSize = [myRenderer.jobTitle sizeWithFont:font];
  myRenderer.headerHeight = myRenderer.footerHeight = titleSize.height + HEADER_FOOTER_MARGIN_PADDING;
#endif
  [myRenderer addPrintFormatter:viewFormatter startingAtPageAtIndex:0];
  // Set our custom renderer as the printPageRenderer for the print job.
  controller.printPageRenderer = myRenderer;
  [myRenderer release];
  
  /*
   The method we use presenting the printing UI depends on the type of UI idiom that is currently executing. Once we invoke one of these methods to present the printing UI, our application's direct involvement in printing is complete. Our custom printPageRenderer will have its methods invoked at the appropriate time by UIKit.
   */
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    [controller presentFromBarButtonItem:printButton animated:YES completionHandler:completionHandler];  // iPad
  else
    [controller presentAnimated:YES completionHandler:completionHandler];  // iPhone
  
}


@end

