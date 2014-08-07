//
//  SnapsCamera.m
//  SnapsCamera
//
//  Created by Travis Fischer on 8/6/14.
//
//

#import "SnapsCamera.h"
#import "SnapsCameraView.h"

@implementation SnapsCamera

- (void)openCamera:(CDVInvokedUrlCommand*)command
{
    self.hasPendingOperation = YES;
    self.latestCommand = command;
    
    self.view = [[SnapsCameraView alloc] init];
    self.view.plugin = self;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self.viewController.view addSubview:self.view];
}

- (void)capturedImageWithPath:(NSString*)imagePath
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:imagePath] callbackId:self.latestCommand.callbackId];
    
    [self cleanup];
}

- (void)closeCamera:(CDVInvokedUrlCommand*)command
{
    if (self.hasPendingOperation) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT] callbackId:self.latestCommand.callbackId];
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT] callbackId:command.callbackId];
        
        [self cleanup];
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT] callbackId:command.callbackId];
    }
}

- (void)cleanup
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.view removeFromSuperview];
    
    self.hasPendingOperation = NO;
    self.latestCommand = nil;
    self.view = nil;
}

@end
