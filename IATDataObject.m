//
//  IATDataObject.m
//  Its A Trap
//
//  Created by Adam Canady on 6/1/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import "IATDataObject.h"

@implementation IATDataObject
@synthesize names;
@synthesize scores;

-(void) dealloc
{
    self.names = nil;
    self.scores = nil;
}

@end
