//
//  SidebarTableViewController.m
//  SidebarDemo
//
//  Created by Simon Ng on 10/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

#import "SidebarTableViewController.h"
#import "SWRevealViewController.h"
#import "GoalOrHeightViewController.h"
#import "SelifeTableViewController.h"

@interface SidebarTableViewController ()
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation SidebarTableViewController {
    NSArray *menuItems;
    NSDictionary *menuItemsList;
    NSArray *menuSelectionTitle;
}
@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menuItems = @[@"Info", @"Weight",@"With Pet",  @"Height", @"Weight Goal" , @"Password", @"Setting"];
    menuItemsList = @{@"Account" : @[@"Info", @"Weigth", @"With Pet", @"Height", @"Weight Goal"],
                      @"Sysm" : @[@"Password", @"Setting"]};
    menuSelectionTitle = @[@"Account", @"Sysm"];
    
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
    return [menuItems count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    return cell;
    
    

}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 100;
    } else {
        return 40;
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Set the title of navigation bar by using the menu items
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
//    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
//    if ([segue.identifier isEqualToString:@"Weight Goal"] || [segue.identifier isEqualToString:@"Height"]) {
//        GoalOrHeightViewController *ghVC = [segue destinationViewController];
//        ghVC.titleName = segue.identifier;
//    }
    NSString *identifier = segue.identifier;
    if (  [identifier isEqualToString:@"Weight Goal"]) {
        UINavigationController *navController = segue.destinationViewController;
        GoalOrHeightViewController *ga = [navController childViewControllers].firstObject;
        ga.titleName = identifier;
    } else if ([identifier isEqualToString:@"selfPage"]) {
        UINavigationController *navController = segue.destinationViewController;
        SelifeTableViewController *sa = [navController childViewControllers].firstObject;
        
    } else if ([identifier isEqualToString:@"listPage"]) {
        
    }

}


//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (indexPath.row == 3) {
//        [self performSegueWithIdentifier:@"Weight Goal" sender:self];
//    } else if (indexPath.row == 4) {
//        [self performSegueWithIdentifier:@"Height" sender:self];
//        
//    }
//    
//}

#pragma mark core data
-(NSArray*) getFetchRequestWithEntity : (NSString*)entityName{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    
    return [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
}




@end
