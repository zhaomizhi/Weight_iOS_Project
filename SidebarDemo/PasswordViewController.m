//
//  PasswordViewController.m
//  Weight_Final
//
//  Created by 赵谜 on 4/8/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "PasswordViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"

@interface PasswordViewController ()

@end

@implementation PasswordViewController
@synthesize managedObjectContext;
@synthesize sidebarButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Setting notification";
    managedObjectContext = MOC;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
