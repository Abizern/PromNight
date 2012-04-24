//
//  MainViewController.m
//  PromNight
//
//  Created by Hanley Hansen on 03/30/2012.
//  Copyright (c) 2012 Hansen Info Tech. All rights reserved.
//

#import "MainViewController.h"
#import "ArrivedGuestsViewController.h"

@interface MainViewController ()

@property (strong, nonatomic, readonly) UIPopoverController *arrivedPopover;

- (void)checkBarcodeNumber:(NSString *)string;

@end

@implementation MainViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize inputField = _inputField;
@synthesize ticketNumberField = _ticketNumberField;
@synthesize firstNameField = _firstNameField;
@synthesize lastNameField = _lastNameField;
@synthesize status = _status;
@synthesize fetchedArrivedObjects;

@synthesize arrivedPopover = _arrivedPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setInputField:nil];
    [self setTicketNumberField:nil];
    [self setFirstNameField:nil];
    [self setLastNameField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // The background doesn't handle rotation, so only present this in portrait.
    // Either right way up or upside down
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


#pragma mark - Custom accessors

- (UIPopoverController *)arrivedPopover {
    if (!_arrivedPopover) {
        // Create the UITableViewController that will be presented in a popup
        ArrivedGuestsViewController *tableViewController = [[ArrivedGuestsViewController alloc] init];
        // Pass the managed object context to this controller
        tableViewController.moc = self.managedObjectContext;
        
        // Create a UIPopoverController to display the contents of this tableview controller.
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:tableViewController];
        _arrivedPopover = popover;
    }
    
    return _arrivedPopover;
}

#pragma mark -  Action methods

- (IBAction)barcodeNumberChanged:(UITextField *)sender {
    NSInteger inputLength = [sender.text length];
    
    if (inputLength == 6) {
        [self checkBarcodeNumber:sender.text];
        sender.text = @"";
    }
}

- (void)checkWhosArrived:(UIButton *)sender {
    // It might be nice to have the popover come out from the button that is clicked to present it.
    // Just for clarity, initialise variables outside of the call, you could do this all as one line instead.
    CGRect rect = sender.frame;
    UIView *view = self.view;
    UIPopoverArrowDirection direction = UIPopoverArrowDirectionAny;
    
    [self.arrivedPopover presentPopoverFromRect:rect inView:view permittedArrowDirections:direction animated:YES];
    
    
    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attendee" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"arrived == %@", [NSNumber numberWithBool: YES]];
//    [fetchRequest setPredicate:predicate];
//    
//    NSError *error = nil;
//    fetchedArrivedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        
//    if (!fetchedArrivedObjects) {
//        DLog(@"Unable to retrieve any values because: %@", error);
//    }
//    
//    if (!fetchedArrivedObjects.count) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attendance Status"                                        message:[NSString stringWithFormat:@"No one has checked in yet"]
//                                                       delegate:nil 
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//        self.ticketNumberField.text = @"";
//        self.firstNameField.text = @"";
//        self.lastNameField.text = @"";
//        self.status.text = @"";
//        
//    } else {
//        
//        NSLog(@"%@", fetchedArrivedObjects);
//        [self reloadData];
//        
//    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self checkBarcodeNumber:textField.text];
    textField.text = @"";
    return YES;
}


#pragma mark - Private methods;

- (void)checkBarcodeNumber:(NSString *)string {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attendee" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barcodeNumber == %u", [string integerValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (!fetchedObjects) {
        DLog(@"Unable to retrieve any values because: %@", error);
    }
    
    if (!fetchedObjects.count) {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Doesn't Exist!"
                                                        message:[NSString stringWithFormat:@"Ticket Number Doesn't Exist"]
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.ticketNumberField.text = @"";
        self.firstNameField.text = @"";
        self.lastNameField.text = @"";
        self.status.text = [NSString stringWithFormat:@"Ticket Number Doesn't Exist"];
        
    } else {
        
        NSManagedObject *attendee = [fetchedObjects lastObject];
        
        self.ticketNumberField.text = [[attendee valueForKey:@"ticketNumber"] stringValue];
        self.firstNameField.text = [attendee valueForKey:@"firstName"];
        self.lastNameField.text = [attendee valueForKey:@"lastName"];
        
        NSInteger isHere = [[attendee valueForKey:@"arrived"] boolValue];
        
        if (!isHere) {
            
            [attendee setValue:[NSNumber numberWithBool:YES] forKey:@"arrived"];
            self.status.text = [NSString stringWithFormat: @"%@ %@ has arrived", [attendee valueForKey:@"firstName"], [attendee valueForKey:@"lastName"]];   
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already here!"                                        message:[NSString stringWithFormat:@"%@ %@ has already been scanned into the system!", [attendee valueForKey:@"firstName"], [attendee valueForKey:@"lastName"]]
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            self.status.text = [NSString stringWithFormat:@"%@ %@ has already been scanned into the system!", [attendee valueForKey:@"firstName"], [attendee valueForKey:@"lastName"]];
            
        }
    }

}

@end