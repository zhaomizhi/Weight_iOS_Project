//
//  PetSettingViewController.m
//  Weight_Final
//
//  Created by 赵谜 on 4/8/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "PetSettingViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "CoreDataPetInfo.h"

@interface PetSettingViewController ()
@property BOOL isPetSet;

@end

@implementation PetSettingViewController
@synthesize sideBar;
@synthesize managedObjectContext;
@synthesize isPetSet;
@synthesize button;
@synthesize petNameText;
@synthesize title;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    managedObjectContext = MOC;
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideBar setTarget: self.revealViewController];
        [self.sideBar setAction: @selector( revealToggle: )];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(hideKeyBoard)];
        [self.view addGestureRecognizer:tapGesture];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    self.petNameText.delegate = self;


    
    // there is pet in already
    if ([self whetherPetSet]){
        title.text = @"Change Pet Name";
    } else {
        title.text = @"Submit Your Pet Name";
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

- (BOOL)whetherPetSet {
    NSArray *petList = [self getFetchRequestWithEntity:@"CoreDataPetInfo"];
    if ([petList count] == 0) {
        return NO;
    } else {
        return YES;
    }
}


- (NSArray*) getFetchRequestWithEntity : (NSString*)entityName{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    return [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
}

- (IBAction)buttonClicked:(id)sender {
    if ([[[self petNameText] text] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successful!"
                                                        message:@"Setting is done."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSError *error = nil;
        // there is pet in already
        if ([self whetherPetSet]){
            //title.text = @"Change Pet Name";
            NSArray *petList = [self getFetchRequestWithEntity:@"CoreDataPetInfo"];
            CoreDataPetInfo *coreDataPetInfo = [petList objectAtIndex:0];
            coreDataPetInfo.petName = [[self petNameText] text];
            // there is no pet
        } else {
            CoreDataPetInfo *coreDataPetInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataPetInfo" inManagedObjectContext:[self managedObjectContext]];
            coreDataPetInfo.petName = [[self petNameText] text];
        }
        [self.managedObjectContext save:&error];
    }
    [self hideKeyBoard];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.petNameText resignFirstResponder];
    return YES;
}

-(void)hideKeyBoard {
    [self.petNameText resignFirstResponder];
}

@end
