//
//  ArrivedGuestsViewController.m
//  PromNight
//
//  Created by Hanley Hansen on 03/30/2012.
//  Copyright (c) 2012 Hansen Info Tech. All rights reserved.
//

#import "ArrivedGuestsViewController.h"
#import "ArrivedGuestsCell.h"
#import "ModelKeys.h"

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    // Fire up the frc to find out who has already arrived.
    [self.tableView setRowHeight:82.0];
    NSError *error;
    BOOL successfulFetch = [self.frc performFetch:&error];
    if (!successfulFetch) {
        DLog(@"Unable to fetch arrived guests because %@", [error description]);
    }
}

#pragma mark - Custom Accessors

- (NSFetchedResultsController *)frc {
    if (!_frc) {
        // Create the fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attendee" inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        
        NSPredicate *arrivedPredicate = [NSPredicate predicateWithFormat:@"arrived == YES"];
        [fetchRequest setPredicate:arrivedPredicate];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kModelLastName ascending:YES];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [fetchRequest setFetchBatchSize:20];
        
        // Create the NSFetchedResultsController
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.moc sectionNameKeyPath:kModelLastNameInitial cacheName:nil];
        frc.delegate = self;
        
        _frc = frc;
    }
    
    return _frc;
}

#pragma mark - NSFetchResultsController Delegates

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[self.frc sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.frc sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.frc sectionForSectionIndexTitle:title atIndex:index];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ArrivedGuestsCell";
    ArrivedGuestsCell *cell = (ArrivedGuestsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.guest = [self.frc objectAtIndexPath:indexPath];
    
    return cell;
}

@end
