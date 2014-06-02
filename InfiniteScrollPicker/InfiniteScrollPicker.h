//
//  InfiniteScrollPicker.h
//  InfiniteScrollPickerExample
//
//  Created by Philip Yu on 6/6/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol InfiniteScrollPickerDelegate;

@class InfiniteScrollPicker;

@interface InfiniteScrollPicker : UIScrollView<UIScrollViewDelegate>
{
    //NSMutableArray *imageStore;
    bool snapping;
    float lastSnappingX;
    id <InfiniteScrollPickerDelegate> scrollDelegate;
}

@property(nonatomic) id<InfiniteScrollPickerDelegate> scrollDelegate;

@property (nonatomic) NSMutableArray *imageStore;

@property (nonatomic, strong) NSArray *imageAry;
@property (nonatomic) int mode; //0:早上， 1：晚上

@property (nonatomic) CGSize itemSize;
@property (nonatomic) float alphaOfobjs;

@property (nonatomic) float heightOffset;
@property (nonatomic) float positionRatio;

@property (nonatomic) int selectedIndex;

- (void)initInfiniteScrollView;

@end

//定义为NSObject的协议，将能被所有的对像实现
@protocol InfiniteScrollPickerDelegate <NSObject >

- (void) InfiniteScrollViewDidScroll;
- (void) InfiniteScrollViewWillBeginDragging:(InfiniteScrollPicker*)picker;
- (void) InfiniteScrollViewDidEndScrollingAnimation:(InfiniteScrollPicker*)picker;

@end

