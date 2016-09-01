//
//  Photo.h
//  TopRegions
//
//  Created by Daniel Springer on 4/7/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSDate * lastViewed;
@property (nonatomic, retain) NSString * photoDescription;
@property (nonatomic, retain) NSNumber * recent;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * thumbnailPhoto;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Photographer *whoTook;

@end
