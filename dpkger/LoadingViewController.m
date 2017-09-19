//
//  LoadingViewController.m
//  dpkger
//
//  Created by ipad_kid on 9/18/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LoadingViewController.h"
#import "ParserViewController.h"
#import "GlobalManager.h"
#import "NSString+cat.h"
#include <spawn.h>

@implementation LoadingViewController {
    NSInteger fileIndex;
    NSArray<NSString *> *files;
    NSString *appDocs;
    NSString *stagingDir;
    NSFileManager *fileManager;
}

- (IBAction)debCreate {
    fileIndex = 0;
    ParserViewController *parserView = (ParserViewController *)self.presentingViewController;
    files = GlobalManager.manager.fileList.allKeys;
    appDocs = @"/private/var/mobile/Documents/dpkger";
    stagingDir = [appDocs stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu", files.hash]];
    fileManager = NSFileManager.defaultManager;
    
    NSString *debian = [stagingDir stringByAppendingPathComponent:@"DEBIAN"];
        [fileManager createDirectoryAtPath:debian withIntermediateDirectories:YES attributes:NULL error:NULL];
    NSString *packageID = parserView.packageID.text;
    NSString *version = parserView.version.text;
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
                         packageID, parserView.name.text, parserView.author.text, parserView.packDesc.text, parserView.dependencies.text, parserView.section.text, version];
    [control writeToFile:[debian stringByAppendingPathComponent:@"control"] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    NSString *debName = [NSString stringWithFormat:@"%@_%@.deb", packageID, version];
    NSString *debLocation = [appDocs stringByAppendingPathComponent:debName];
    
    // TODO - validate stagingDir isn't copied into itself
    [self copyFiles:^{
        GlobalManager.manager.fileList = nil;
        
        pid_t pid;
        char *const args[] = { "dpkg-deb", "-b", stagingDir.charStar, debLocation.charStar, NULL };
        posix_spawn(&pid, "/usr/bin/dpkg-deb", NULL, NULL, args, NULL);
        waitpid(pid, NULL, 0);
        // [fileManager removeItemAtPath:stagingDir error:NULL];
        
        // UIAlertController stuff
        NSString *message = [NSString stringWithFormat:@"Debian package create at %@", debLocation];
        UIAlertController *openAlert = [UIAlertController alertControllerWithTitle:@"Done!" message:message preferredStyle:1];
        
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open in Filza" style:0 handler:^(UIAlertAction *action) {
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:[NSString stringWithFormat:@"filza://%@", debLocation]]];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        UIAlertAction *pathAction = [UIAlertAction actionWithTitle:@"Copy path" style:0 handler:^(UIAlertAction *action) {
            [UIPasteboard.generalPasteboard setString:debLocation];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:1 handler:^(UIAlertAction *action) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        
        [openAlert addAction:openAction];
        [openAlert addAction:pathAction];
        [openAlert addAction:doneAction];
        [self presentViewController:openAlert animated:YES completion:nil];
    }];
}

- (void)copyFiles:(void (^)(void))completion {
    if (fileIndex >= files.count) {
        self.indicator.text = @"Compressing";
        completion();
        return;
    }
    
    NSString *fromPath = files[fileIndex];
    
    self.indicator.text = [NSString stringWithFormat:@"Copying files from %@", fromPath];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *stagedArea = [stagingDir stringByAppendingPathComponent:fromPath.stringByDeletingLastPathComponent];
        [fileManager createDirectoryAtPath:stagedArea withIntermediateDirectories:YES attributes:NULL error:NULL];
        [fileManager copyItemAtPath:fromPath toPath:[stagedArea stringByAppendingPathComponent:fromPath.lastPathComponent] error:NULL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            fileIndex++;
            [self copyFiles:completion];
        });
    });
}

@end
