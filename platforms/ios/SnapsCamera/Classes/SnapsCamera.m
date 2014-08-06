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

-(void) openCamera:(CDVInvokedUrlCommand *)command
{
    self.hasPendingOperation = YES;
    self.latestCommand = command;
    
    self.view = [[SnapsCameraView alloc] init];
    self.view.plugin = self;
    
    [self.viewController.view addSubview:self.view];
}

-(void) capturedImageWithPath:(NSString*)imagePath
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:imagePath] callbackId:self.latestCommand.callbackId];
    
    self.hasPendingOperation = NO;
    
    [self.view removeFromSuperview];
    self.view = nil;
}

@end
