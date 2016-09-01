//
//  Photographer+Create.h
//  TopRegions
//
//  Created by Daniel Springer on 3/14/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)



+(Photographer *)photographerWithName:(NSString *)name
               inManagedObjectContext:(NSManagedObjectContext *)context;


/*
+(Photographer *)photographerWithFlickrInfo:(NSDictionary *)photoDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;
 */
@end
