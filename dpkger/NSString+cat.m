//
//  NSString+cat.m
//  dpkger
//
//  Created by ipad_kid on 9/16/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "NSString+cat.h"

@implementation NSString (BlackJacketPrivate)

- (BOOL)isDir {
    BOOL value;
    [NSFileManager.defaultManager fileExistsAtPath:self isDirectory:&value];
    return value;
}

- (char *)charStar {
    return (char *)self.UTF8String;
}
@end
