//
//  Region+Create.h
//  TopRegions
//
//  Created by Daniel Springer on 3/18/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "Region.h"

@interface Region (Create)


/*
+(Region *)RegionWithName:(NSString *)name
   inManagedObjectContext:(NSManagedObjectContext *)context;
 


+(Region *)regionWithName:(NSString *)name
         withPhotographer:(NSString *)photographer
   inManagedObjectContext:(NSManagedObjectContext *)context;


+(Region *)regionWithFlickrInfo:(NSDictionary *)photoDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;
 
 */

+(Region *)regionWithFlickrInfo:(NSDictionary *)photoDictionary
         inManagedObjectContext:(NSManagedObjectContext *)context;


+(void)loadRegionsFromFlickrArray:(NSArray *)regions intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
