//
//  WeightListTableViewController.m
//  Weight_Final
//
//  Created by 赵谜 on 4/28/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "WeightListTableViewController.h"
#import "SWRevealViewController.h"
#import "HKHealthStore+AAPLExtensions.h"
#import "CoreDataHostInfo.h"
#import "AppDelegate.h"


@interface WeightListTableViewController ()
@property NSArray *recordList;
@property (strong,nonatomic) HKHealthStore *healthStore;

@end

@implementation WeightListTableViewController
@synthesize recordList;
@synthesize healthStore;

- (void)viewDidLoad {
    [super viewDidLoad];
    healthStore = HEALTHSTORE;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Weight Records List";
    [self getDataFromHealthKit];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController ) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.recordList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // load weight lbs
    HKUnit *weightUnit = [HKUnit poundUnit];
    HKQuantitySample *sample   = [self.recordList objectAtIndex:indexPath.row];
    NSNumber *number = [NSNumber numberWithFloat:[[sample quantity] doubleValueForUnit:weightUnit]];
    NSString *numberString = [number stringValue];
    NSString *numberStringWithUnit = [NSString stringWithFormat:@"%@ %@", numberString, @"lbs"];
    cell.textLabel.text = numberStringWithUnit;
    
    // load weight create date
    NSDate *recordDate = [sample startDate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormat stringFromDate:recordDate];
    cell.detailTextLabel.text = dateString;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - health kit
-(void)getDataFromHealthKit {
    
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(NSArray *mostRecentQuantity, NSError *error) {
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully and the error is %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"failed");
            });
        }
        else {
            //set the result from healthkit to local variable
            self.recordList = mostRecentQuantity;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self tableView] reloadData];
                
            });
            
        }
    }];
    
    
    
}


@end
