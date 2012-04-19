//
//  ArrivedGuestsViewController.m
//  PromNight
//
//  Created by Abizer Nasir on 19/04/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//

#import "ArrivedGuestsViewController.h"

@interface ArrivedGuestsViewController ()

@property (strong, nonatomic, readonly) NSFetchedResultsController *frc;

@end

@implementation ArrivedGuestsViewController
@synthesize moc = _moc;
@synthesize frc = _frc;

// New designated initialiser
- (id)init {
    if (!(self == [super initWithStyle:UITableViewStylePlain])) {
        return nil; // Bail!
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return [self init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    // Fire up the frc to find out who has already arrived.
    NSError *error;
    BOOL successfulFetch = [self.frc performFetch:&error];
    if (!successfulFetch) {
        DLog(@"Unable to fetch arrived guests because %@", [error description]);
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - Custom accessors

- (NSFetchedResultsController *)frc {
    if (!_frc) {
        // Create the fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attendee" inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        
        NSPredicate *arrivedPredicate = [NSPredicate predicateWithFormat:@"arrived == YES"];
        [fetchRequest setPredicate:arrivedPredicate];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [fetchRequest setFetchBatchSize:20];
        
        // Create the NSFetchedResultsController
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:@"cache"];
        frc.delegate = self;
        
        _frc = frc;
    }
    
    return _frc;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.frc.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSManagedObject *attendee = [self.frc objectAtIndexPath:indexPath];
    NSString *name = [NSString stringWithFormat:@"%@, %@", [attendee valueForKey:@"lastName"], [attendee valueForKey:@"firstName"]];
    NSString *ticketNumber = [NSString stringWithFormat:@"%@", [[attendee valueForKey:@"ticketNumber"] stringValue]];
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = ticketNumber;
    
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}
@end
