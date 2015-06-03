//
//  WeightRecords.h
//  
//
//  Created by 赵谜 on 5/1/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CoreDataPetInfo;

@interface WeightRecords : NSManagedObject

@property (nonatomic, retain) NSString * weightRecord;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) CoreDataPetInfo *coreDataPetInfo;

@end
