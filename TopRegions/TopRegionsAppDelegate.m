//
//  TopRegionsAppDelegate.m
//  TopRegions
//
//  Created by Daniel Springer on 2/5/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "TopRegionsAppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "Region+Create.h"
#import "PhotoDatabaseAvailability.h"
#import "CreateContext.h"

// THIS FILE WANTS TO BE VERY WIDE BECAUSE IT HAS A LOT OF COMMENTS THAT ARE ATTACHED ONTO THE END OF LINES--MAKE THIS COMMENT FIT ON ONE LINE
// (or turn off line wrapping)

@interface TopRegionsAppDelegate() <NSURLSessionDownloadDelegate>
@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;
@property (strong, nonatomic) NSManagedObjectContext *photoDatabaseContext;
@property (strong ,nonatomic) NSMutableDictionary *regions;//Dictionary of regions with their ID this will speed thing up so I don't have to fetch regions for every ID
@end

// name of the Flickr fetching background download session
#define FLICKR_FETCH @"Flickr Just Uploaded Fetch"

#define FLICKR_ID_FETCH @"Flickr Just IDed a Photo"

// how often (in seconds) we fetch new photos if we are in the foreground
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)

// how long we'll wait for a Flickr fetch to return when we're in the background
#define BACKGROUND_FLICKR_FETCH_TIMEOUT (10)

@implementation TopRegionsAppDelegate

#pragma mark - UIApplicationDelegate

// this is called as soon as our storyboard is read in and we're ready to get started
// but it's still very early in the game (UI is not yet on screen, for example)

- (NSMutableDictionary *)regions
{
    if (!_regions) _regions = [[NSMutableDictionary alloc] init];
    return _regions;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // when we're in the background, fetch as often as possible (which won't be much)
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [CreateContext generateContext];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.photoDatabaseContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
    
    
    
    // we fire off a Flickr fetch every time we launch (why not?)
    [self startFlickrFetch];
    
    // this return value has to do with handling URLs from other applications
    return YES;
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{

    // we don't want it to take too long because the system will start to lose faith in us as a background fetcher and stop calling this as much
    // so we'll limit the fetch to BACKGROUND_FETCH_TIMEOUT seconds (also we won't use valuable cellular data)

    if (self.photoDatabaseContext) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT; // want to be a good background citizen!
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos:250]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                    completionHandler(UIBackgroundFetchResultNoData);
                } else {
                    [self loadFlickrPhotosFromLocalURL:localFile
                                           intoContext:self.photoDatabaseContext
                                   andThenExecuteBlock:^{
                                       completionHandler(UIBackgroundFetchResultNewData);
                                   }
                     ];
                }
            }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData); // no app-switcher update if no database!
    }
}

// this is called whenever a URL we have requested with a background session returns and we are in the background
// it is essentially waking us up to handle it
// if we were in the foreground iOS would just call our delegate method and not bother with this

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    // this completionHandler, when called, will cause our UI to be re-cached in the app switcher
    // but we should not call this handler until we're done handling the URL whose results are now available
    // so we'll stash the completionHandler away in a property until we're ready to call it
    // (see flickrDownloadTasksMightBeComplete for when we actually call it)
    self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}

#pragma mark - Database Context

// we do some stuff when our Photo database's context becomes available
// we kick off our foreground NSTimer so that we are fetching every once in a while in the foreground
// we post a notification to let others know the context is available

- (void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext
{
    _photoDatabaseContext = photoDatabaseContext;
    
    // every time the context changes, we'll restart our timer
    // so kill (invalidate) the current one
    [self.flickrForegroundFetchTimer invalidate];
    self.flickrForegroundFetchTimer = nil;
    
    if (self.photoDatabaseContext)
    {
        // this timer will fire only when we are in the foreground
        self.flickrForegroundFetchTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL
                                         target:self
                                       selector:@selector(startFlickrFetch:)
                                       userInfo:nil
                                        repeats:YES];
    }
    
    // let everyone who might be interested know this context is available
    // this happens very early in the running of our application
    // it would make NO SENSE to listen to this radio station in a View Controller that was segued to, for example
    // (but that's okay because a segued-to View Controller would presumably be "prepared" by being given a context to work in)
    
    
    /*
    NSDictionary *userInfo = self.photoDatabaseContext ? @{ PhotoDatabaseAvailabilityContext : self.photoDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
     */
    
    
}

