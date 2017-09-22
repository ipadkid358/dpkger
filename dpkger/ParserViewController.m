//
//  ParserViewController.m
//  dpkger
//
//  Created by ipad_kid on 9/16/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "ParserViewController.h"
#import "GlobalManager.h"
#import "NSString+cat.h"
#include <spawn.h>

@implementation ParserViewController {
    NSInteger fileIndex;
    NSArray<NSString *> *files;
    NSString *appDocs;
    NSString *stagingDir;
    NSFileManager *fileManager;
    NSString *debLocation;
    
    UIAlertController *openAlert;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveGo)];
    done.enabled = NO;
    self.navigationItem.rightBarButtonItem = done;
}

- (void)saveGo {
    [self becomeFirstResponder];
    [self.packageID resignFirstResponder];
    [self.version resignFirstResponder];
    [self.name resignFirstResponder];
    [self.author resignFirstResponder];
    [self.packDesc resignFirstResponder];
    
    fileIndex = 0;
    files = GlobalManager.manager.fileList.allKeys;
    appDocs = @"/private/var/mobile/Documents/dpkger";
    
    // Because: https://developer.apple.com/documentation/objectivec/nsuinteger
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
    stagingDir = [appDocs stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu", files.hash]];
#else
    stagingDir = [appDocs stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", files.hash]];
#endif
    fileManager = NSFileManager.defaultManager;
    
    NSString *debian = [stagingDir stringByAppendingPathComponent:@"DEBIAN"];
    [fileManager createDirectoryAtPath:debian withIntermediateDirectories:YES attributes:NULL error:NULL];
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
    
    NSString *debName = [NSString stringWithFormat:@"%@_%@.deb", packageID, version];
    debLocation = [appDocs stringByAppendingPathComponent:debName];
    
    openAlert = [UIAlertController alertControllerWithTitle:@"Creating deb\n" message:@"Starting..." preferredStyle:1];
    
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [openAlert.view addSubview:loadingIndicator];
    [loadingIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(loadingIndicator);
    for (NSString *format in @[@"H:|-[loadingIndicator]-|", @"V:|-42-[loadingIndicator]"])
        [openAlert.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:NULL views:viewsDict]];
    [loadingIndicator startAnimating];
    
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
    
    openAction.enabled = NO;
    pathAction.enabled = NO;
    doneAction.enabled = NO;
    [openAlert addAction:openAction];
    [openAlert addAction:pathAction];
    [openAlert addAction:doneAction];
    [self presentViewController:openAlert animated:YES completion:^{
        [self copyFiles:^{
            GlobalManager.manager.fileList = nil;
            
            [loadingIndicator stopAnimating];
            [openAlert setTitle:@"Done!"];
            [openAlert setMessage:[NSString stringWithFormat:@"Debian package create at %@", debLocation]];
            openAction.enabled = YES;
            pathAction.enabled = YES;
            doneAction.enabled = YES;
        }];
    }];
}

- (void)copyFiles:(void (^)(void))completion {
    NSUInteger filesCount = files.count;
    
    if (fileIndex > filesCount) {
        completion();
        return;
    }
    
    NSString *fromPath;
    if (fileIndex < filesCount) {
        fromPath = files[fileIndex];
        [openAlert setMessage:[NSString stringWithFormat:@"Copying files from %@", fromPath]];
    } else [openAlert setMessage:@"Compressing"];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (fileIndex < filesCount) {
            NSString *stagedArea = [stagingDir stringByAppendingPathComponent:fromPath.stringByDeletingLastPathComponent];
            [fileManager createDirectoryAtPath:stagedArea withIntermediateDirectories:YES attributes:NULL error:NULL];
            [fileManager copyItemAtPath:fromPath toPath:[stagedArea stringByAppendingPathComponent:fromPath.lastPathComponent] error:NULL];
        } else {
            pid_t pid;
            char *const args[] = { "dpkg-deb", "-b", stagingDir.charStar, debLocation.charStar, NULL };
            posix_spawn(&pid, "/usr/bin/dpkg-deb", NULL, NULL, args, NULL);
            waitpid(pid, NULL, 0);
            [fileManager removeItemAtPath:stagingDir error:NULL];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            fileIndex++;
            [self copyFiles:completion];
        });
    });
}

@end
