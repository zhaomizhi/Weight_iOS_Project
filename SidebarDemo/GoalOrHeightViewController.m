//
//  GoalOrHeightViewController.m
//  Weight_Final
//
//  Created by 赵谜 on 4/8/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "GoalOrHeightViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "PNChart.h"
#import "CoreDataHostInfo.h"



@interface GoalOrHeightViewController ()


@end

@implementation GoalOrHeightViewController 
@synthesize sidebarButton;
@synthesize  titleName;
@synthesize managedObjectContext;
@synthesize textField;
@synthesize label;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    managedObjectContext = MOC;
    self.title = titleName;
    self.textField.delegate = self;
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if ( revealViewController ) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(hideKeyBoard)];
        
        [self.view addGestureRecognizer:tapGesture];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    [self initTextField];
    


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initTextField {
    if ([titleName isEqualToString:@"Height"]) {
        label.text  = @"Height ";
        
    } else {
        label.text = @"Goal";
        NSArray *userList = [self getFetchRequestWithEntity:@"CoreDataHostInfo"];
        if ([userList count] > 0 && [[userList objectAtIndex:0] goal] ) {
            NSString *goal = [[userList objectAtIndex:0] goal];
            textField.text = goal;
        } else {
            textField.text = @"0";
        }
    }
}

-(NSArray*) getFetchRequestWithEntity : (NSString*)entityName{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSError *error = nil;
        
        
        return [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - dismiss keyboard

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    return YES;
}

-(void)hideKeyBoard {
    [self.textField resignFirstResponder];
}


#pragma mark click button

- (IBAction)clickeSaveButton:(id)sender {
    NSError *error = nil;
    NSString *input = textField.text;
    NSArray *userList = [self getFetchRequestWithEntity:@"CoreDataHostInfo"];
    
    //there is no user log in before
    if ([userList count] == 0) {
        
        CoreDataHostInfo *user = [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataHostInfo" inManagedObjectContext:[self managedObjectContext]];
        user.goal = input;
        if (![[self managedObjectContext]save:&error]) {
            NSLog(@"Error with %@", error);
        } else {
            NSLog(@"success");
        }
        
       
    } else {
        CoreDataHostInfo *user = [userList objectAtIndex:0];
        user.goal = input;
        [self.managedObjectContext save:&error];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successful!"
                                                    message:@"Setting is done."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self hideKeyBoard];
}
@end
