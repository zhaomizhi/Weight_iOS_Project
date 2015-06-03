//
//  ViewController.m
//  SidebarDemo
//
//  Created by Simon on 28/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "MainViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "PNChart.h"
#import "HKHealthStore+AAPLExtensions.h"
#import "CoreDataHostInfo.h"
#import "WeightRecords.h"





@interface MainViewController ()
@property (nonatomic, strong) NSDictionary *singelItems;
@property (nonatomic,strong) NSArray *itemCounts;
@property (nonatomic,strong) NSArray *HKSampleLists;
@property int whichSegmentIsClicked;





@end

@implementation MainViewController
@synthesize managedObjectContext;
@synthesize hkInfo;
@synthesize healthStore;
@synthesize HKSampleLists;
@synthesize whichSegmentIsClicked;
@synthesize weightNumberLabel;
@synthesize saveButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    managedObjectContext = MOC;
    healthStore = HEALTHSTORE;
    
    
    
    //init the layout and view
    self.title = @"Weight";
    self.whichSegmentIsClicked = 0;
    [saveButton setTintColor:PNFreshGreen];
    
    [self setUpHealthSotreIfPossible ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showCharBasedOnDataFromHealthKit];
        [self updateUsersWeightLabel];
        [self setUpGenderAndBirthday];
    });
    
    
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    NSLog(@"MainViewController viewdidload");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






#pragma  mark managedcontext


