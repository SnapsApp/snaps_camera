//
//  SnapsCamera.h
//  SnapsCamera
//
//  Created by Travis Fischer on 8/6/14.
//
//

#import <Cordova/CDV.h>

@class SnapsCameraView;

@interface SnapsCamera : CDVPlugin

- (void)openCamera:(CDVInvokedUrlCommand*)command;
- (void)closeCamera:(CDVInvokedUrlCommand*)command;

- (void)capturedImageWithPath:(NSString*)imagePath;

@property (strong, nonatomic) SnapsCameraView *view;
@property (strong, nonatomic) CDVInvokedUrlCommand *latestCommand;
@property (readwrite, assign) BOOL hasPendingOperation;

@end
