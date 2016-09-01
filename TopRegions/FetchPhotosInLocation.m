//
//  JustPostedFlickrPhotosTVC.m
//  TopRegions
//
//  Created by Daniel Springer on 2/5/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "FetchPhotosInLocation.h"
#import "FlickrFetcher.h"

@interface FetchPhotosInLocation ()

@end

@implementation FetchPhotosInLocation



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotos];
}

-(IBAction)fetchPhotos
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher 2", NULL); //NUll means serial q
    dispatch_async(fetchQ, ^{
        NSData *jsonResult = [NSData dataWithContentsOfURL:self.locationURL];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                            options:0 error:NULL];
        NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        //Just created our own q above and go back to main q to display the photo
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        self.photos = photos;
        });
        
    });
}


@end