#pragma mark - Flickr Fetching

// this will probably not work (task = nil) if we're in the background, but that's okay
// (we do our background fetching in performFetchWithCompletionHandler:)
// it will always work when we are the foreground (active) application


//This uses flickrDOwnloadSession(NSURLSession).
- (void)startFlickrFetch
{
    // getTasksWithCompletionHandler: is ASYNCHRONOUS
    // but that's okay because we're not expecting startFlickrFetch to do anything synchronously anyway
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        //Are we working on a fetch?
        if (![downloadTasks count]) {
            // if not working on a fetch, let's start one up
           // NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos:20]];
            
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos:250]];
             
            
            task.taskDescription = FLICKR_FETCH;
                                              
            [task resume];
        } else {
            // we are working on a fetch let's make sure it is running while we're here
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}
/*
-(void)startRegionID:(NSURL *)url
{
    
    NSMutableArray *photosWithRegions = [[NSMutableArray alloc] init];
    NSArray *photos = [self flickrPhotosAtURL:url];
    dispatch_queue_t fetchQ = dispatch_queue_create("region fetcher", DISPATCH_QUEUE_CONCURRENT); //NUll means serial q
    dispatch_async(fetchQ, ^{
#warning fix this it's so slow.  Concurrent seems to speed it up.  I want to put FLICKR_PHOTO_PLACE_IDs in the core data and see if it's in there if it is then just use that location.  Will speed this up.  I also should look into the other program to see if I can do this without dispatch_queue_t use the other method in this TopREgionsAppDelegate Class.
        
        for (NSDictionary *photo in photos) {
            NSMutableDictionary *regionInfo = [[NSMutableDictionary alloc] init];
            
            
            NSData *jsonResult = [NSData dataWithContentsOfURL:[FlickrFetcher URLforInformationAboutPlace:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]]];
            NSDictionary *region = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                   options:0
                                                                     error:NULL];
            NSLog(@"place id: %@", [photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]);
            [regionInfo addEntriesFromDictionary:photo];
            [regionInfo setObject:[FlickrFetcher extractRegionNameFromPlaceInformation:region] forKey:@"region"];
            [photosWithRegions addObject:regionInfo];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            
        });
        
    });
    



    /*
    NSMutableArray *photosWithRegions = [[NSMutableArray alloc] init];
    NSArray *photos = [self flickrPhotosAtURL:url]
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        // let's see if we're already working on a fetch ...
        for (NSDictionary *photo in photos) {
            NSMutableDictionary *regionInfo = [[NSMutableDictionary alloc] init];
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforInformationAboutPlace:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]]];

            NSData *jsonResult = [NSData dataWithContentsOfURL:[FlickrFetcher URLforInformationAboutPlace:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]]];
            NSDictionary *region = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                   options:0
                                                                     error:NULL];
            NSLog(@"place id: %@", [photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]);
            [regionInfo addEntriesFromDictionary:photo];
            [regionInfo setObject:[FlickrFetcher extractRegionNameFromPlaceInformation:region] forKey:@"region"];
            [photosWithRegions addObject:regionInfo];
            
        }

        
        }
    }];
}

*/

- (void)startFlickrFetch:(NSTimer *)timer // NSTimer target/action always takes an NSTimer as an argument
{
    [self startFlickrFetch];
}

// the getter for the flickrDownloadSession @property

- (NSURLSession *)flickrDownloadSession // the NSURLSession we will use to fetch Flickr data in the background
{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken; // dispatch_once ensures that the block will only ever get executed once per application launch
        dispatch_once(&onceToken, ^{
            // "backgroundSessionConfiguration:"
            //  means that we will (eventually) get the results even if we are not the foreground application
            // even if our application crashed, it would get relaunched (eventually) to handle this URL's results!
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self    // we MUST have a delegate for background configurations
                                                              delegateQueue:nil];   // nil means "a random, non-main-queue queue"
        });
    }
    return _flickrDownloadSession;
}

// standard "get photo information from Flickr URL" code

- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];  // will block if url is not local!
    if (flickrJSONData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                             options:0
                                                               error:NULL];
    }
    
    
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

