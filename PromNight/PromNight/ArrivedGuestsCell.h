//
//  ArrivedGuestsCell.h
//  PromNight
//
//  Created by Hanley Hansen on 03/30/2012.
//  Copyright (c) 2012 Hansen Info Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Attendee;

@interface ArrivedGuestsCell : UITableViewCell

@property (strong, nonatomic) Attendee *guest;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketNumber;
@property (weak, nonatomic) IBOutlet UILabel *arrivalTime;

@end
