//
//  MainViewController.h
//  PromNight
//
//  Created by Hanley Hansen on 03/30/2012.
//  Copyright (c) 2012 Hansen Info Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    UIView *arrivedView;
    UITableView *arrivedTable;
    
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UILabel *ticketNumberField;
@property (weak, nonatomic) IBOutlet UILabel *firstNameField;
@property (weak, nonatomic) IBOutlet UILabel *lastNameField;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) NSArray *fetchedArrivedObjects;
@property (nonatomic, retain) UIView *arrivedView;
@property (nonatomic, retain) UITableView *arrivedTable;


- (IBAction)barcodeNumberChanged:(UITextField *)sender;
- (IBAction)checkWhosArrived:(UIButton *)sender;

@end
