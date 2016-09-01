//
//  ViewController.m
//  TopRegions
//
//  Created by Daniel Springer on 3/14/16.
//  Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"
#import "FlickrFetcher.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(IBAction)fetchPhotos
{
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher 2", NULL); //NUll means serial q
    dispatch_async(fetchQ, ^{
        NSURL *url = [FlickrFetcher URLforRecentGeoreferencedPhotos:20];
        NSData *jsonResult = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                            options:0 error:NULL];
        //Just created our own q above and go back to main q to display the photo
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", propertyListResults);
        });
        
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
