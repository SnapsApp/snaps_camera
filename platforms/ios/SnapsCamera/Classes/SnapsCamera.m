//
//  SnapsCamera.m
//  SnapsCamera
//
//  Created by Travis Fischer on 8/6/14.
//
//

#import "SnapsCamera.h"
#import "SnapsCameraView.h"

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface SnapsCamera () <MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) SnapsCameraView *view;
@property (strong, nonatomic) CDVInvokedUrlCommand *latestCommand;
@property (strong, nonatomic) CDVInvokedUrlCommand *mmsCommand;
@property (readwrite, assign) BOOL hasPendingOperation;

@end

@implementation SnapsCamera

- (void)openCamera:(CDVInvokedUrlCommand*)command
{
    if (self.hasPendingOperation) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT] callbackId:command.callbackId];
        return;
    }
    
    self.hasPendingOperation = YES;
    self.latestCommand = command;
    
    self.view = [[SnapsCameraView alloc] init];
    self.view.plugin = self;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self.viewController.view addSubview:self.view];
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

- (void)hideCamera:(CDVInvokedUrlCommand*)command
{
    if (self.view) {
        self.view.hidden = YES;
    }
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)showCamera:(CDVInvokedUrlCommand*)command
{
    if (self.view) {
        self.view.hidden = NO;
    }
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)addSticker:(CDVInvokedUrlCommand*)command
{
    if (self.hasPendingOperation) {
        [self.view addSticker:[command.arguments objectAtIndex:0]];
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT] callbackId:command.callbackId];
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

- (void)sendMMS:(CDVInvokedUrlCommand*)command
{
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    
    NSData *imgData = [NSData dataWithContentsOfFile:[command.arguments objectAtIndex:0]];
    BOOL didAttachImage = [messageController addAttachmentData:imgData typeIdentifier:(NSString*)kUTTypeJPEG filename:@"snap.jpg"];
    
    if (didAttachImage) {
        self.mmsCommand = command;
        [self.viewController presentViewController:messageController animated:YES completion:nil];
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT] callbackId:self.mmsCommand.callbackId];
            break;
        case MessageComposeResultSent:
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:self.mmsCommand.callbackId];
            break;
        case MessageComposeResultFailed:
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:self.mmsCommand.callbackId];
            break;
        default:
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT] callbackId:self.mmsCommand.callbackId];
            break;
    }
    
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)capturedImageWithPath:(NSString*)imagePath
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:imagePath] callbackId:self.latestCommand.callbackId];
    
    [self cleanup];
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
