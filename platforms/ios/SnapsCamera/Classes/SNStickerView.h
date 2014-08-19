//
//  SNStickerView.h
//  SnapsCamera
//
//  Created by Travis Fischer on 8/18/14.
//
//

#import <UIKit/UIKit.h>

@class SNStickerView;

@protocol SNStickerViewDelegate <NSObject>

@optional

- (void)removeSticker:(SNStickerView*)sticker;
- (void)selectSticker:(SNStickerView*)sticker;
- (BOOL)isSelectedSticker:(SNStickerView*)sticker;

@end

@interface SNStickerView : UIView

- (id)initWithImage:(UIImage *)image;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<SNStickerViewDelegate> delegate;

@end
