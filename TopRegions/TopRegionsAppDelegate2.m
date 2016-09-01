//
//  AppDelegate.m
//  TopRegions
//
//  Created by Daniel Springer on 3/14/16.
//  Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

#import "TopRegionsAppDelegate2.h"
#import "CreateContext.h"

@interface TopRegionsAppDelegate2()

@property (strong, nonatomic) NSManagedObjectContext* photoDatabaseContext;

@end

#define FLICKR_FETCH @"Flickr Just Uploaded Fetch"

#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)

@implementation TopRegionsAppDelegate2

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    CreateContext *context = [[CreateContext alloc] init];
    
    //self.photoDatabaseContext = [context generateContext];
    
    //[self startFlickrFetch];
    
    return YES;
}

@end
