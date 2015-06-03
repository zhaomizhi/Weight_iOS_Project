//
//  CoreDataHostInfo.h
//  
//
//  Created by 赵谜 on 4/28/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreDataHostInfo : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * currentHeight;
@property (nonatomic, retain) NSString * goal;

@end