// gets the Flickr photo dictionaries out of the url and puts them into Core Data
//Takes a block as an argument
// and because we now do this both as part of our background session delegate handler and when background fetch happens

- (void)loadFlickrPhotosFromLocalURL:(NSURL *)localFile
                         intoContext:(NSManagedObjectContext *)context
                 andThenExecuteBlock:(void(^)())whenDone
{
    
    NSMutableArray *photosWithRegions = [[NSMutableArray alloc] init];
    if (context) {
        NSArray *photos = [self flickrPhotosAtURL:localFile];
        [context performBlock:^{
            dispatch_queue_t fetchQ = dispatch_queue_create("region fetcher", DISPATCH_QUEUE_CONCURRENT); //NUll means serial q
            dispatch_async(fetchQ, ^{

                
                for (NSDictionary *photo in photos) {

                    NSMutableDictionary *regionInfo = [[NSMutableDictionary alloc] init];
                    
                    if ([self.regions  objectForKey:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]]) {
                        [regionInfo addEntriesFromDictionary:photo];
                        [regionInfo setObject:[self.regions objectForKey:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]] forKey:@"region"];
                        [photosWithRegions addObject:regionInfo];
                        
                        NSLog(@"%i", [photos indexOfObject:photo]);
                        continue;
                        
                        //This looks to see if our region dictionary contains the FLICKR_PHOTO_PLACE_ID.  If it contains it it sets the region info instead of fetching the info from flickr.  Many regions are repeated only about 5% are unique.
                    }
                    
                    NSData *jsonResult = [NSData dataWithContentsOfURL:[FlickrFetcher URLforInformationAboutPlace:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]]];
                    NSDictionary *region = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                           options:0
                                                                             error:NULL];
                    if ([FlickrFetcher extractRegionNameFromPlaceInformation:region] == nil) {
                        continue;
                    }
                    [self.regions setObject:[FlickrFetcher extractRegionNameFromPlaceInformation:region] forKey:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]];
                    NSLog(@"place id: %@", [photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]);
                    [regionInfo addEntriesFromDictionary:photo];
                    [regionInfo setObject:[FlickrFetcher extractRegionNameFromPlaceInformation:region] forKey:@"region"];
                    [photosWithRegions addObject:regionInfo];
                    //Fetches flickr region info and puts it into the photo dictionary.
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Photo loadPhotosFromFlickrArray:photosWithRegions intoManagedObjectContext:context];
                    [Region loadRegionsFromFlickrArray:photosWithRegions intoManagedObjectContext:context];
                    //[context save:NULL]; // NOT NECESSARY if this is a UIManagedDocument's context
                    if (whenDone) whenDone();
                    
                    
                });
                
            });
            
            
            
        }];
    } else {
        if (whenDone) whenDone();
    }
}

#pragma mark - NSURLSessionDownloadDelegate
// required by the protocol
// these delegate methods are only for the background download
        
//This looks to be the delegate that I call above
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    // we shouldn't assume we're the only downloading going on ...
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        // ... but if this is the Flickr fetching, then process the returned data
        [self loadFlickrPhotosFromLocalURL:localFile
                               intoContext:self.photoDatabaseContext
                       andThenExecuteBlock:^{
                           [self flickrDownloadTasksMightBeComplete];
                       }
         ];
    }
    
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // we don't support resuming an interrupted download task
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // we don't report the progress of a download in our UI, but this is a cool method to do that with
}

// not required by the protocol, but we should definitely catch errors here
// and also so that we can detect that download tasks are (might be) complete
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error && (session == self.flickrDownloadSession)) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
        [self flickrDownloadTasksMightBeComplete];
    }
}

// this is "might" in case some day we have multiple downloads going on at once

- (void)flickrDownloadTasksMightBeComplete
{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            // we're doing this check for other downloads just to be theoretically "correct"
            //  but we don't actually need it (since we only ever fire off one download task at a time)
            // in addition getTasksWithCompletionHandler: is ASYNCHRONOUS
            //  so we must check again when the block executes if the handler is still not nil
            //  (another thread might have sent it already in a multiple-tasks-at-once implementation)
            if (![downloadTasks count]) {  // any more Flickr downloads left?
                // nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            } // else other downloads going, so let them call this method when they finish
        }];
    }
}

@end