//
//  TableViewController.m
//  dpkger
//
//  Created by ipad_kid on 8/26/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalManager.h"
#import "NSString+cat.h"
#import "ParserViewController.h"

@interface TableViewController : UITableViewController
@property (nonatomic, strong) NSString *currentPath;
- (void)done;
@end

@implementation TableViewController {
    NSArray *filesAtPath;
    NSMutableDictionary<NSString *, NSNumber *> *fileList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.currentPath) {
        self.currentPath = @"/";
        [GlobalManager.manager initDict];
    }
    fileList = GlobalManager.manager.fileList;

    filesAtPath = [NSFileManager.defaultManager contentsOfDirectoryAtPath:self.currentPath error:NULL];
    self.navigationItem.title = self.currentPath.lastPathComponent;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    if (fileList[self.currentPath] && filesAtPath.count) {
        for (NSString *newPath in filesAtPath) [fileList setValue:@1 forKey:[self.currentPath stringByAppendingPathComponent:newPath]];
        [fileList removeObjectForKey:self.currentPath];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return filesAtPath.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *dirObject = [filesAtPath objectAtIndex:indexPath.row];
    NSString *fullPath = [self.currentPath stringByAppendingPathComponent:dirObject];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = dirObject;
    
    if (fullPath.isDir) cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else if (fileList[fullPath]) cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *fullPath = [self.currentPath stringByAppendingPathComponent:cell.textLabel.text];
    NSString *title = fileList[fullPath] ? @"Remove Entry" : @"Recursive Add";
    
    UITableViewRowAction *swipeButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:title handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        if (fileList[fullPath]) [fileList removeObjectForKey:fullPath];
        else [fileList setValue:@1 forKey:fullPath];
        [self.tableView setEditing:NO animated:YES];
    }];
    swipeButton.backgroundColor = UIColor.purpleColor;
    return @[swipeButton];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *fullPath = [self.currentPath stringByAppendingPathComponent:cell.textLabel.text];
    return fullPath.isDir;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *fullPath = [self.currentPath stringByAppendingPathComponent:cell.textLabel.text];
    if (fullPath.isDir) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"File" bundle:nil];
        TableViewController *newViewController = [storyboard instantiateViewControllerWithIdentifier:@"File"];
        
        newViewController.currentPath = fullPath;
        [self.navigationController pushViewController:newViewController animated:YES];
    } else {
        switch (cell.accessoryType) {
            case UITableViewCellAccessoryNone:
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [fileList setValue:@1 forKey:fullPath];
                break;
                
            case UITableViewCellAccessoryCheckmark:
                cell.accessoryType = UITableViewCellAccessoryNone;
                [fileList removeObjectForKey:fullPath];
                break;
                
            default:
                break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)done {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Parser" bundle:nil];
    ParserViewController *newViewController = [storyboard instantiateViewControllerWithIdentifier:@"Parser"];
    [self.navigationController pushViewController:newViewController animated:YES];
}

@end
