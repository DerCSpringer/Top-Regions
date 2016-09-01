//
//  Region+Create.m
//  TopRegions
//
//  Created by Daniel Springer on 3/18/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "Region+Create.h"
#import "Photographer+Create.h"
#import "FlickrFetcher.h"
@implementation Region (Create)


/*
+(Region *)regionWithName:(NSString *)name
         withPhotographer:(NSString *)photographer
   inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    
    Region *region = nil;
    
    if ([name length]) {
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        //Returns an array matching the request in the context.
        
        if (!matches || error || ([matches count] > 1)) {
            //handle error
        }
        
        else if (![matches count])
        {
            region = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                   inManagedObjectContext:context];
            region.name = name;
            region.numberOfPhotographersInRegion = [NSNumber numberWithInt:1];
            //Sets region name and count = 1 if a region doesn't exist in the Region entity yet
        }
        else
        {
            region  = [matches firstObject];
            int regionCount = [region.numberOfPhotographersInRegion integerValue] + 1;
            region.numberOfPhotographersInRegion = [NSNumber numberWithInt:regionCount];
            //Increses the number of photographers in a region if the region already exists
            
        }
    }
    
    if ([photographer length]) {
        
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"photographersInRegion.name = %@", photographer];
    NSError *error;

    NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || error || ([matches count] > 1)) {
            //handle error
        }
        
        else if (![matches count])
        {
            [region addPhotographersInRegionObject:[Photographer photographerWithName:<#(NSString *)#> inManagedObjectContext:<#(NSManagedObjectContext *)#>]
            
            
            
            //NEed to add a photographer
        }
#warning Should this all be called from Photo+Flickr?  It doesn't make much sense.  Should I return anything? How do I know when I should use an import statement.  Should I put that all in one class?
        else
        {
            region  = [matches firstObject];
            int regionCount = [region.numberOfPhotographersInRegion integerValue] + 1;
            region.numberOfPhotographersInRegion = [NSNumber numberWithInt:regionCount];
            //Increses the number of photographers in a region if the region already exists
            
        }
        
    }
    
    
    return region;
}

*/


+(Region *)regionWithFlickrInfo:(NSDictionary *)photoDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    Region *region = nil;
    NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
    Photographer *photographer = [Photographer photographerWithName:photographerName inManagedObjectContext:context];
    
    
    NSString *regionName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_REGION];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", regionName];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handle error
    }
    
    else if ([matches count])//If a region is already created in the database it checks to see if the specified photographer has taken photos in the region.  If he hasn't it adds the photographer to photographersInRegion
    {
        region = [matches firstObject];
        if (![region.photographersInRegion containsObject:photographer]) {
            int x = [region.photographerCount intValue];
            x++;
            region.photographerCount = [NSNumber numberWithInt:x];
            [region addPhotographersInRegionObject:[Photographer photographerWithName:photographerName inManagedObjectContext:context]];
        }
    }
    
    else //create region with attributes
    {
        region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:context];
        region.name = regionName;
        region.photographerCount = [NSNumber numberWithInt:1];
        [region addPhotographersInRegionObject:[Photographer photographerWithName:photographerName inManagedObjectContext:context]];
    }
    
    
    
    return region;
}



+(void)loadRegionsFromFlickrArray:(NSArray *)regions
         intoManagedObjectContext:(NSManagedObjectContext *)context //Of Flickr NSDictionary
{
    for (NSDictionary *region in regions) {
        [self regionWithFlickrInfo:region inManagedObjectContext:context];
    }
}


@end
