//
//  AppDelegate.h
//  SidebarDemo
//
//  Created by Simon on 28/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>
#import "HKInfo.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
#define MOC [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext]
#define HEALTHSTORE [(AppDelegate*)[[UIApplication sharedApplication] delegate] healthStore]
#define URECORDSAMPLES [(AppDelegate*)[[UIApplication sharedApplication] delegate] userRecordHKQuantitySample]

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property ( strong, nonatomic) HKHealthStore *healthStore;
@property (readonly,strong, nonatomic)HKInfo *host;
@property (strong, nonatomic) NSMutableArray *userRecordHKQuantitySample;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;



@end
