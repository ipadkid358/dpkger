//
//  GlobalManager.h
//  dpkger
//
//  Created by ipad_kid on 9/16/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalManager : NSObject {
    NSMutableDictionary<NSString *, NSNumber *> *fileList;
}

@property (nonatomic, retain, readwrite) NSMutableDictionary<NSString *, NSNumber *> *fileList;
+ (instancetype)manager;
- (void)initDict;
@end
