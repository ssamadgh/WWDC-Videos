/*
     File: APLPrivacyClassesTableViewController.m
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

#import "APLPrivacyClassesTableViewController.h"

@implementation APLPrivacyClassesTableViewController

#pragma mark - View lifecycle management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an array with all our services.
    self.serviceArray = @[kDataClassLocation, kDataClassCalendars, kDataClassContacts, kDataClassPhotos, kDataClassReminders, kDataClassMicrophone, kDataClassBluetooth, kDataClassFacebook, kDataClassTwitter, kDataClassSinaWeibo, kDataClassTencentWeibo, kDataClassAdvertising];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    APLPrivacyDetailViewController *viewController = ((APLPrivacyDetailViewController *)segue.destinationViewController);
    
    NSString *serviceString = [self.serviceArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    
    [viewController setTitle:serviceString];
    
    if([serviceString isEqualToString:kDataClassLocation]) {
        [viewController setCheckBlock:^ {
            [self checkLocationServicesAuthorizationStatus];
        }];
        [viewController setRequestBlock:^{
            [self requestLocationServicesAuthorization];
        }];
    }
    else if([serviceString isEqualToString:kDataClassContacts]) {
        [viewController setCheckBlock:^ {
            [self checkAddressBookAccess];
        }];
        [viewController setRequestBlock:^{
            [self requestAddressBookAccess];
        }];
    }
    else if([serviceString isEqualToString:kDataClassCalendars]) {
        [viewController setCheckBlock:^ {
            [self checkEventStoreAccessForType:EKEntityTypeEvent];
        }];
        [viewController setRequestBlock:^{
            [self requestEventStoreAccessWithType:EKEntityTypeEvent];
        }];
    }
    else if([serviceString isEqualToString:kDataClassReminders]) {
        [viewController setCheckBlock:^ {
            [self checkEventStoreAccessForType:EKEntityTypeReminder];
        }];
        [viewController setRequestBlock:^{
            [self requestEventStoreAccessWithType:EKEntityTypeReminder];
        }];
    }
    else if([serviceString isEqualToString:kDataClassPhotos]) {
        [viewController setCheckBlock:^ {
            [self checkPhotosAuthorizationStatus];
        }];
        [viewController setRequestBlock:^{
            [self requestPhotosAccess:NO];
            [self requestPhotosAccess:YES];
        }];
    }
    else if([serviceString isEqualToString:kDataClassMicrophone]) {
        [viewController setCheckBlock:nil];
        [viewController setRequestBlock:^{
            [self requestMicrophoneAccess:YES];
            [self requestMicrophoneAccess:NO];
        }];
    }
    else if([serviceString isEqualToString:kDataClassBluetooth]) {
        [viewController setCheckBlock:^{
            [self checkBluetoothAccess];
        }];
        [viewController setRequestBlock:^{
            [self requestBluetoothAccess];
        }];
    }
    else if([serviceString isEqualToString:kDataClassFacebook]) {
        [viewController setCheckBlock:^{
            [self checkSocialAccountAuthorizationStatus:ACAccountTypeIdentifierFacebook];
        }];
        [viewController setRequestBlock:^{
            [self requestFacebookAccess];
        }];
    }
    else if([serviceString isEqualToString:kDataClassTwitter]) {
        [viewController setCheckBlock:^{
            [self checkSocialAccountAuthorizationStatus:ACAccountTypeIdentifierTwitter];
        }];
        [viewController setRequestBlock:^{
            [self requestTwitterAccess];
        }];
    }
    else if([serviceString isEqualToString:kDataClassSinaWeibo]) {
        [viewController setCheckBlock:^{
            [self checkSocialAccountAuthorizationStatus:ACAccountTypeIdentifierSinaWeibo];
        }];
        [viewController setRequestBlock:^{
            [self requestSinaWeiboAccess];
        }];
    }
    else if([serviceString isEqualToString:kDataClassTencentWeibo]) {
        [viewController setCheckBlock:^{
            [self checkSocialAccountAuthorizationStatus:ACAccountTypeIdentifierTencentWeibo];
        }];
        [viewController setRequestBlock:^{
            [self requestTencentWeiboAccess];
        }];
    }
    else if([serviceString isEqualToString:kDataClassAdvertising]) {
        [viewController setCheckBlock:^{
            [self advertisingIdentifierStatus];
        }];
        [viewController setRequestBlock:nil];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.serviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
    [[cell textLabel] setText:[self.serviceArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"serviceSegue" sender:self];
}

- (void)dealloc {
    if(_addressBook) {
        ABAddressBookUnregisterExternalChangeCallback(_addressBook, handleAddressBookChange, (__bridge void *)(self));
        CFRelease(_addressBook);
    }
    
}

#pragma mark - Location methods

- (void)checkLocationServicesAuthorizationStatus {
    /*
     We can ask the location services manager ahead of time what the authorization status is for our bundle and take the appropriate action.
     */
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self alertViewWithDataClass:Location status:NSLocalizedString(@"not determined", @"")];
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        [self alertViewWithDataClass:Location status:NSLocalizedString(@"restricted", @"")];
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self alertViewWithDataClass:Location status:NSLocalizedString(@"denied", @"")];
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [self alertViewWithDataClass:Location status:NSLocalizedString(@"granted", @"")];
    }
}

