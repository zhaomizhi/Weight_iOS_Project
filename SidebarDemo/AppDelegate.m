//
//  AppDelegate.m
//  SidebarDemo
//
//  Created by Simon on 28/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "AppDelegate.h"
#import "HKHealthStore+AAPLExtensions.h"
#import "WeightRecords.h"



@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize host = _host;
@synthesize healthStore = _healthStore;
@synthesize userRecordHKQuantitySample = _userRecordHKQuantitySample;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}

//-(void)initCoreData{
//    NSArray *petList = [self getFetchRequestWithEntity:@"WeightRecords"];
//    NSError *error = nil;
//    if ([petList count] == 0){
//        WeightRecords *weightRecord = [NSEntityDescription insertNewObjectForEntityForName:@"WeightRecords" inManagedObjectContext:[self managedObjectContext]];
//        NSDate *today = [NSDate date];
//        NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
//        weightRecord.createdDate = yesterday;
//        weightRecord.weightRecord = @"8";
//        
//        if (![[self managedObjectContext]save:&error]) {
//            NSLog(@"Error with %@", error);
//        } else {
//            NSLog(@"success");
//        }
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}







#pragma mark init healthKit


-(HKHealthStore*) healthStore {
    if (_healthStore != nil) {
        return _healthStore;
    }
    _healthStore = [[HKHealthStore alloc] init];
    return _healthStore;
}



-(void)setUpHealthSotreIfPossible {
    if ([HKHealthStore isHealthDataAvailable] ) {
        self.healthStore = HEALTHSTORE;
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTyep = [self dataTypesToRead];
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTyep completion:^(BOOL success,
                                                                                                              NSError *error){
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self readNecessaryDataFromHealthKit];
            });
        }];
    }
}

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    // HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    // HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    return [NSSet setWithObjects: heightType, weightType, nil];
}


// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    //HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    //HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    return [NSSet setWithObjects: heightType, weightType, birthdayType, biologicalSexType, nil];
}


#pragma mark reading data from healthkit

-(NSMutableArray*)readNecessaryDataFromHealthKit {
    
    
    if ([HKHealthStore isHealthDataAvailable] ){
        NSError *error;
        NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
        
        //read gender info
        HKBiologicalSexObject *bioSex = [self.healthStore biologicalSexWithError:&error];
        NSString *gender;
        switch (bioSex.biologicalSex) {
            case HKBiologicalSexNotSet:
                gender = @"other";
                break;
            case HKBiologicalSexFemale:
                gender = @"Female";
                break;
            case HKBiologicalSexMale:
                // ...
                gender = @"Male";
                break;
        }
        
        //read weight
        
        
        NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
        massFormatter.unitStyle = NSFormattingUnitStyleLong;
        
        NSMassFormatterUnit weightFormatterUnit = NSMassFormatterUnitPound;
        NSString *weightUnitString = [massFormatter unitStringFromValue:10 unit:weightFormatterUnit];
        NSString *localizedWeightUnitDescriptionFormat = NSLocalizedString(@"Weight (%@)", nil);
        NSString *unit = [NSString stringWithFormat:localizedWeightUnitDescriptionFormat, weightUnitString];
        
        
        
        HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        
        [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(NSArray *mostRecentQuantity, NSError *error) {
            if (!mostRecentQuantity) {
                NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully and the error is %@", error);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"failed");
                });
            }
            else {
                // Determine the weight in the required unit.
                HKUnit *weightUnit = [HKUnit poundUnit];
                //double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
                self.userRecordHKQuantitySample = [[NSMutableArray alloc] init];
                for (HKQuantitySample *sample in mostRecentQuantity) {
                    //[userWeights arrayByAddingObject:[sample doubleValueForUnit:weightUnit]];
                    //double temp = [[sample quantity] doubleValueForUnit:weightUnit];
                    //[self.userRecords addObject:[NSNumber numberWithDouble:temp]];
                    [self.userRecordHKQuantitySample addObject:sample];
                }
                
            }
        }];
        
        [[self host] setBirthday:dateOfBirth];
        [[self host] setGender:gender];
        return self.userRecordHKQuantitySample;
    } else {
        [self setUpHealthSotreIfPossible];
        
    }
}






- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"coreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Weight_Final.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}




#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}




#pragma mark - fetch request controller

-(NSArray*) getFetchRequestWithEntity : (NSString*)entityName{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    
    return [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
}


@end
