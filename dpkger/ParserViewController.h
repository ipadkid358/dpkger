//
//  ParserViewController.h
//  dpkger
//
//  Created by ipad_kid on 9/16/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParserViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *packageID;
@property (weak, nonatomic) IBOutlet UITextField *author;
@property (weak, nonatomic) IBOutlet UITextField *version;
@property (weak, nonatomic) IBOutlet UITextView *packDesc;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *dependencies;
@property (weak, nonatomic) IBOutlet UITextField *section;

- (void)saveGo;
@end
