//
//  Attendee.h
//  PromNight
//
//  Created by Abizer Nasir on 24/04/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Attendee : NSManagedObject

@property (nonatomic, retain) NSDate * arrivalTime;
@property (nonatomic, retain) NSNumber * arrived;
@property (nonatomic, retain) NSNumber * barcodeNumber;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * ticketNumber;
@property (nonatomic, retain) NSString * lastNameInitial;

@end
