//
//  ChangeNameViewController.m
//  Weight_Final
//
//  Created by 赵谜 on 4/8/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "ChangeNameViewController.h"
#import "AppDelegate.h"
#import "CoreDataHostInfo.h"


@interface ChangeNameViewController ()

@end

@implementation ChangeNameViewController
@synthesize label;
@synthesize textField;
@synthesize managedObjectContext;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    managedObjectContext = MOC;

    NSArray *userList = [self getFetchRequestWithEntity:@"CoreDataHostInfo"];
    if ([userList count] > 0) {
        NSString *username = [[userList objectAtIndex:0] userName];
        textField.text = username;
    } else {
        textField.text = @"Default Username";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark core data
//-(NSArray*) getFetchRequestWithEntity : (NSString*)entityName{
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    NSError *error = nil;
//    
//    
//    return [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
//}

#pragma mark button clicked
- (IBAction)saveButtonClicked:(id)sender {
    NSError *error = nil;
    NSString *input = textField.text;
    NSArray *userList = [self getFetchRequestWithEntity:@"CoreDataHostInfo"];
    
    //there is no user log in before
    if ([userList count] == 0) {
        
        CoreDataHostInfo *user = [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataHostInfo" inManagedObjectContext:[self managedObjectContext]];
        user.userName = input;
        if (![[self managedObjectContext]save:&error]) {
            NSLog(@"Error with %@", error);
        } else {
            NSLog(@"success");
        }
        
    //get the user name from current user
    } else {
        CoreDataHostInfo *user = [userList objectAtIndex:0];
        user.userName = input;
        [self.managedObjectContext save:&error];
    }
    

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark core data
-(NSArray*) getFetchRequestWithEntity : (NSString*)entityName{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    
    return [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
}
@end
