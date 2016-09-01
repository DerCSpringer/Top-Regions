//
//  PhotographersCDTVC.m
//  TopRegions
//
//  Created by Daniel Springer on 3/14/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "PhotographersCDTVC.h"
#import "Photographer.h"
#import "Region.h"
#import "PhotoDatabaseAvailability.h"
#import "PhotosInRegionCDTVC.h"


@implementation PhotographersCDTVC

- (void)awakeFromNib
{
    
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
    
    //Checks for notifications on Photodatabse...  then it sets the managedObjectContext to this userinfo note(NSDictionary)
}


//If we get a photo we can get it's context via managedobjectContext method
-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
 
    _managedObjectContext = managedObjectContext;
    
    
    NSSortDescriptor *countSort = [NSSortDescriptor sortDescriptorWithKey:@"photographerCount"
                                                                ascending:NO
                                                                 selector:@selector(compare:)];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                ascending:YES
                                                                 selector:@selector(localizedStandardCompare:)];
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    
    request.predicate = nil;//Fetches all regions
    request.sortDescriptors = @[countSort, nameSort];
    
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Region Cell"];
    
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = region.name;
    
    if ([region.photographersInRegion count] == 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photographer in the region", [region.photographerCount intValue]];
    }
    
    else
    {
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photographers in the region", [region.photographerCount intValue]];
    }
    
    
    return cell;
    
}

#pragma mark - Navigation

//I need to send a context to the pircdtvc and a title(region will be the title)
-(void)preparePhotosInRegionCDTVC:(PhotosInRegionCDTVC *)pircdtvc forRegion:(Region *)region
{
    pircdtvc.title = region.name;
    pircdtvc.context = [region managedObjectContext];
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"Display Photos in Region"]) {
            if ([segue.destinationViewController isKindOfClass:[PhotosInRegionCDTVC class]]) {
                [self preparePhotosInRegionCDTVC:segue.destinationViewController forRegion:region];
            }
        }
    }
}
@end
