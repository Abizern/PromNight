//
//  MainViewController.m
//  PromNight
//
//  Created by Hanley Hansen on 03/30/2012.
//  Copyright (c) 2012 Hansen Info Tech. All rights reserved.
//

static NSString * const ArrivedGuestsSegueIdentifier = @"ArrivedGuestsSegue";

#import "MainViewController.h"
#import "ArrivedGuestsViewController.h"
#import "ModelKeys.h"

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

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![segue.identifier isEqualToString:ArrivedGuestsSegueIdentifier]) {
        return;
    }
    ArrivedGuestsViewController *arrivedGuestsVC = segue.destinationViewController;
    arrivedGuestsVC.moc = self.managedObjectContext;
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

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self checkBarcodeNumber:textField.text];
    textField.text = @"";
    return YES;
}



#pragma mark - Private methods;

- (void)checkBarcodeNumber:(NSString *)string {
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }

    
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
        
        self.ticketNumberField.text = [[attendee valueForKey:kModelTicketNumber] stringValue];
        self.firstNameField.text = [attendee valueForKey:kModelFirstName];
        self.lastNameField.text = [attendee valueForKey:kModelLastName];
        
        NSInteger isHere = [[attendee valueForKey:kModelArrived] boolValue];
        
        if (!isHere) {
            
            [attendee setValue:[NSNumber numberWithBool:YES] forKey:kModelArrived];
            [attendee setValue:[NSDate date] forKey:kModelArrivalTime];
            self.status.text = [NSString stringWithFormat: @"%@ %@ has arrived", [attendee valueForKey:kModelFirstName], [attendee valueForKey:kModelLastName]];   
        } else {
            NSString *arrivedAt = [dateFormatter stringFromDate:[attendee valueForKey:kModelArrivalTime]];
            NSString *alertString = [NSString stringWithFormat:@"%@ %@ has already been scanned into the system at %@ !", [attendee valueForKey:kModelFirstName], [attendee valueForKey:kModelLastName], arrivedAt];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already here!" 
                                                            message:alertString
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            self.status.text = alertString;
            
        }
    }

}

@end