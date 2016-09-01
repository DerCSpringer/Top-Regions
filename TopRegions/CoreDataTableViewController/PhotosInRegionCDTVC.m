//
//  PhotosInRegionCDTVC.m
//  TopRegions
//
//  Created by Daniel Springer on 3/30/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "PhotosInRegionCDTVC.h"
#import "Photo.h"
#import "TopPlacesHelper.h"
#import "ImageViewController.h"

@interface PhotosInRegionCDTVC ()

@end

@implementation PhotosInRegionCDTVC



- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void)setContext:(NSManagedObjectContext *)context
{
    
    _context = context;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"region = %@", self.title];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"region"
                                                              ascending:NO
                                                               selector:@selector(compare:)]];
    
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    photo.date = [NSDate date];

    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    if ([detail isKindOfClass:[ImageViewController class]]) {
        [self prepareImageViewController:detail toDisplayPhoto:photo];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Display Photos"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [TopPlacesHelper titleForPhoto:photo];
    
    if (!photo.thumbnailPhoto) {
        
        [TopPlacesHelper fetchThumbnail:photo];
    }
    
    cell.imageView.image = [UIImage imageWithData:photo.thumbnailPhoto];
    
    return cell;
    
}

-(void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(Photo *)photo
{
    ivc.imageURL = [NSURL URLWithString:photo.imageURL];
    ivc.title = [TopPlacesHelper titleForPhoto:photo];
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"Display Photo"]) {
            if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                [self prepareImageViewController:segue.destinationViewController
                                  toDisplayPhoto:photo];
            }
        }
    }
}

@end
