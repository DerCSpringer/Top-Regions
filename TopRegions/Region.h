//
//  Region.h
//  TopRegions
//
//  Created by Daniel Springer on 3/24/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSNumber * photographerCount;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *photographersInRegion;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotographersInRegionObject:(Photographer *)value;
- (void)removePhotographersInRegionObject:(Photographer *)value;
- (void)addPhotographersInRegion:(NSSet *)values;
- (void)removePhotographersInRegion:(NSSet *)values;

@end
