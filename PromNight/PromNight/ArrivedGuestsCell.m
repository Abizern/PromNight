//
//  ArrivedGuestsCell.m
//  PromNight
//
//  Created by Hanley Hansen on 03/30/2012.
//  Copyright (c) 2012 Hansen Info Tech. All rights reserved.
//


#import "ArrivedGuestsCell.h"
#import "Attendee.h"
#import "ModelKeys.h"
#import <CoreData/CoreData.h>

@interface ArrivedGuestsCell ()

- (void)updateLabels;

@end

@implementation ArrivedGuestsCell
@synthesize guest = _guest;
@synthesize nameLabel = _nameLabel;
@synthesize ticketNumber = _ticketNumber;
@synthesize arrivalTime = _arrivalTime;

#pragma mark - Set up and tear down

- (void)awakeFromNib {
    // When the guest object is set, this observation will update the labels
    [self addObserver:self forKeyPath:@"guest" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"guest"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (keyPath == @"guest") {
        [self updateLabels];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private methods

- (void)updateLabels {
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.guest valueForKey:kModelFirstName], [self.guest valueForKey:kModelLastName]];
    self.ticketNumber.text = [[self.guest valueForKey:kModelTicketNumber] stringValue];
    NSDate *arrivedAt = [self.guest valueForKey:kModelArrivalTime];
    self.arrivalTime.text = [dateFormatter stringFromDate:arrivedAt];
}

@end
