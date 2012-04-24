//
//  ArrivedGuestsCell.m
//  PromNight
//
//  Created by Abizer Nasir on 24/04/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//


#import "ArrivedGuestsCell.h"
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
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.guest valueForKey:@"firstName"], [self.guest valueForKey:@"lastName"]];
    self.ticketNumber.text = [[self.guest valueForKey:@"ticketNumber"] stringValue];
    self.arrivalTime.text = [[self.guest valueForKey:@"arrivalTime"] description];
}

@end
