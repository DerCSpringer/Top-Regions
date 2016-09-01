//
//  Photo+Flickr.h
//  TopRegions
//
//  Created by Daniel Springer on 3/14/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)


//Adds a Photo dictionary into CoreData
+(Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;


//Batch loads a bunch of Photos from Flickr
+(void)loadPhotosFromFlickrArray:(NSArray *)photos //Of Flickr NSDictionary
           intoManagedObjectContext:(NSManagedObjectContext *)context;


@end
