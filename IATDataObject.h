//
//  IATDataObject.h
//  Its A Trap
//
//  Created by Adam Canady on 6/1/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import "IATAppDataObject.h"

@interface IATDataObject : IATAppDataObject {
    NSMutableArray* scores;
    NSMutableArray* names;
}

@property (nonatomic, copy) NSMutableArray* scores;
@property (nonatomic, copy) NSMutableArray* names;

@end
