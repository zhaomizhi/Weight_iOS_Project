//
//  CoreDataPetInfo.h
//  
//
//  Created by 赵谜 on 5/1/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface CoreDataPetInfo : NSManagedObject

@property (nonatomic, retain) NSString * petName;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSSet *weightRecords;
@end

@interface CoreDataPetInfo (CoreDataGeneratedAccessors)

- (void)addWeightRecordsObject:(NSManagedObject *)value;
- (void)removeWeightRecordsObject:(NSManagedObject *)value;
- (void)addWeightRecords:(NSSet *)values;
- (void)removeWeightRecords:(NSSet *)values;

@end
