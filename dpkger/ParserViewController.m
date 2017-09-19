//
//  ParserViewController.m
//  dpkger
//
//  Created by ipad_kid on 9/16/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "ParserViewController.h"
#import "LoadingViewController.h"

@implementation ParserViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveGo)];
    self.navigationItem.rightBarButtonItem = done;
}

- (void)saveGo {
    [self becomeFirstResponder];
    [self.packageID resignFirstResponder];
    [self.version resignFirstResponder];
    [self.name resignFirstResponder];
    [self.author resignFirstResponder];
    [self.packDesc resignFirstResponder];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Loading" bundle:nil];
    LoadingViewController *newViewController = [storyboard instantiateViewControllerWithIdentifier:@"Loading"];
    [self.navigationController pushViewController:newViewController animated:YES];
}

@end
