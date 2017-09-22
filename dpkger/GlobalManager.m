//
//  GlobalManager.m
//  dpkger
//
//  Created by ipad_kid on 9/16/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "GlobalManager.h"

@implementation GlobalManager
@synthesize fileList;

+ (instancetype)manager {
    static GlobalManager *manager = nil;
    @synchronized(self) {
        if (manager == nil) manager = [[self alloc] init];
    }
    return manager;
}

- (void)initDict {
    if (self.fileList == nil) self.fileList = NSMutableDictionary.new;
}
@end
