//
//  ArrivedGuestsViewController.h
//  PromNight
//
//  Created by Abizer Nasir on 24/04/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArrivedGuestsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *moc;

@end
