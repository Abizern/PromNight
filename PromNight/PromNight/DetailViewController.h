//
//  DetailViewController.h
//  PromNight
//
//  Created by Abizer Nasir on 30/03/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
