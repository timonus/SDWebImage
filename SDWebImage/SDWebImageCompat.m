/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCompat.h"
#import "UIImage+WebCache.h"
#import "NSImage+Additions.h"

#if !__has_feature(objc_arc)
    #error SDWebImage is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#if !OS_OBJECT_USE_OBJC
    #error SDWebImage need ARC for dispatch object
#endif

inline CGFloat SDImageScaleForKey(NSString * _Nullable key) {
    CGFloat scale = 1;
    if (!key) {
        return scale;
    }
#if SD_WATCH
    if ([[WKInterfaceDevice currentDevice] respondsToSelector:@selector(screenScale)])
#elif SD_UIKIT
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
#elif SD_MAC
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)])
#endif
    {
        if (key.length >= 8) {
            NSRange range = [key rangeOfString:@"@2x."];
            if (range.location != NSNotFound) {
                scale = 2.0;
            }
            
            range = [key rangeOfString:@"@3x."];
            if (range.location != NSNotFound) {
                scale = 3.0;
            }
        }
    }
    return scale;
}

inline UIImage *SDScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    
#if SD_UIKIT || SD_WATCH
    if ((image.images).count > 0) {
        NSMutableArray<UIImage *> *scaledImages = [NSMutableArray array];

        for (UIImage *tempImage in image.images) {
            [scaledImages addObject:SDScaledImageForKey(key, tempImage)];
        }
        
        UIImage *animatedImage = [UIImage animatedImageWithImages:scaledImages duration:image.duration];
        if (animatedImage) {
            animatedImage.sd_imageLoopCount = image.sd_imageLoopCount;
        }
        return animatedImage;
    }
#endif
    CGFloat scale = SDImageScaleForKey(key);
    if (scale > 1) {
#if SD_UIKIT || SD_WATCH
        UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
#else
        UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale];
#endif
        image = scaledImage;
    }
    return image;
}

NSString *const SDWebImageErrorDomain = @"SDWebImageErrorDomain";
