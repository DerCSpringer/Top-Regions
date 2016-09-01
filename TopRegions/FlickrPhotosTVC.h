//
//  FlickrPhotosTVC.h
//  TopRegions
//
//  Created by Daniel Springer on 2/5/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPhotosTVC : UITableViewController
@property (strong, nonatomic) NSArray *photos; //of flickr photo NSDictionary
@property (strong, nonatomic) NSURL *locationURL;

@end
