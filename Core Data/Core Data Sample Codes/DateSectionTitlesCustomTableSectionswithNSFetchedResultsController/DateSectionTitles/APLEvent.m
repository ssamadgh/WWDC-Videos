/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Custom class for the Event entity.
  The timeStamp and title are persistent attributes; the sectionIdentifier is transient and derived from timeStamp.
  * timeStamp is the date on which the event occurred.
  * title is displayed in the table view rows.
  When the default data is created in the application delegate, the title is initialized to a string representation of the date.
  * sectionIdentifier is used to divide the events into sections in the table view.
  sectionIdentifier is a string value representing the number ((year * 1000) + month). Using this value, events can be correctly ordered and grouped regardless of the actual name of the month. It is calculated and cached on demand in the custom accessor method.
 */

#import "APLEvent.h"

@interface APLEvent ()

@property (nonatomic) NSDate *primitiveTimeStamp;
@property (nonatomic) NSString *primitiveSectionIdentifier;

@end

#pragma mark -

@implementation APLEvent

@dynamic title, timeStamp, primitiveTimeStamp, sectionIdentifier, primitiveSectionIdentifier;

#pragma mark - Transient properties

- (NSString *)sectionIdentifier
{
    // Create and cache the section identifier on demand.

    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString *tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];

    if (!tmp)
    {
        /*
         Sections are organized by month and year. Create the section identifier as a string representing the number (year * 1000) + month; this way they will be correctly ordered chronologically regardless of the actual name of the month.
         */
        NSCalendar *calendar = [NSCalendar currentCalendar];

        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:self.timeStamp];
        tmp = [NSString stringWithFormat:@"%ld", ([components year] * 1000) + [components month]];
        [self setPrimitiveSectionIdentifier:tmp];
    }
    return tmp;
}


#pragma mark - Time stamp setter

- (void)setTimeStamp:(NSDate *)newDate
{
    // If the time stamp changes, the section identifier become invalid.
    [self willChangeValueForKey:@"timeStamp"];
    [self setPrimitiveTimeStamp:newDate];
    [self didChangeValueForKey:@"timeStamp"];

    [self setPrimitiveSectionIdentifier:nil];
}


#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier
{
    // If the value of timeStamp changes, the section identifier may change as well.
    return [NSSet setWithObject:@"timeStamp"];
}

@end