- (void)requestLocationServicesAuthorization {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    
    /*
     When the application requests to start receiving location updates that is when the user is presented with a consent dialog.
     */
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationMangerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // Handle the failure...
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // Do something with the new location the application just received...
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    /*
     The delegate function will be called when the permission status changes the application should then attempt to handle the change appropriately by changing UI or setting up or tearing down data structures.
     */
    if(status == kCLAuthorizationStatusNotDetermined) {
        [self alertViewWithDataClass:Location status:NSLocalizedString(@"not determined", @"")];
    }
    else if(status == kCLAuthorizationStatusRestricted) {
        [self alertViewWithDataClass:Location status:NSLocalizedString(@"restricted", @"")];
    }
    else if(status == kCLAuthorizationStatusDenied) {
        [self alertViewWithDataClass:Location status:NSLocalizedString(@"denied", @"")];
    }
    else if(status == kCLAuthorizationStatusAuthorized) {
        [self alertViewWithDataClass:Location status:NSLocalizedString(@"granted", @"")];
    }
}

#pragma mark - Contacts methods

- (void)checkAddressBookAccess {
    /*
     We can ask the address book ahead of time what the authorization status is for our bundle and take the appropriate action.
     */
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if(status == kABAuthorizationStatusNotDetermined) {
        [self alertViewWithDataClass:Contacts status:NSLocalizedString(@"not determined", @"")];
    }
    else if(status == kABAuthorizationStatusRestricted) {
        [self alertViewWithDataClass:Contacts status:NSLocalizedString(@"restricted", @"")];
    }
    else if(status == kABAuthorizationStatusDenied) {
        [self alertViewWithDataClass:Contacts status:NSLocalizedString(@"denied", @"")];
    }
    else if(status == kABAuthorizationStatusAuthorized) {
        [self alertViewWithDataClass:Contacts status:NSLocalizedString(@"granted", @"")];
    }
}

void handleAddressBookChange(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    // do something with changed addres book data...
}

- (void)requestAddressBookAccess {
    self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if(self.addressBook) {
        /*
         Register for a callback if the addressbook data changes this is important to be notified of new data when the user grants access to the contacts. the application should also be able to handle a nil object being returned as well if the user denies access to the address book.
         */
        ABAddressBookRegisterExternalChangeCallback(self.addressBook, handleAddressBookChange, (__bridge void *)(self));
        
        /*
         When the application requests to receive address book data that is when the user is presented with a consent dialog.
         */
        ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertViewWithDataClass:Contacts status:(granted) ? NSLocalizedString(@"granted", @"") : NSLocalizedString(@"denied", @"")];
            });
        });
    }
}

#pragma mark - EventStore methods

- (void)checkEventStoreAccessForType:(EKEntityType)type {
    /*
     We can ask the event store ahead of time what the authorization status is for our bundle and take the appropriate action.
     */
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:type];
    if(status == EKAuthorizationStatusNotDetermined) {
        [self alertViewWithDataClass:((type == EKEntityTypeEvent) ? Calendars : Reminders) status:NSLocalizedString(@"not determined", @"")];
    }
    else if(status == EKAuthorizationStatusRestricted) {
        [self alertViewWithDataClass:((type == EKEntityTypeEvent) ? Calendars : Reminders) status:NSLocalizedString(@"restricted", @"")];
    }
    else if(status == EKAuthorizationStatusDenied) {
        [self alertViewWithDataClass:((type == EKEntityTypeEvent) ? Calendars : Reminders) status:NSLocalizedString(@"denied", @"")];
    }
    else if(status == EKAuthorizationStatusAuthorized) {
        [self alertViewWithDataClass:((type == EKEntityTypeEvent) ? Calendars : Reminders) status:NSLocalizedString(@"granted", @"")];
    }
}

