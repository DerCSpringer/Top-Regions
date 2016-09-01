//
//  testing.m
//  TopRegions
//
//  Created by Daniel Springer on 3/17/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "CreateContext.h"
#import "PhotoDatabaseAvailability.h"

@interface CreateContext()


@end


@implementation CreateContext


+(void)generateContext
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady:document];
            if (!success) NSLog(@"Couldn't open document at %@", url);
        }];
    } else {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) [self documentIsReady:document];
            if (!success) NSLog(@"couldn't create document at %@", url);
        }];
    }
        
    
}

+(void)documentIsReady:(UIManagedDocument *)document
{
    NSManagedObjectContext *context = nil;
    if (document.documentState == UIDocumentStateNormal) {
        context = document.managedObjectContext;
        NSDictionary *userInfo = context ? @{ PhotoDatabaseAvailabilityContext : context } : nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                            object:self
                                                          userInfo:userInfo];
        
    }
}



@end
