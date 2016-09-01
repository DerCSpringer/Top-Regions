//
//  Photographer+Create.m
//  TopRegions
//
//  Created by Daniel Springer on 3/14/16.
//  Copyright (c) 2016 Daniel Springer. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+(Photographer *)photographerWithName:(NSString *)name
               inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    
    Photographer *photographer = nil;
    
    if ([name length]) {
    
    
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || error || ([matches count] > 1)) {
            //handle error
        }
        
        else if (![matches count])
        {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:context];
            photographer.name = name;
            
            
        }
        else
        {
            photographer  = [matches firstObject];
            
        }
    }
    
    return photographer;
}



@end
