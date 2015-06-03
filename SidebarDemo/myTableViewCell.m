//
//  myTableViewCell.m
//  Weight_Final
//
//  Created by 赵谜 on 4/7/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "myTableViewCell.h"
#import "AppDelegate.h"
#import "CoreDataHostInfo.h"

@implementation myTableViewCell
@synthesize image;

@synthesize managedObjectContext;



- (void)awakeFromNib {
    // Initialization code
//    managedObjectContext = MOC;
//    NSArray *userList = [self getFetchRequestWithEntity:@"CoreDataHostInfo"];
//    if ([userList count] > 0) {
//        NSString *name = [[userList objectAtIndex:0] userName];
//        usernameLabel.text = name;
//    } else {
//        usernameLabel.text = @"Set UserName";
//    }
    
    image.layer.cornerRadius = image.frame.size.height/2;
    image.layer.masksToBounds = YES;
    image.layer.borderColor = [UIColor lightGrayColor].CGColor;
    image.layer.borderWidth = 1.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


-(NSArray*) getFetchRequestWithEntity : (NSString*)entityName{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    return [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
}

//-(CoreDataHostInfo*) getLatestOneFetchResultWithEntity : (NSString *)entityName {
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
//    [request setEntity:entity];
//    
//    // Results should be in descending order of timeStamp.
//   // NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
//   // [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//    
//    NSArray *results = [managedObjectContext executeFetchRequest:request error:NULL];
//    CoreDataHostInfo *latestEntity = [results objectAtIndex:0];
//    return latestEntity;
//}

@end
