//
//  SnapsCameraView.h
//  SnapsCamera
//
//  Created by Travis Fischer on 8/6/14.
//
//

#import <UIKit/UIKit.h>

@class SnapsCamera;

@interface SnapsCameraView : UIView

- (void)addSticker:(NSString*)sticker;

@property (strong, nonatomic) SnapsCamera *plugin;

@end
