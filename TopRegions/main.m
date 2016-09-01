//
//  main.m
//  TopRegions
//
//  Created by Daniel Springer on 3/14/16.
//  Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TopRegionsAppDelegate.h"

int main(int argc, char * argv[])
{
    
    //XHook up relationships between entities.  Only works for the whoTook field in photo right now
        //Seems to work now.  Didn't do anything just misread data in sql table viewer
    //X Display top regions and now just photographers names
    //Looking up placeinfo is taking way to long.  Look into that.
    //I've limited the number of photos queried to 10 to speed things up.
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([TopRegionsAppDelegate class]));
    }
}