-(NSArray*) getFetchRequestWithEntity : (NSString*)entityName{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    
    return [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
}

-(CoreDataHostInfo*) getLastestOneFetchResultWithEntity : (NSString *)entityName {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    // Results should be in descending order of timeStamp.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *results = [managedObjectContext executeFetchRequest:request error:NULL];
    CoreDataHostInfo *latestEntity = [results objectAtIndex:0];
    return latestEntity;
}





#pragma mark segmented controller




- (IBAction)clickedSegmentButton:(id)sender {
    NSString *currentWeight = [self getPetCurrentWeight];
    switch ([sender selectedSegmentIndex]) {
        case 0:
            NSLog(@"0");
            self.whichSegmentIsClicked = 0;
            [self showChartByDay];
            [self updateUsersWeightLabel];
            break;
        case 1:
            NSLog(@"1");
            self.whichSegmentIsClicked = 1;
            [self showCharByPet];
            [self updateLabelWithPet:currentWeight];
            break;
        default:
            break;
    }
    
}

#pragma mark down/up button click

- (IBAction)downClicked:(id)sender {
    NSString *currentWeightNumber = weightNumberLabel.text;
    int floatWeight = [currentWeightNumber intValue];
    floatWeight = floatWeight - 1;
    NSString *result = [NSString stringWithFormat:@"%d",floatWeight];
    weightNumberLabel.text = result;
}

- (IBAction)upClicked:(id)sender {
    NSString *currentWeightNumber = weightNumberLabel.text;
    int floatWeight = [currentWeightNumber intValue];
    floatWeight = floatWeight + 1;
    NSString *result = [NSString stringWithFormat:@"%d",floatWeight];
    weightNumberLabel.text = result;
}

- (IBAction)saveButtonClicked:(id)sender {
    NSError *error = nil;
    NSDate *currentDate = [NSDate date];
    
    if (self.whichSegmentIsClicked == 1) {
        // pet button clicked
        NSArray *petList = [self getFetchRequestWithEntity:@"WeightRecords"];
        // there is record in the petlist
        if ([petList count] > 0) {
            WeightRecords *wr = [petList objectAtIndex:0];
            NSDate *recentDateFromList = wr.createdDate;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM-dd"];
            NSString *currentDateString = [dateFormat stringFromDate:currentDate];
            NSString *recnetDateFromListString = [dateFormat stringFromDate:recentDateFromList];
            // There is a same day record in the core data records list already
            // update the record
            if ([currentDateString isEqualToString:recnetDateFromListString]) {
                
                HKQuantitySample *hkSample = [HKSampleLists objectAtIndex:0];
                HKUnit *weightUnit = [HKUnit poundUnit];
                NSNumber *currentHostWeight = [NSNumber numberWithFloat:[[hkSample quantity] doubleValueForUnit:weightUnit]];
                int currentHostWeightInt = [currentHostWeight intValue];
                int textValue = [self.weightNumberLabel.text intValue];
                int petWeightInt = textValue - currentHostWeightInt;
                NSString *petWeightString = [NSString stringWithFormat:@"%d", petWeightInt];
                NSLog(@"There is a pet in record right now");
                wr.createdDate = [NSDate date];
                wr.weightRecord = petWeightString;
                if (![[self managedObjectContext]save:&error]) {
                    NSLog(@"Error with %@", error);
                } else {
                    NSLog(@"success");
                }
                // create a new one to insert into core data
            } else {
                HKQuantitySample *hkSample = [HKSampleLists objectAtIndex:0];
                HKUnit *weightUnit = [HKUnit poundUnit];
                NSNumber *currentHostWeight = [NSNumber numberWithFloat:[[hkSample quantity] doubleValueForUnit:weightUnit]];
                int currentHostWeightInt = [currentHostWeight intValue];
                int currentPetWeight = [self.weightNumberLabel.text intValue] - currentHostWeightInt;
                NSString *currentPetWeightString = [NSString stringWithFormat:@"%d", currentPetWeight];
                WeightRecords *weightRecord = [NSEntityDescription insertNewObjectForEntityForName:@"WeightRecords" inManagedObjectContext:[self managedObjectContext]];
                weightRecord.createdDate = currentDate;
                weightRecord.weightRecord = currentPetWeightString;
                
                if (![[self managedObjectContext]save:&error]) {
                    NSLog(@"Error with %@", error);
                } else {
                    NSLog(@"success");
                }
                
            }
        } else {
            HKQuantitySample *hkSample = [HKSampleLists objectAtIndex:0];
            HKUnit *weightUnit = [HKUnit poundUnit];
            NSNumber *currentHostWeight = [NSNumber numberWithFloat:[[hkSample quantity] doubleValueForUnit:weightUnit]];
            int currentHostWeightInt = [currentHostWeight intValue];
            int currentPetWeight = [self.weightNumberLabel.text intValue] - currentHostWeightInt;
            NSString *currentPetWeightString = [NSString stringWithFormat:@"%d", currentPetWeight];
            WeightRecords *weightRecord = [NSEntityDescription insertNewObjectForEntityForName:@"WeightRecords" inManagedObjectContext:[self managedObjectContext]];
            weightRecord.createdDate = currentDate;
            weightRecord.weightRecord = currentPetWeightString;
            
            if (![[self managedObjectContext]save:&error]) {
                NSLog(@"Error with %@", error);
            } else {
                NSLog(@"success");
            }
        }
        
        [self showCharByPet];
        
    } else {
        NSString *currentWeightNumber = weightNumberLabel.text;
        float floatWeight = [currentWeightNumber floatValue];
        [self saveWeightIntoHealthStore:floatWeight];
    }
}


- (void)saveWeightIntoHealthStore:(double)weight {
    // Save the user's weight into HealthKit.
    
    HKUnit *poundUnit = [HKUnit poundUnit];
    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:weight];
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
    
    [self.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the weight sample %@. In your app, try to handle this gracefully. The error was: %@.", weightSample, error);
            abort();
        } else {
            NSLog(@"Save data to healthkit successful");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showCharBasedOnDataFromHealthKit];
        });
    }];
}