- (void)requestEventStoreAccessWithType:(EKEntityType)type {
    if(!self.eventStore) {
        self.eventStore = [[EKEventStore alloc] init];
    }
    
    /*
     When the application requests to receive event store data that is when the user is presented with a consent dialog.
     */
    [self.eventStore requestAccessToEntityType:type completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertViewWithDataClass:((type == EKEntityTypeEvent) ? Calendars : Reminders) status:(granted) ? NSLocalizedString(@"granted", @"") : NSLocalizedString(@"denied", @"")];
            
            // Do something with the access to eventstore...
        });
    }];
}

#pragma mark - Photos methods

- (void)checkPhotosAuthorizationStatus {
    /*
     We can ask the asset library ahead of time what the authorization status is for our bundle and take the appropriate action.
     */
    if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
        [self alertViewWithDataClass:Photos status:NSLocalizedString(@"not determined", @"")];
    }
    else if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted) {
        [self alertViewWithDataClass:Photos status:NSLocalizedString(@"restricted", @"")];
    }
    else if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
        [self alertViewWithDataClass:Photos status:NSLocalizedString(@"denied", @"")];
    }
    else if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        [self alertViewWithDataClass:Photos status:NSLocalizedString(@"granted", @"")];
    }
}

- (void)requestPhotosAccess:(BOOL)useImagePicker {
    // Consent alerts can be triggered either by using UIImagePickerController or ALAssetLibrary.
    if(useImagePicker) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker setDelegate:self];
        
        /*
         Upon presenting the picker, consent will be required from the user if the user previously denied access to the asset library, an "access denied" lock screen will be presented to the user to remind them of this choice.
         */
        [self presentViewController:picker animated:YES completion:nil];
        picker = nil;
    }
    else {
        if(!self.assetLibrary) {
            self.assetLibrary = [[ALAssetsLibrary alloc] init];
        }
        
        /*
         Enumerating assets or groups of assets in the library will present a consent dialog to the user.
         */
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // ...do something with the requested assets
        } failureBlock:^(NSError *error) {
            // ...handle failure
        }];
    }
}

#pragma mark - Microphone methods

- (void)requestMicrophoneAccess:(BOOL)usePermissionAPI {
    AVAudioSession *audioSession = [[AVAudioSession alloc] init];
    if(!usePermissionAPI) {
        // Setting the category of the audio session triggers the consent alert.
        NSError *error;
        [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
        
        /*
         Do something with the audio session data...
         Note that the application will receive zeros (silence) in the audio session until the user approves access to the microphone.
         */
    }
    else {
        /*
         Because this method is synchronous, it is being wrapped in a dispatch block to avoid blocking the main thread.
         */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            /*
             The requestRecordPermission API allows an application to request permission in advance of needing recording permission.  when the call returns, audio data will be available if the user approved the request.
             */
            BOOL granted = [audioSession requestRecordPermission];
            [self alertViewWithDataClass:Microphone status:(granted) ? NSLocalizedString(@"granted", @"") : NSLocalizedString(@"denied", @"")];
            
            // do something with the audio session or handle permission failures...
        });
    }
}

#pragma mark - Bluetooth methods

