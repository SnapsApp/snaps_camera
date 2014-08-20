//
//  SnapsCameraView.m
//  SnapsCamera
//
//  Created by Travis Fischer on 8/6/14.
//
//

#import "SnapsCameraView.h"
#import "SnapsCamera.h"
#import "SNCameraButton.h"
#import "SNStickerView.h"
#import "UIImage+Resize.h"
#import "UIButton+Snaps.h"

#define IS_IPHONE_5  (([[UIScreen mainScreen] bounds].size.height >= 568) ? YES : NO)

@interface SnapsCameraView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SNStickerViewDelegate>

@property (nonatomic, strong) UIView *_overlay;
@property (nonatomic, strong) UIView *_stickersView;

@property (nonatomic, strong) UIImagePickerController *_picker;

@property (nonatomic, strong) NSMutableArray *_stickers;

@property (nonatomic, strong) SNStickerView *_selected;

@property (nonatomic) BOOL isCameraMode;

@property (nonatomic, strong) NSMutableArray *_overlaySubviews;

@property (nonatomic, strong) UIImage *_image;

@end

@implementation SnapsCameraView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self._stickers = [[NSMutableArray alloc] init];
        
        // Set the frames to be half screen
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        CGRect frame = CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height / 2);
        self.frame = frame;
        
        self._overlay = [[UIView alloc] initWithFrame:self.frame];
        
        self._stickersView = [[UIView alloc] initWithFrame:self.frame];
        self._stickersView.clipsToBounds = YES;
        self._stickersView.opaque = NO;
        [self._overlay addSubview:self._stickersView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self._stickersView addGestureRecognizer:tap];
        
        self.isCameraMode = YES;
    }
    
    return self;
}

- (void)setIsCameraMode:(BOOL)isCameraMode
{
    if (_isCameraMode != isCameraMode || !self._overlaySubviews) {
        _isCameraMode = isCameraMode;
        
        if (self._overlaySubviews) {
            for (UIView *view in self._overlaySubviews) {
                [view removeFromSuperview];
            }
        }
        
        self._overlaySubviews = [NSMutableArray new];
        
        if (isCameraMode) {
            self._picker = [[UIImagePickerController alloc] init];
            
            self._picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self._picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            self._picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            self._picker.showsCameraControls = NO;
            
            self._picker.delegate = self;
            self._picker.view.frame = self.frame;
            
            [self._overlay bringSubviewToFront:self._stickersView];
            
            {
                SNCameraButton *photoButton = [SNCameraButton new];
                CGFloat size = (IS_IPHONE_5 ? 48 : 32);
                photoButton.frame = CGRectMake(0, 0, size, size);
                photoButton.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height - size / 2 - 8);
                [photoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
                [self._overlay addSubview:photoButton];
                [self._overlaySubviews addObject:photoButton];
            }
            
            //        UIButton *swap = [UIButton getButton:@"icon.swap"];
            //        [swap addTarget:self action:@selector(swapCamera:) forControlEvents:UIControlEventTouchUpInside];
            //        [self addSubview:swap];
            //
            //        UIButton *flash = [UIButton getButton:@"icon.flash"];
            //        [flash addTarget:self action:@selector(toggleFlash:) forControlEvents:UIControlEventTouchUpInside];
            //        [self addSubview:flash];
            //
            //        UIButton *gallery = [UIButton getButton:@"icon.gallery"];
            //        [gallery addTarget:self action:@selector(openGallery:) forControlEvents:UIControlEventTouchUpInside];
            //        [self addSubview:gallery];
            
            self._picker.cameraOverlayView = self._overlay;
            [self addSubview:self._picker.view];
        } else {
            if (self._picker) {
                [self._picker.view removeFromSuperview];
                [self._overlay removeFromSuperview];
                self._picker.cameraOverlayView = nil;
                self._picker = nil;
            }
            
            // TODO: imageview needs to display the resulting image
            UIImageView *iv = [[UIImageView alloc] initWithImage:self._image];
            iv.frame = self.frame;
            [self._overlay addSubview:iv];
            [self._overlaySubviews addObject:iv];
            
            CGFloat pad = 16;
            
            for (SNStickerView *sticker in self._stickers) {
                [self._overlay bringSubviewToFront:sticker];
            }
            
            [self._overlay bringSubviewToFront:self._stickersView];
            
            {
                UIButton *button = [[UIButton alloc] init];
                [button setTitle:@"Cancel" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(onEditCancel:) forControlEvents:UIControlEventTouchUpInside];
                [button sizeToFit];
                button.frame = CGRectMake(pad, pad, button.bounds.size.width, button.bounds.size.height);
                [self._overlay addSubview:button];
                [self._overlaySubviews addObject:button];
            }
            
            {
                UIButton *button = [[UIButton alloc] init];
                [button setTitle:@"Done" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(onEditComplete:) forControlEvents:UIControlEventTouchUpInside];
                [button sizeToFit];
                button.frame = CGRectMake(self.bounds.size.width - button.bounds.size.width - pad, pad, button.bounds.size.width, button.bounds.size.height);
                [self._overlay addSubview:button];
                [self._overlaySubviews addObject:button];
            }
            
            [self addSubview:self._overlay];
        }
    }
}

