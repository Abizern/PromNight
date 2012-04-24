//
//  Attendee.m
//  PromNight
//
//  Created by Abizer Nasir on 24/04/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//

#import "Attendee.h"


@implementation Attendee

@dynamic arrivalTime;
@dynamic arrived;
@dynamic barcodeNumber;
@dynamic firstName;
@dynamic lastName;
@dynamic ticketNumber;
@dynamic lastNameInitial;


#pragma mark - Custom Accessors

- (NSString *)lastNameInitial {
    [self willAccessValueForKey:@"lastNameInitial"];
    NSString *initial = [self.lastName substringToIndex:1];
    [self didAccessValueForKey:@"lastNameInitial"];
    
    return initial;
}

@end