- (void)checkBluetoothAccess {
    if(!self.cbManager) {
        self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    /*
     We can ask the bluetooth manager ahead of time what the authorization status is for our bundle and take the appropriate action.
     */
    CBCentralManagerState state = [self.cbManager state];
    if(state == CBCentralManagerStateUnknown) {
        [self alertViewWithDataClass:Bluetooth status:NSLocalizedString(@"unknown", @"")];
    }
    else if(state == CBCentralManagerStateUnauthorized) {
        [self alertViewWithDataClass:Bluetooth status:NSLocalizedString(@"denied", @"")];
    }
    else {
        [self alertViewWithDataClass:Bluetooth status:NSLocalizedString(@"granted", @"")];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    /*
     Whe delegate method will be called when the permission status changes the application should then attempt to handle the change appropriately by changing UI or setting up or tearing down data structures.
     */
}

- (void)requestBluetoothAccess {
    if(!self.cbManager) {
        self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    /*
     When the application requests to start scanning for bluetooth devices that is when the user is presented with a consent dialog.
     */
    [self.cbManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // Handle the discovered bluetooth devices...
}

#pragma mark - Social methods

- (void)checkSocialAccountAuthorizationStatus:(NSString *)accountTypeIndentifier {
    if(!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    
    /*
     We can ask each social account type ahead of time what the authorization status is for our bundle and take the appropriate action.
     */
    ACAccountType *socialAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:accountTypeIndentifier];
    
    DataClass class;
    if([accountTypeIndentifier isEqualToString:ACAccountTypeIdentifierFacebook]) {
        class = Facebook;
    }
    else if([accountTypeIndentifier isEqualToString:ACAccountTypeIdentifierTwitter]) {
        class = Twitter;
    }
    else if([accountTypeIndentifier isEqualToString:ACAccountTypeIdentifierSinaWeibo]) {
        class = SinaWeibo;
    }
    else {
        class = TencentWeibo;
    }
    [self alertViewWithDataClass:class status:([socialAccount accessGranted]) ? NSLocalizedString(@"granted", @"") : NSLocalizedString(@"denied", @"")];
}

#pragma mark - Facebook

- (void)requestFacebookAccess {
    if(!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    ACAccountType *facebookAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // When requesting access to the account is when the user will be prompted for consent.
    NSDictionary *options = @{ ACFacebookAppIdKey: @"MY_CODE",
                               ACFacebookPermissionsKey: @[@"email", @"user_about_me"],
                               ACFacebookAudienceKey: ACFacebookAudienceFriends };
    [self.accountStore requestAccessToAccountsWithType:facebookAccount options:options completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertViewWithDataClass:Facebook status:(granted) ? NSLocalizedString(@"granted", @"") : NSLocalizedString(@"denied", @"")];
            // do something with account access...
        });
    }];
}

#pragma mark - Twitter

- (void)requestTwitterAccess {
    if(!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    
    ACAccountType *twitterAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // When requesting access to the account is when the user will be prompted for consent.
    [self.accountStore requestAccessToAccountsWithType:twitterAccount options:nil completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertViewWithDataClass:Twitter status:(granted) ? NSLocalizedString(@"granted", @"") : NSLocalizedString(@"denied", @"")];
            // do something with account access...
        });
    }];
}

#pragma mark - SinaWeibo methods

- (void)requestSinaWeiboAccess {
    if(!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    
    ACAccountType *sinaWeiboAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
    
    // When requesting access to the account is when the user will be prompted for consent.
    [self.accountStore requestAccessToAccountsWithType:sinaWeiboAccount options:nil completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertViewWithDataClass:SinaWeibo status:(granted) ? NSLocalizedString(@"granted", @"") : NSLocalizedString(@"denied", @"")];
            // do something with account access...
        });
    }];
}

#pragma mark - TencentWeibo methods

- (void)requestTencentWeiboAccess {
    if(!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    
    ACAccountType *tencentWeiboAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTencentWeibo];
    
    // When requesting access to the account is when the user will be prompted for consent.
    [self.accountStore requestAccessToAccountsWithType:tencentWeiboAccount options:nil completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertViewWithDataClass:TencentWeibo status:(granted) ? NSLocalizedString(@"granted", @"") : NSLocalizedString(@"denied", @"")];
            // do something with account access...
        });
    }];
}

#pragma mark - Advertising

- (void)advertisingIdentifierStatus {
    /*
     It is required to check the value of the property isAdvertisingTrackingEnabled before using the advertising identifier.  if the value is NO, then identifier can only be used for the purposes enumerated in the program license agreement note that the advertising ID can be controlled by restrictions just like the rest of the privacy data classes.
     Applications should not cache the advertising ID as it can be changed via the reset button in Settings.
     */
    [self alertViewWithDataClass:Advertising status:([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) ? NSLocalizedString(@"granted", @"") : NSLocalizedString(@"denied", @"")];
}

#pragma mark - Helper methods

- (void)alertViewWithDataClass:(DataClass)class status:(NSString *)status {
    NSString *formatString = NSLocalizedString(@"Access to %@ is %@.", @"");
    NSString *message = [NSString stringWithFormat:formatString, [self stringForDataClass:class], status];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kRequestStatusStr message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    alertView = nil;
}

- (NSString *)stringForDataClass:(DataClass)class {
    if(class == Location) {
        return kDataClassLocation;
    }
    else if(class == Contacts) {
        return kDataClassContacts;
    }
    else if(class == Calendars) {
        return kDataClassCalendars;
    }
    else if(class == Photos) {
        return kDataClassPhotos;
    }
    else if(class == Reminders) {
        return kDataClassReminders;
    }
    else if(class == Microphone) {
        return kDataClassMicrophone;
    }
    else if(class == Facebook) {
        return kDataClassFacebook;
    }
    else if(class == Twitter) {
        return kDataClassTwitter;
    }
    else if(class == SinaWeibo) {
        return kDataClassSinaWeibo;
    }
    else if(class == TencentWeibo) {
        return kDataClassTencentWeibo;
    }
    else if(class == Advertising) {
        return kDataClassAdvertising;
    }
    
    return nil;
}

@end