- (void)addSticker:(NSString*)sticker
{
    NSLog(@"addSticker: %@", sticker);
    
    __unsafe_unretained SnapsCameraView *weakSelf = self;
    
    
    // TODO: use SDWebImageManager for caching
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:sticker]];
        UIImage *image = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            SNStickerView *iv = [[SNStickerView alloc] initWithImage:image];
            iv.delegate = self;
            iv.contentMode = UIViewContentModeScaleAspectFit;
            CGFloat W = self.bounds.size.width;
            CGFloat w = W / 4;
            iv.frame = CGRectMake(0, 0, w, image.size.height * w / image.size.width);
            iv.center = CGPointMake(W / 2, self.bounds.size.height / 2);
            
            [weakSelf._stickers addObject:iv];
            [weakSelf._stickersView addSubview:iv];
            
            [weakSelf selectSticker:iv];
        });
    });
}

- (void)removeSticker:(SNStickerView*)sticker
{
    [sticker removeFromSuperview];
    [self._stickers removeObject:sticker];
    
    if (self._selected == sticker) {
        [self selectSticker:nil];
    }
}

- (void)selectSticker:(SNStickerView*)sticker
{
    self._selected = sticker;
    
    if (self._selected) {
        [self._stickersView bringSubviewToFront:self._selected];
    }
    
    for (SNStickerView *sticker in self._stickers) {
        [sticker setNeedsDisplay];
    }
}

- (BOOL)isSelectedSticker:(SNStickerView*)sticker
{
    return (sticker == self._selected);
}

- (void)handleTap:(UITapGestureRecognizer*)recognizer
{
    [self selectSticker:nil];
}

- (void)swapCamera:(id)sender
{
    
    // TODO
    
}

- (void)toggleFlash:(id)sender
{
    
    // TODO
    
}

- (void)takePhoto:(id)sender
{
    [self._picker takePicture];
}

- (void)openGallery:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    [self.plugin.viewController presentViewController:picker animated:YES completion:nil];
}

- (void)switchCameras:(id)sender
{
    if (self._picker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        self._picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
        self._picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self selectSticker:nil];
    
    self._image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self._image = [self._image imageByScalingAndCroppingForSize:CGSizeMake(640, 640)];
    self.isCameraMode = NO;
}

- (void)onEditCancel:(id)sender
{
    self.isCameraMode = YES;
}

- (void)onEditComplete:(id)sender
{
    UIImage *image = self._image;
    CGFloat horizRatio = image.size.width / self.frame.size.width;
    CGFloat vertRatio  = image.size.height / self.frame.size.height;
    
    CGImageRef imageRef = image.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                image.size.width,
                                                image.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    
    for (SNStickerView *sticker in self._stickers) {
        CGContextSaveGState(bitmap);
        
        // TODO: fix transform issues
//        CGContextConcatCTM(bitmap, sticker.transform);
//        CGContextDrawImage(bitmap, sticker.frame, sticker.image.CGImage);
        
        CGContextTranslateCTM(bitmap, sticker.frame.origin.x * horizRatio, sticker.frame.origin.y * vertRatio);
        CGContextScaleCTM(bitmap, 1, -1);
        CGContextConcatCTM(bitmap, [[sticker layer] affineTransform]);
        [[sticker layer] renderInContext:bitmap];
        
        CGContextRestoreGState(bitmap);
    }
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    image = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    NSString *filename = [NSString stringWithFormat:@"snap-%ld.jpg", currentTime];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [imageData writeToFile:imagePath atomically:YES];
    
    // Tell the plugin class that we're finished processing the image
    [self.plugin capturedImageWithPath:imagePath];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.plugin.viewController dismissViewControllerAnimated:YES completion:^{ }];
}

@end