#pragma mark show chart detail
-(void)showChartByDay {
    
    // date formatter & string array & date array
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd"];
    NSMutableArray *sevenDaysString = [[NSMutableArray alloc] init];
    NSMutableArray *sevenDaysStringtemp = [[NSMutableArray alloc] init];
    NSMutableArray *sevenDays = [[NSMutableArray alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    
    
    //get the number of how many record in healthkit
    NSInteger number = [HKSampleLists count];
    
    //get the latest date
    NSDate *lastDate;
    
    
    // if the number more than one
    if (number > 0 ) {
        HKQuantitySample *hkSample = [HKSampleLists objectAtIndex:0];
        lastDate = [hkSample startDate];
        [sevenDaysStringtemp addObject:[dateFormat stringFromDate:lastDate]];
        //generate the 7 days array (value and string)
        for(int i = 1; i < 7; i++){
            NSDate *tempDate =[lastDate dateByAddingTimeInterval:-(i*24*60*60)];
            [sevenDays addObject:tempDate];
            NSString *parsedTempDate = [dateFormat stringFromDate:tempDate];
            [sevenDaysStringtemp addObject:parsedTempDate];
        }
        
        //find valid dates in most recent 7 days
        NSMutableArray *validSampleList = [[NSMutableArray alloc] init];
        for (HKQuantitySample *sample in HKSampleLists) {
            
            NSString *sampleDate = [dateFormat stringFromDate:sample.startDate];
            // if there is already record in sevenday (There is same day record in it)
            if ([sevenDaysStringtemp containsObject:sampleDate]) {
                if (![sevenDaysString containsObject:sampleDate]){
                    [sevenDaysString addObject:sampleDate];
                    [validSampleList addObject:sample];
                }
                
            }
        }
        
        HKUnit *weightUnit = [HKUnit poundUnit];
        for (HKQuantitySample *sample  in validSampleList) {
            NSNumber *number = [NSNumber numberWithFloat:[[sample quantity] doubleValueForUnit:weightUnit]];
            [dataArray addObject:number];
        }
    }
    
    // no record in healthkit
    else if ( number == 0){
        lastDate = [NSDate date];
        [sevenDaysString addObject:[dateFormat stringFromDate:lastDate]];
        for(int i = 1; i < 7; i++){
            NSDate *tempDate =[lastDate dateByAddingTimeInterval:-(i*24*60*60)];
            [sevenDays addObject:tempDate];
            NSString *parsedTempDate = [dateFormat stringFromDate:tempDate];
            [sevenDaysString addObject:parsedTempDate];
        }
        NSNumber *numberZero = [[NSNumber alloc] initWithFloat:0.00];
        dataArray = [NSMutableArray arrayWithObjects:numberZero,numberZero,numberZero,numberZero,numberZero,numberZero,numberZero, nil];
    }
    
    //reverser the value of two array
    NSArray* reversedDate = [[sevenDaysString reverseObjectEnumerator] allObjects];
    NSArray* reversedData = [[dataArray reverseObjectEnumerator] allObjects];
    
    
    
    // the goal line
    NSArray *listFromCoreData = [self getFetchRequestWithEntity:@"CoreDataHostInfo"];
    NSUInteger i = [listFromCoreData count];
    NSMutableArray *goalLine = [[NSMutableArray alloc] init];
    if (i == 0) {
        NSLog(@"There is no goal right now");
    } else {
        CoreDataHostInfo *mainHost = [listFromCoreData objectAtIndex:0];
       
        if ([mainHost goal]!= nil) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            NSNumber * goal = [f numberFromString: [mainHost goal] ];
            
            for (int  i = 0; i < [reversedDate count]; i++) {
                [goalLine addObject:goal];
            }
        }

    }
    
    
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 60.0, SCREEN_WIDTH, 200.0)];
    [lineChart setXLabels:reversedDate];
    
    // Line Chart No.1
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = PNFreshGreen;
    data01.itemCount = lineChart.xLabels.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [reversedData[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    // Line Chart No.2 (Goal line)
    // there is goal in core data
    if ([goalLine count] > 0){
        PNLineChartData *data02 = [PNLineChartData new];
        data02.color = PNTwitterColor;
        data02.lineWidth = 1;
        data02.alpha = 0.5;
        data02.itemCount = lineChart.xLabels.count;
        data02.getData = ^(NSUInteger index) {
            CGFloat yValue = [goalLine[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        lineChart.chartData = @[data01, data02];
    } else {
        lineChart.chartData = @[data01];
    }
    
    [lineChart strokeChart];
    
    [self.segmentView addSubview:lineChart];
    
}

#pragma mark pet set
- (BOOL)whetherPetSet {
    NSArray *petList = [self getFetchRequestWithEntity:@"CoreDataPetInfo"];
    if ([petList count] == 0) {
        return NO;
    } else {
        return YES;
    }
}

//-(void) showtableTest {
//
//        PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 60.0, SCREEN_WIDTH, 200.0)];
//        [lineChart setXLabels:@[@"one",@"two",@"three",@"four"]];
//
//        // Line Chart No.1
//        NSArray * data01Array = @[@60.1, @160.1, @126.4, @262.2];
//        PNLineChartData *data01 = [PNLineChartData new];
//        data01.color = PNFreshGreen;
//        data01.itemCount = lineChart.xLabels.count;
//        data01.getData = ^(NSUInteger index) {
//            CGFloat yValue = [data01Array[index] floatValue];
//            return [PNLineChartDataItem dataItemWithY:yValue];
//        };
//        // Line Chart No.2
//        NSArray * data02Array = @[@20.1, @180.1, @26.4, @202.2];
//        PNLineChartData *data02 = [PNLineChartData new];
//        data02.color = PNTwitterColor;
//        data02.itemCount = lineChart.xLabels.count;
//        data02.getData = ^(NSUInteger index) {
//            CGFloat yValue = [data02Array[index] floatValue];
//            return [PNLineChartDataItem dataItemWithY:yValue];
//        };
//
//        lineChart.chartData = @[data01, data02];
//        [lineChart strokeChart];
//       [self.segmentView addSubview:lineChart];
//
//}
-(void)showCharByPet {
    
    // whether there is a pet in record
    if ([self whetherPetSet]) {
        NSLog(@"There is pet in core data");
        
        // the user has update record in within today minutes
        if ([self isTheUserHasUpdateTodayWeight]) {
            NSArray *petList = [self getFetchRequestWithEntity:@"WeightRecords"];
            // there is no pet record in database
            if ([petList count] == 0) {
                PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 60.0, SCREEN_WIDTH, 200.0)];
                [lineChart strokeChart];
                [self.segmentView addSubview:lineChart];
                
                // show data into chart
            } else{
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MM-dd"];
                PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 60.0, SCREEN_WIDTH, 200.0)];
                NSMutableArray *dateStringArray = [[NSMutableArray alloc] init];
                NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < [petList count]; i ++) {
                    NSString *lastDateString = [dateFormat stringFromDate:[[petList objectAtIndex:i] createdDate]];
                    [dateStringArray addObject: lastDateString];
                    [dataArray addObject:[[petList objectAtIndex:i] weightRecord]];
                }
                
                [lineChart setXLabels:dateStringArray];
                
                // Line Chart No.1
                
                PNLineChartData *data01 = [PNLineChartData new];
                data01.color = PNFreshGreen;
                data01.itemCount = lineChart.xLabels.count;
                data01.getData = ^(NSUInteger index) {
                    CGFloat yValue = [dataArray[index] floatValue];
                    return [PNLineChartDataItem dataItemWithY:yValue];
                };
                lineChart.chartData = @[data01];
                [lineChart strokeChart];
                [self updateLabelWithPet:[dataArray objectAtIndex:0]];
                [self.segmentView addSubview:lineChart];
                
                
                
            }
            // the user has not update he or she current weight
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                            message:@"Please update your today weight first."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        // there is no pet in record
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                        message:@"Please create your pet information first."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

-(BOOL)isTheUserHasUpdateTodayWeight{
    NSInteger number = [HKSampleLists count];
    NSDate *lastDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd"];
    
    if ([HKSampleLists count] > 0) {
        HKQuantitySample *hkSample = [HKSampleLists objectAtIndex:0];
        lastDate = [hkSample startDate];
        if (number > 0) {
            lastDate = [hkSample startDate];
            NSString *lastDateString = [dateFormat stringFromDate:lastDate];
            NSString *currentDateString = [dateFormat stringFromDate:[NSDate date]];
            
            // there is updated date
            if ([lastDateString isEqualToString:currentDateString]) {
                NSLog(@"The user had updated its weight");
                return YES;
            } else {
                NSLog(@"The user had not updated its weight");
                return NO;
            }
        }
        NSLog(@"The user had not updated its weight");
        return NO;
    }
    return NO;
    
}


-(void)updateLabelWithPet: weight {
    if ([HKSampleLists count] > 0) {
        HKQuantitySample *hkSample = [HKSampleLists objectAtIndex:0];
        HKUnit *weightUnit = [HKUnit poundUnit];
        NSNumber *currentHostWeight = [NSNumber numberWithFloat:[[hkSample quantity] doubleValueForUnit:weightUnit]];
        int currentHostWeightInt = [currentHostWeight intValue];
        int currentPetWeight = [weight intValue];
        int sum = currentHostWeightInt + currentPetWeight;
        self.weightNumberLabel.text = [NSString stringWithFormat:@"%d", sum];
        NSLog(@"updateLable");
    }
    
}

-(NSString*)getPetCurrentWeight{
    NSArray *petList = [self getFetchRequestWithEntity:@"WeightRecords"];
    if ([petList count] > 0) {
        WeightRecords *wr = [petList objectAtIndex:0];
        return [wr weightRecord];
    }
    return @"0";

}

#pragma mark set up system

-(void) setUpGenderAndBirthday {
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
    
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(NSArray *mostRecentQuantity, NSError *error) {
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully and the error is %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"failed");
            });
        }
        else {
            //set the result from healthkit to local variable
            self.HKSampleLists = mostRecentQuantity;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getCharWithGender : gender dob : dateOfBirth];
                
            });
            
        }
    }];
    
}

