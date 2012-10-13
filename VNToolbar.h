//
//  VNToolbar.h
//  Marine Weather
//
//  Created by submarine on 9/29/12.
//  Copyright (c) 2012 Mistral LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kVNToolbarButtonSize 48
#define kVNToolbarButtonGap 4
#define kVNArrowScale 0.5

typedef NS_OPTIONS(NSUInteger, VNToolbarEdgeStyle) {
    VNToolbarEdgeStyleRoundedLeft = 1UL << 0, //-M_PI_2
    VNToolbarEdgeStyleRoundedRight = 1UL << 1,
    VNToolbarEdgeStyleRoundedAll = VNToolbarEdgeStyleRoundedLeft | VNToolbarEdgeStyleRoundedRight,
    VNToolbarEdgeStyleArrowLeft = 1UL << 2, //-M_PI_2
    VNToolbarEdgeStyleArrowRight = 1UL << 3,
    VNToolbarEdgeStyleArrowAll = VNToolbarEdgeStyleArrowLeft | VNToolbarEdgeStyleArrowRight,
    VNToolbarEdgeStyleNone = NSUIntegerMax
};

@interface VNToolbar : UIToolbar

@property (nonatomic) VNToolbarEdgeStyle edgeStyle;
@property (nonatomic, setter = setHorizontalMode:) BOOL isHorizontalMode; //-M_PI_2
@property (nonatomic, setter = setLeftSideMode:) BOOL isLeftSideMode; // align content to left side, or to right side
@property (nonatomic) BOOL sizeIsFixed;

- (id)initHorizontal:(BOOL)flag withFrame:(CGRect)frame;
/*!
 *  use this method to add bar element. 
 *  if you use standart method setItems: than be careful with elemement rotation
 *  according the bar style.
 */
- (void) setButtonsWithCustomButtons:(NSArray *)aButtons;

- (void) configure;
@end
