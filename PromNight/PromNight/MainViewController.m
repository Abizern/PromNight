//
//  MainViewController.m
//  PromNight
//
//  Created by Hanley Hansen on 03/30/2012.
//  Copyright (c) 2012 Hansen Info Tech. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

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
@synthesize arrivedTable;
@synthesize arrivedView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrivedView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,410)];
    arrivedView.backgroundColor = [UIColor whiteColor];
    UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(backToCheckIn)];
    NSArray *items = [NSArray arrayWithObjects: customItem, nil];
    [tb setItems:items animated:NO];
    
    arrivedTable = [[UITableView alloc] initWithFrame:CGRectMake(0,44,320,365) style:UITableViewStyleGrouped];
	arrivedTable.delegate = self;
    arrivedTable.dataSource = self;
    [arrivedView addSubview:arrivedTable];
    [arrivedView addSubview:tb];
    
}

-(void)backToCheckIn
{
    
    [self.arrivedView removeFromSuperview];
    
}

- (void) reloadData 
{
    [self.view addSubview:arrivedView];	
	[self.arrivedTable reloadData];
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
	return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    
    return [self.fetchedArrivedObjects count];
    
}   

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
	NSDictionary *s =  [self.fetchedArrivedObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@ has arrived", [s objectForKey:@"lastName"], [s objectForKey:@"firstName"]];
    
    return cell;
    
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attendee" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"arrived == %@", [NSNumber numberWithBool: YES]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    fetchedArrivedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
    if (!fetchedArrivedObjects) {
        DLog(@"Unable to retrieve any values because: %@", error);
    }
    
    if (!fetchedArrivedObjects.count) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attendance Status"                                        message:[NSString stringWithFormat:@"No one has checked in yet"]
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.ticketNumberField.text = @"";
        self.firstNameField.text = @"";
        self.lastNameField.text = @"";
        self.status.text = @"";
        
    } else {
        
        NSLog(@"%@", fetchedArrivedObjects);
        [self reloadData];
        
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
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Doesn't Exist!"                                        message:[NSString stringWithFormat:@"Ticket Number Doesn't Exist"]
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