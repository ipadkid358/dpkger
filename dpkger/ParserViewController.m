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
        NSString *appDocs = @"/private/var/mobile/Documents/dpkger";
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
                         "Depends: %@\n"
                         "Maintainer: ipad_kid <ipadkid358@gmail.com>\n"
                         "Architecture: iphoneos-arm\n"
                         "Section: %@\n"
                         "Version: %@\n",
                         packageID, self.name.text, self.author.text, self.packDesc.text, self.dependencies.text, self.section.text, version];
    [control writeToFile:[debian stringByAppendingPathComponent:@"control"] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    [self becomeFirstResponder];
    [self.packageID resignFirstResponder];
    [self.version resignFirstResponder];
    [self.name resignFirstResponder];
    [self.author resignFirstResponder];
    [self.packDesc resignFirstResponder];
    
    NSString *debName = [NSString stringWithFormat:@"%@_%@.deb", packageID, version];
    NSString *topDir = self.stagingDir.stringByDeletingLastPathComponent;
    NSString *debLocation = [topDir stringByAppendingPathComponent:debName];

    UIAlertController *openAlert = [UIAlertController alertControllerWithTitle:@"Compressing" message:@"Please wait. Your deb is being compressed. Depending on the size of the files you chose, this may take some time. Buttons will not be clickable until this is finished" preferredStyle:1];

    [openAlert addAction:[UIAlertAction actionWithTitle:@"Open in Filza" style:0 handler:^(UIAlertAction *action) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:[NSString stringWithFormat:@"filza://%@", debLocation]]];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }]];
    
    [openAlert addAction:[UIAlertAction actionWithTitle:@"Copy path" style:0 handler:^(UIAlertAction *action) {
        [UIPasteboard.generalPasteboard setString:debLocation];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }]];
    
    [openAlert addAction:[UIAlertAction actionWithTitle:@"Done" style:1 handler:^(UIAlertAction *action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:openAlert animated:YES completion:^{
        pid_t pid;
        char *const args[] = { "dpkg-deb", "-b", self.stagingDir.charStar, debLocation.charStar, NULL };
        posix_spawn(&pid, "/usr/bin/dpkg-deb", NULL, NULL, args, NULL);
        waitpid(pid, NULL, 0);
        [NSFileManager.defaultManager removeItemAtPath:self.stagingDir error:NULL];
    }];
}
@end
