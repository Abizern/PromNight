//
//  ArrivedGuestsCell.h
//  PromNight
//
//  Created by Abizer Nasir on 24/04/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Attendee;

@interface ArrivedGuestsCell : UITableViewCell

@property (strong, nonatomic) Attendee *guest;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketNumber;
@property (weak, nonatomic) IBOutlet UILabel *arrivalTime;

@end
