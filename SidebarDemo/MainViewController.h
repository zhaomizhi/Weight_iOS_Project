//
//  ViewController.h
//  SidebarDemo
//
//  Created by Simon on 28/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>
#import "HKInfo.h"



@interface MainViewController : UIViewController

#define HOST [(MainViewController*)[[UIApplication sharedApplication] delegate] hkInfo]

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIView *segBar;
@property (weak, nonatomic) IBOutlet UILabel *weightNumberLabel;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;



@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong,nonatomic) HKInfo *hkInfo;
@property (strong,nonatomic) HKHealthStore *healthStore;

- (IBAction)clickedSegmentButton:(id)sender;
- (IBAction)downClicked:(id)sender;
- (IBAction)upClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;




@end
