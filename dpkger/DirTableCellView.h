//
//  DirTableCellView.h
//  dpkger
//
//  Created by ipad_kid on 9/16/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirTableCellView : UITableViewCell
@property (weak) NSString *fullPath;
@property BOOL isDir;
@end
