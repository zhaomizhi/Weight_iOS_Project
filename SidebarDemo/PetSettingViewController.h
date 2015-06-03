//
//  PetSettingViewController.h
//  Weight_Final
//
//  Created by 赵谜 on 4/8/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PetSettingViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBar;
@property (weak, nonatomic) IBOutlet UITextField *petNameText;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *title;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
- (IBAction)buttonClicked:(id)sender;

@end