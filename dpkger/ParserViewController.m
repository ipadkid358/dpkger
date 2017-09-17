//
//  ParserViewController.m
//  dpkger
//
//  Created by ipad_kid on 9/16/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalManager.h"
#import "ParserViewController.h"
#import "NSString+cat.h"
#include <spawn.h>

@implementation ParserViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *alertMessage = @"Please wait. Depending on the amount of files, and their sizes, this may take some time";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Setting up deb" message:alertMessage preferredStyle:1];
    [self presentViewController:alert animated:YES completion:^{
        NSArray *files = GlobalManager.manager.fileList.allKeys;
        NSString *appDocs =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *hashed = [NSString stringWithFormat:@"%lu", files.hash];
        self.stagingDir = [appDocs stringByAppendingPathComponent:hashed];
        NSFileManager *fileManager = NSFileManager.defaultManager;
        
        // TODO - validate stagingDir isn't copied into itself
        for (NSString *file in files) {
            NSString *stagedArea = [self.stagingDir stringByAppendingPathComponent:file.stringByDeletingLastPathComponent];
            [fileManager createDirectoryAtPath:stagedArea withIntermediateDirectories:YES attributes:NULL error:NULL];
            [fileManager copyItemAtPath:file toPath:[stagedArea stringByAppendingPathComponent:file.lastPathComponent] error:NULL];
        }
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveGo)];
    self.navigationItem.rightBarButtonItem = done;
}

- (void)saveGo {
    NSString *debian = [self.stagingDir stringByAppendingPathComponent:@"DEBIAN"];
    [NSFileManager.defaultManager createDirectoryAtPath:debian withIntermediateDirectories:NO attributes:NULL error:NULL];
    NSString *packageID = self.packageID.text;
    NSString *version = self.version.text;
    NSString *control = [NSString stringWithFormat:@""
                         "Package: %@\n"
                         "Name: %@\n"
                         "Author: %@\n"
                         "Description: %@\n"
                         // "Depends: mobilesubstrate\n"
                         "Maintainer: ipad_kid <ipadkid358@gmail.com>\n"
                         "Architecture: iphoneos-arm\n"
                         // "Section: Tweaks\n"
                         "Version: %@\n", packageID, self.name.text, self.author.text, self.packDesc.text, version];
    [control writeToFile:[debian stringByAppendingPathComponent:@"control"] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    [self becomeFirstResponder];
    [self.packageID resignFirstResponder];
    [self.version resignFirstResponder];
    [self.name resignFirstResponder];
    [self.author resignFirstResponder];
    [self.packDesc resignFirstResponder];
    
    // [UIApplication.sharedApplication openURL:[NSURL URLWithString:[NSString stringWithFormat:@"filza://%@/.", self.stagingDir]]];
    NSString *alertMessage = @"Please wait. Depending on the amount of files, and their sizes, this may take some time";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Creating deb" message:alertMessage preferredStyle:1];
    [self presentViewController:alert animated:YES completion:^{
        NSString *debName = [NSString stringWithFormat:@"%@_%@.deb", packageID, version];
        NSString *topDir = self.stagingDir.stringByDeletingLastPathComponent;
        NSString *debLocation = [topDir stringByAppendingPathComponent:debName];
        
        pid_t pid;
        char *const args[] = { "dpkg-deb", "-b", self.stagingDir.charStar, debLocation.charStar, NULL };
        int posixReturn = posix_spawn(&pid, "/usr/bin/dpkg-deb", NULL, NULL, args, NULL);
        waitpid(pid, NULL, 0);
        printf("Return: %d\nPid: %d\n", posixReturn, pid);
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
}
@end
