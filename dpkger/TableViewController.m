//
//  TableViewController.m
//  dpkger
//
//  Created by ipad_kid on 8/26/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalManager.h"
#import "ParserViewController.h"
#import "DirTableCellView.h"

@interface TableViewController : UITableViewController
@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, strong) NSArray *filesAtPath;
- (void)done;
@end

@implementation TableViewController
NSMutableDictionary<NSString *, NSNumber *> *fileList;
- (void)viewDidLoad {
    [super viewDidLoad];
    [GlobalManager.manager initDict];
    fileList = GlobalManager.manager.fileList;
    if (!self.currentPath) self.currentPath = @"/";
    
    self.filesAtPath = [NSFileManager.defaultManager contentsOfDirectoryAtPath:self.currentPath error:NULL];
    self.navigationItem.title = self.currentPath.lastPathComponent;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    if (fileList[self.currentPath] && self.filesAtPath.count) {
        for (NSString *newPath in self.filesAtPath) [fileList setValue:@1 forKey:[self.currentPath stringByAppendingPathComponent:newPath]];
        [fileList removeObjectForKey:self.currentPath];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filesAtPath.count;
}

- (NSString *)pathAtIndexPath:(NSIndexPath *)indexPath {
    NSString *dirObject = [self.filesAtPath objectAtIndex:indexPath.row];
    NSString *fullPath = [self.currentPath stringByAppendingPathComponent:dirObject];
    return fullPath;
}

- (BOOL)isDirAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [self pathAtIndexPath:indexPath];
    BOOL isDir;
    [NSFileManager.defaultManager fileExistsAtPath:path isDirectory:&isDir];
    return isDir;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *dirObject = [self.filesAtPath objectAtIndex:indexPath.row];
    NSString *fullPath = [self.currentPath stringByAppendingPathComponent:dirObject];
    
    DirTableCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = dirObject;
    cell.fullPath = fullPath;
    BOOL isDir;
    [NSFileManager.defaultManager fileExistsAtPath:fullPath isDirectory:&isDir];
    cell.isDir = isDir;
    if (isDir) cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else if (fileList[fullPath]) cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    DirTableCellView *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *fullPath = cell.fullPath;
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
//    DirTableCellView *cell = [tableView cellForRowAtIndexPath:indexPath];
//    return cell.isDir;
    BOOL isDir = [self isDirAtIndexPath:indexPath];
    return isDir;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DirTableCellView *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *fullPath = cell.fullPath;
    if (cell.isDir) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"File" bundle:nil];
        TableViewController *newViewController = [storyboard instantiateViewControllerWithIdentifier:@"File"];
        
        newViewController.currentPath = fullPath;
        [self.navigationController pushViewController:newViewController animated:YES];
    } else {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [fileList setValue:@1 forKey:fullPath];
        } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [fileList removeObjectForKey:fullPath];
        } else NSLog(@"Bug");
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)done {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Parser" bundle:nil];
    ParserViewController *newViewController = [storyboard instantiateViewControllerWithIdentifier:@"Parser"];
    [self.navigationController pushViewController:newViewController animated:YES];
}

@end
