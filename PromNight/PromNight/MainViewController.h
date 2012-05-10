//
//  MainViewController.h
//  PromNight
//
//  Created by Hanley Hansen on 03/30/2012.
//  Copyright (c) 2012 Hansen Info Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MainViewController : UIViewController <UITextFieldDelegate> {

}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UILabel *ticketNumberField;
@property (weak, nonatomic) IBOutlet UILabel *firstNameField;
@property (weak, nonatomic) IBOutlet UILabel *lastNameField;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) NSArray *fetchedArrivedObjects;

- (IBAction)barcodeNumberChanged:(UITextField *)sender;

@end
