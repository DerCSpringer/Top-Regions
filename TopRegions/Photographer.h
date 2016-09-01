//
//  Photographer.h
//  TopRegions
//
//  Created by Daniel Springer on 3/24/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Region;

@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *regionsWherePhotosAreTaken;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addRegionsWherePhotosAreTakenObject:(Region *)value;
- (void)removeRegionsWherePhotosAreTakenObject:(Region *)value;
- (void)addRegionsWherePhotosAreTaken:(NSSet *)values;
- (void)removeRegionsWherePhotosAreTaken:(NSSet *)values;

@end
