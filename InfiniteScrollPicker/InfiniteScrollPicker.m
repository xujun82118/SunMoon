//
//  InfiniteScrollPicker.m
//  InfiniteScrollPickerExample
//
//  Created by Philip Yu on 6/6/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import "InfiniteScrollPicker.h"
#import "UIView+viewController.h"
#import "AddWaterMask.h"
#import "TapShowImageViewController.h"
#import "tapToImage.h"


@implementation InfiniteScrollPicker

@synthesize imageAry = _imageAry;
@synthesize itemSize = _itemSize;
@synthesize imageStore = _imageStore;
@synthesize alphaOfobjs;
@synthesize heightOffset;
@synthesize positionRatio;
@synthesize selectedIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        alphaOfobjs = 1.0;
        heightOffset = 0.0;
        positionRatio = 1.0;
        
        _imageAry = [[NSMutableArray alloc] init];
        _imageStore = [[NSMutableArray alloc] init];
        

    }
    return self;
}


- (void)initInfiniteScrollView
{
    if (_itemSize.width == 0 && _itemSize.height == 0) {
        if (_imageAry.count > 0)
        {
            //_itemSize = [(UIImage *)[_imageAry objectAtIndex:0] size];
            UIImage* image =(UIImage *)[(NSDictionary*)[_imageAry objectAtIndex:0] objectForKey:@"image_data"];
            _itemSize = [image size];
        }
        else
        {
            _itemSize = CGSizeMake(320,480);
        }
        
        //第一次登录时照片为空，size=0
        if (_itemSize.width==0) {
            _itemSize = CGSizeMake(320,480);
        }
        
    }
    
    if (_itemSize.height>self.frame.size.height) {
        CGFloat rate = _itemSize.width/_itemSize.height;
        _itemSize.height = self.frame.size.height-30;
        _itemSize.width = _itemSize.height *rate
        ;
    }
    
    //NSAssert((_itemSize.height < self.frame.size.height), @"item's height must not bigger than scrollpicker's height");
    
    self.pagingEnabled = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    if (_imageAry.count > 0)
    {
        
        // Init 5 set of images, 3 for user selection, 2 for
        for (int i = 0; i < (_imageAry.count*5); i++)
        {
            // Place images into the bottom of view
            //UIImageView *temp = [[UIImageView alloc] initWithFrame:CGRectMake(i * _itemSize.width, self.frame.size.height - _itemSize.height, _itemSize.width, _itemSize.height)];
            
            //tap*******
            tapSeeImageView =[[TapSeeImage alloc] initWithFrame:CGRectMake(i * _itemSize.width, self.frame.size.height - _itemSize.height, _itemSize.width, _itemSize.height)];
            tapSeeImageView.canClick = YES;
            tapSeeImageView.tag = i;
            //tapToImage *tapShow = [[tapToImage alloc] initWithNibName:@"tapToImage" bundle:Nil];

            //[temp setClickToViewController:tapShow];
            //tap*******

            NSDictionary * tempDic =(NSDictionary *)[_imageAry objectAtIndex:i%_imageAry.count];
            tapSeeImageView.image = (UIImage*)[tempDic objectForKey:@"image_data"];
            //temp.image = [_imageAry objectAtIndex:i%_imageAry.count];
            //[imageStore addObject:temp];
            [_imageStore addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   tapSeeImageView, @"image_data",
                                   [tempDic objectForKey:@"image_name_time"], @"image_name_time",
                                    [tempDic objectForKey:@"image_sentence"], @"image_sentence",
                                   nil]];

            
            [self addSubview:tapSeeImageView];
        }
        
        self.contentSize = CGSizeMake(_imageAry.count * 5 * _itemSize.width, self.frame.size.height);
        
        float viewMiddle = _imageAry.count * 2 * _itemSize.width;
        [self setContentOffset:CGPointMake(viewMiddle, 0)];
        
        self.delegate = self;
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^ {
            [self reloadView:viewMiddle-10];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self snapToAnEmotion];
            });
        });
        
    }
    
}


- (void)tapOneImageViewHandle:(UITapGestureRecognizer *)sender
{
    //NSLog(@" one view is tapper");
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@" one view is touchesEnded");

    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //NSLog(@" shouldReceiveTouch");
    UIImageView* tappedView = touch.view;
    

    return  YES;
}

- (void)setImageAry:(NSArray *)imageAry
{
    _imageAry = imageAry;
    [self initInfiniteScrollView];
}

