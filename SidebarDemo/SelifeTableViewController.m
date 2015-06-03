//
//  SelifeTableViewController.m
//  Weight_Final
//
//  Created by 赵谜 on 4/8/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "SelifeTableViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "ChangeNameViewController.h"
#import "MobileCoreServices/MobileCoreServices.h"
#import "GoalOrHeightViewController.h"
#import "CoreDataHostInfo.h"
#import "HKInfo.h"
#import "MainViewController.h"


@interface SelifeTableViewController ()
@property CoreDataHostInfo *coreDataHostInfo;


@end

@implementation SelifeTableViewController
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize usernameLabel;
@synthesize birthdayLabel;
@synthesize genderLabel;
@synthesize coreDataHostInfo;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    managedObjectContext = MOC;
    [self initLabel];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController ) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
}

-(void) viewDidAppear:(BOOL)animated {
    NSArray *userList = [self getFetchRequestWithEntity:@"CoreDataHostInfo"];
    if ([userList count] > 0 ) {
        
        NSString *username = [[userList objectAtIndex:0] userName];
        if (username == nil) {
            usernameLabel.text = @"Default Username";
        } else {
            usernameLabel.text = username;
        }
        
    } else {
        usernameLabel.text = @"Default Username";
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initLabel {
    NSArray *listFromCoreData = [self getFetchRequestWithEntity:@"CoreDataHostInfo"];
    NSUInteger i = [listFromCoreData count];
    if ([listFromCoreData count] > 0) {
        CoreDataHostInfo *mainHost = [listFromCoreData objectAtIndex:i - 1];
        
        if ([mainHost userName]!= nil) {
            usernameLabel.text = [mainHost userName];
        } else {
            usernameLabel.text = @"Default Username";
        }
        
        if ([mainHost gender]!= nil) {
            genderLabel.text = mainHost.gender;
        } else {
            genderLabel.text = @"Gender";
        }
        
        if ([mainHost birthday]!= nil) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            NSString *birthdayString = [dateFormat stringFromDate:mainHost.birthday];
            birthdayLabel.text = birthdayString;
        } else {
            birthdayLabel.text = @"Birthday";
        }
    }
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

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


#pragma mark - Navigation
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"changeName" sender:self];
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"changeName"]) {
        ChangeNameViewController *changeNameCV = [segue destinationViewController];
    }
}

#pragma mark core data
-(NSArray*) getFetchRequestWithEntity : (NSString*)entityName{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    
    return [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
}



# pragma image picker


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.image.image = image;
    }
}


- (IBAction)editImageButtonClicked:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imageController = [[UIImagePickerController alloc] init];
        imageController.delegate = self;
        imageController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imageController.allowsEditing = NO;
        [self presentViewController:imageController animated:YES completion:nil];
    }
}
- (IBAction)imageSaveButtonClicke:(id)sender {
    NSError *error = nil;
    NSArray *userList = [self getFetchRequestWithEntity:@"CoreDataHostInfo"];
    //there is no user log in before
    if ([userList count] == 0) {
        
        CoreDataHostInfo *user = [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataHostInfo" inManagedObjectContext:[self managedObjectContext]];
        user.image = UIImageJPEGRepresentation(self.image.image, 0.0);
        if (![[self managedObjectContext]save:&error]) {
            NSLog(@"Error with %@", error);
        } else {
            NSLog(@"success");
        }
        
        //get the user name from current user
    } else {
        CoreDataHostInfo *user = [userList objectAtIndex:0];
        user.image = UIImagePNGRepresentation(self.image.image);
        [self.managedObjectContext save:&error];
    }

}
@end
