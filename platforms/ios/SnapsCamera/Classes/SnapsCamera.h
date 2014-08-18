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
- (void)addSticker:(CDVInvokedUrlCommand*)command;
- (void)reset:(CDVInvokedUrlCommand*)command;

- (void)capturedImageWithPath:(NSString*)imagePath;

@end