- (void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize;
    [self initInfiniteScrollView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.contentOffset.x > 0)
    {
        float sectionSize = _imageAry.count * _itemSize.width;
        
        if (self.contentOffset.x <= (sectionSize - sectionSize/2))
        {
            self.contentOffset = CGPointMake(sectionSize * 2 - sectionSize/2, 0);
        } else if (self.contentOffset.x >= (sectionSize * 3 + sectionSize/2)) {
            self.contentOffset = CGPointMake(sectionSize * 2 + sectionSize/2, 0);
        }

        [self reloadView:self.contentOffset.x];
    }
}

#pragma mark - scroll delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == 0 && !snapping) [self snapToAnEmotion];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!snapping) [self snapToAnEmotion];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.scrollDelegate InfiniteScrollViewWillBeginDragging:self];

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
    [self.scrollDelegate InfiniteScrollViewDidEndScrollingAnimation:self];

}

- (void)reloadView:(float)offset
{
    float biggestSize = 0;
    id biggestView;
    
    for (int i = 0; i < _imageStore.count; i++) {
        
        //UIImageView *view = [imageStore objectAtIndex:i];
        TapSeeImage *view = [(NSDictionary*)[_imageStore objectAtIndex:i] objectForKey:@"image_data"];

        if (view.center.x > (offset - _itemSize.width ) && view.center.x < (offset + self.frame.size.width + _itemSize.width))
        {
            float tOffset = (view.center.x - offset) - self.frame.size.width/4;
            
            if (tOffset < 0 || tOffset > self.frame.size.width) tOffset = 0;
            float addHeight = (-1 * fabsf((tOffset)*2 - self.frame.size.width/2) + self.frame.size.width/2)/4;
            
            if (addHeight < 0) addHeight = 0;
            
            //增加addWidth
            float addWidth = addHeight*(_itemSize.width/_itemSize.height);
            
            view.frame = CGRectMake(view.frame.origin.x,
                                    self.frame.size.height - _itemSize.height - heightOffset - (addHeight/positionRatio),
                                    _itemSize.width + addWidth,
                                    _itemSize.height + addHeight);
            
            if (((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x) > biggestSize)
            {
                
                biggestSize = ((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x);
                biggestView = view;
                selectedIndex = i;
                
            }
            
        } else {
            view.frame = CGRectMake(view.frame.origin.x, self.frame.size.height, _itemSize.width, _itemSize.height);
            for (UIImageView *imageView in view.subviews)
            {
                imageView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            }
            
        }
    }
    
    for (int i = 0; i < _imageStore.count; i++)
    {
        //UIView *cBlock = [imageStore objectAtIndex:i];
        UIView *cBlock  = [(NSDictionary*)[_imageStore objectAtIndex:i] objectForKey:@"image_data"];

        cBlock.alpha = alphaOfobjs;
        
        if (i > 0)
        {
            //UIView *pBlock = [imageStore objectAtIndex:i-1];
            UIView *pBlock = [(NSDictionary*)[_imageStore objectAtIndex:i-1] objectForKey:@"image_data"];
            cBlock.frame = CGRectMake(pBlock.frame.origin.x + pBlock.frame.size.width, cBlock.frame.origin.y, cBlock.frame.size.width, cBlock.frame.size.height);
        }
    }
    
    
//    for (int i = 0; i < _imageStore.count; i++) {
//        
//        TapSeeImage *view = [(NSDictionary*)[_imageStore objectAtIndex:i] objectForKey:@"image_data"];
//        if (view ==  biggestView) {
//            view.canClick = YES;
//            NSLog(@"*******yes");
//        }else
//        {
//            view.canClick = NO;
//            NSLog(@"*******no");
//
//        }
//        
//    }
    
    [(UIView *)biggestView setAlpha:1.0];
}

/*
- (void)reloadView:(float)offset
{
    float biggestSize = 0;
    id biggestView;

    NSLog(@"-----imageStore count=%d", imageStore.count);
    
    for (int i = 0; i < imageStore.count; i++) {
        
        UIImageView *view = [imageStore objectAtIndex:i];
        
        if (view.center.x > (offset - _itemSize.width ) && view.center.x < (offset + self.frame.size.width + _itemSize.width))
        {
            float tOffset = (view.center.x - offset) - self.frame.size.width/4;
            
            if (tOffset < 0 || tOffset > self.frame.size.width) tOffset = 0;
            float addHeight = (-1 * fabsf((tOffset)*2 - self.frame.size.width/2) + self.frame.size.width/2)/4;
            
            if (addHeight < 0) addHeight = 0;
            
            view.frame = CGRectMake(view.frame.origin.x,
                                    self.frame.size.height - _itemSize.height - heightOffset - (addHeight/positionRatio),
                                    _itemSize.width + addHeight,
                                    _itemSize.height + addHeight);

            if (((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x) > biggestSize)
            {
                biggestSize = ((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x);
                biggestView = view;
            }
            
        } else {
            view.frame = CGRectMake(view.frame.origin.x, self.frame.size.height, _itemSize.width, _itemSize.height);
            for (UIImageView *imageView in view.subviews)
            {
                imageView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            }
        }
    }
    
    for (int i = 0; i < imageStore.count; i++)
    {
        UIView *cBlock = [imageStore objectAtIndex:i];
        cBlock.alpha = alphaOfobjs;

        if (i > 0)
        {
            UIView *pBlock = [imageStore objectAtIndex:i-1];
            cBlock.frame = CGRectMake(pBlock.frame.origin.x + pBlock.frame.size.width, cBlock.frame.origin.y, cBlock.frame.size.width, cBlock.frame.size.height);
        }
    }

    [(UIView *)biggestView setAlpha:1.0];
}

 */
- (void)snapToAnEmotion
{
    float biggestSize = 0;
    UIImageView *biggestView;
    
    //NSLog(@"--snapToAnEmotion---imageStore count=%d", imageStore.count);

    
    snapping = YES;
    
    float offset = self.contentOffset.x;
    
    for (int i = 0; i < _imageStore.count; i++) {
        //UIImageView *view = [imageStore objectAtIndex:i];
        UIImageView *view = [(NSDictionary*)[_imageStore objectAtIndex:i] objectForKey:@"image_data"];
        if (view.center.x > offset && view.center.x < (offset + self.frame.size.width))
        {
            if (((view.center.x + view.frame.size.width) - view.center.x) > biggestSize)
            {
                
//                //构造带时间的照片****
//                NSString * time = [(NSDictionary*)[_imageStore objectAtIndex:i] objectForKey:@"image_name_time"];
//                UIImage* addImageBk = [self addTimeToImage:[UIImage imageNamed:@"相框.png"] withTime:time];
//                view.image = [self addToImage:view.image withBkImage:addImageBk];
//                //*****************
                
                
                biggestSize = ((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x);
                biggestView = view;
                selectedIndex = i;

            }
            
        }
    }
    
    
//    for (int i = 0; i < _imageStore.count; i++) {
//        
//        TapSeeImage *view = [(NSDictionary*)[_imageStore objectAtIndex:i] objectForKey:@"image_data"];
//        if (view ==  biggestView) {
//            view.canClick = YES;
//            NSLog(@"11*******yes");
//        }else
//        {
//            view.canClick = NO;
//            NSLog(@"11*******no");
//            
//        }
//        
//    }
    
    float biggestViewX = biggestView.frame.origin.x + biggestView.frame.size.width/2 - self.frame.size.width/2;
    float dX = self.contentOffset.x - biggestViewX;
    float newX = self.contentOffset.x - dX/1.4;
    
    // Disable scrolling when snapping to new location
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^ {
        [self setScrollEnabled:NO];
        [self scrollRectToVisible:CGRectMake(newX, 0, self.frame.size.width, 1) animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            SEL selector = @selector(infiniteScrollPicker:didSelectAtImage:);
            if ([[self firstAvailableUIViewController] respondsToSelector:selector])
            {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [[self firstAvailableUIViewController] performSelector:selector withObject:self withObject:biggestView];
                #pragma clang diagnostic pop
            }
            
            [self setScrollEnabled:YES];
            snapping = 0;
        });
    });
}


/**
 * @brief 给相片增加日期时间
 *
 * @param image 要增加图片
 * @param time 要增加的时间字串
 */
- (UIImage*) addTimeToImage: (UIImage*) image  withTime:(NSString*) time
{
    
    AddWaterMask* add = [AddWaterMask alloc];
    UIImage* imageAdd = [add addText:image text:time];
    
    return  imageAdd;
}


/**
 * @brief 给相片叠加时间底图
 *
 * @param timeImage 时间底图
 * @param image 加到底图上的原图
 */
- (UIImage*) addToImage: (UIImage*) image  withBkImage:(UIImage*) timeImage
{
    
    AddWaterMask* add = [AddWaterMask alloc];
    UIImage* imageAdd = [add addImage:timeImage addMsakImage:image];
    
    return  imageAdd;
}



@end
