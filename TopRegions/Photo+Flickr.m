//
//  Photo+Flickr.m
//  TopRegions
//
//  Created by Daniel Springer on 3/14/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"
#import "Region+Create.h"

@implementation Photo (Flickr)



//Adds a Photo dictionary into CoreData
+(Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    //Find or create photo in database
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handle error
    }
    
    else if ([matches count])
    {
        photo = [matches firstObject];
    }
    
    else //create photo with attributes
    {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = unique;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.region = [photoDictionary valueForKeyPath:FLICKR_PHOTO_REGION];
        photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        photo.photoDescription = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];

        //Won't need above statement unless the tableview displays the photo.title
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName inManagedObjectContext:context];
        //Creates region entity if needed or just adds to the count of photographers in a region if
        
        
    }
    
    
    
    return photo;
}

-(NSString *)regionNameInPhoto
{
    NSString *regionName = nil;
    
    
    
    
    
    
    return regionName;
}

-(void)fetchRegionInformation
{
    
    
}


//Batch loads a bunch of Photos from Flickr
+(void)loadPhotosFromFlickrArray:(NSArray *)photos //Of Flickr NSDictionary
           intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}



@end
