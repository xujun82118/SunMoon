//
//  AddWaterMask.m
//  ShowGirl美妆
//
//  Created by 徐 军 on 14-1-14.
//  Copyright (c) 2014年 徐 军. All rights reserved.
//

#import "AddWaterMask.h"


@interface AddWaterMask ()

@end

@implementation AddWaterMask

@synthesize waterRect, logRect;


/**
 加文字随意
 @param img 需要加文字的图片
 @param text1 文字描述
 @returns 加好文字的图片
 */
-(UIImage *)addText:(UIImage *)img text:(NSString *)text1
{
    int w = img.size.width;
    int h = img.size.height;
    UIGraphicsBeginImageContext(img.size);
    [[UIColor whiteColor] set];
    [img drawInRect:CGRectMake(0, 0, w, h)];
    //[text1 drawInRect:CGRectMake(10, 55, 130, 80) withFont:[UIFont systemFontOfSize:18]];
    
    UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:14.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     font, NSFontAttributeName, [UIColor blueColor],NSForegroundColorAttributeName,[NSNumber numberWithFloat:1.0],
                                     NSBaselineOffsetAttributeName, nil];
    
    //[text1 drawInRect:CGRectMake(10, h-50, 230, 80) withAttributes:attrsDictionary];
    [text1 drawWithRect:CGRectMake(w/2-30, h-10, w, 100) options:NSStringDrawingUsesFontLeading attributes:attrsDictionary context:Nil];

    
    UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aimg;
    
    
    /*
    //get image width and height
       int w = img.size.width;
       int h = img.size.height;
    
    //int w = 300;
    //int h = 140;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextSetRGBFillColor(context, 0.0, 0, 1.0, 0.6);
    char* text = (char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];
    CGContextSelectFont(context, "Georgia", 15, kCGEncodingMacRoman);
    //CGFontRef Georgia = CGFontCreateWithFontName((CFStringRef)@"Georgia");
    //CGContextSetFont(context, Georgia);
    //CGContextSetFontSize(context, 15);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 0, 0, 1.0, 0.8);
    
    //位置调整
    CGContextShowTextAtPoint(context, w/2-strlen(text)*4.5 , h - 135, text, strlen(text));
    
    //Create image ref from the context
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
     */
}

/**
 加图片水印
 @param img 需要加logo图片的图片
 @param logo logo图片
 @returns 加好logo的图片
 */
-(UIImage *)addImageLogo:(UIImage *)img text:(UIImage *)logo
{
    //get image width and height
    int w = img.size.width;
    int h = img.size.height;
    int logoWidth = logo.size.width;
    int logoHeight = logo.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake(w-logoWidth, 0, logoWidth, logoHeight), [logo CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
    //  CGContextDrawImage(contextRef, CGRectMake(100, 50, 200, 80), [smallImg CGImage]);
}

/**
 加半透明水印
 @param useImage 需要加水印的图片
 @param maskImage 水印
 @returns 加好水印的图片
 */
- (UIImage *)addImage:(UIImage *)useImage addMsakImage:(UIImage *)maskImage
{
    UIGraphicsBeginImageContext(useImage.size);
    NSLog(@"useimage.width = %f, height = %f", useImage.size.width,useImage.size.height);
    [useImage drawInRect:CGRectMake(0, 0, useImage.size.width, useImage.size.height)];
    
    [maskImage drawInRect:CGRectMake(waterRect.origin.x, waterRect.origin.y, waterRect.size.width, waterRect.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}


@end

