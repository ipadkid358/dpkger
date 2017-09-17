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
    static GlobalManager *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil) sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

- (void)initDict {
    if (self.fileList == nil) self.fileList = NSMutableDictionary.new;
}
@end
