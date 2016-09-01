//
//  RecentPhotosCDTVC.m
//  TopRegions
//
//  Created by Daniel Springer on 4/7/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "RecentPhotosCDTVC.h"
#import "PhotoDatabaseAvailability.h"

@interface RecentPhotosCDTVC ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation RecentPhotosCDTVC



-(void)awakeFromNib
{

    [super awakeFromNib];
    //Does work notificaiton was sent out before viewDidLoad
    //AwakeFromNib Seems to call even if view isn't on screen.  Maybe only works for top views?
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
 
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    
    // Specify criteria for filtering which objects to fetch
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                                   ascending:NO];
    request.predicate = [NSPredicate predicateWithFormat:@"date != nil"];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    if (self.managedObjectContext != nil) {
        
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    }
    
}


@end