-(void)showCharBasedOnDataFromHealthKit {
    
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(NSArray *mostRecentQuantity, NSError *error) {
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully and the error is %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"failed");
            });
        }
        else {
            //set the result from healthkit to local variable
            self.HKSampleLists = mostRecentQuantity;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showChartByDay];
            });
        }
    }];
    
    
    
}

-(void)getCharWithGender:gender dob:dateOfBirth {
    NSError *error = nil;
    NSArray *userList = [self getFetchRequestWithEntity:@"CoreDataHostInfo"];
    // no user log in this app before
    if ([userList count] == 0) {
        CoreDataHostInfo *core = [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataHostInfo" inManagedObjectContext:self.managedObjectContext];
        
        core.gender = gender;
        core.birthday = dateOfBirth;
        if (![[self managedObjectContext]save:&error]) {
            NSLog(@"Error with %@", error);
        } else {
            NSLog(@"success");
        }
    }
    
}

- (void)updateUsersWeightLabel {
    // Fetch the user's default weight unit in pounds.
    NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
    massFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    NSMassFormatterUnit weightFormatterUnit = NSMassFormatterUnitPound;
    NSString *weightUnitString = [massFormatter unitStringFromValue:10 unit:weightFormatterUnit];
    NSString *localizedWeightUnitDescriptionFormat = NSLocalizedString(@"Weight (%@)", nil);
    
    
    // self.weightNumberLabel.text = [NSString stringWithFormat:localizedWeightUnitDescriptionFormat, weightUnitString];
    
    // Query to get the user's latest weight, if it exists.
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    [self.healthStore aapl_oneQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.");
            
        }
        else {
            // Determine the weight in the required unit.
            HKUnit *weightUnit = [HKUnit poundUnit];
            double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
            //double finalUserWeight = usersWeight *100 /100;
            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
                self.weightNumberLabel.text = [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle];
            });
        }
    }];
}



#pragma mark ask for user authorization

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
                //[self readNecessaryDataFromHealthKit];
                //[self showCharBasedOnDataFromHealthKit];
                //[self updateUsersWeightLabel];
                //[self setUpGenderAndBirthday];
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



@end
