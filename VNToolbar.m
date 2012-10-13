//
//  VNToolbar.m
//  Marine Weather
//
//  Created by submarine on 9/29/12.
//  Copyright (c) 2012 Mistral LLC. All rights reserved.
//

#import "VNToolbar.h"
#import "UIImage+Tools.h"

@interface VNToolbar () {
    CGAffineTransform _baseTransform;
    CGRect _initFrame;
    CGAffineTransform _appliedTransform;
}
@property (nonatomic, retain)     NSMutableArray *buttonsArray;
@end

@implementation VNToolbar
@synthesize edgeStyle = _edgeStyle;
@synthesize isHorizontalMode = _isHorizontalMode;
@synthesize buttonsArray = _buttonsArray;
@synthesize isLeftSideMode = _isLeftSideMode;

#pragma mark - Accessors
- (void) setFrame:(CGRect)frame {
    _initFrame = frame;
    [self setBounds:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

- (void) setBounds:(CGRect)bounds {
    CGRect newBounds;
    if (!_isHorizontalMode) {
        newBounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
    } else {
        newBounds = bounds;
    }
    [super setBounds:newBounds];
}

- (void) setButtonsWithCustomButtons:(NSArray *)aButtons {
    [self.buttonsArray setArray: [self elementsForButton:aButtons]];
    [self setItems:self.buttonsArray animated:FALSE];
}

- (void) setHorizontalMode:(BOOL)aMode {
    if (_isHorizontalMode != aMode) {
        _isHorizontalMode = aMode;
//        [self configure];
    }
}

- (void) setEdgeStyle:(VNToolbarEdgeStyle)anEdgeStyle {
    if (_edgeStyle != anEdgeStyle) {
        _edgeStyle = anEdgeStyle;
//        [self configure];
    }
}

- (void) setTransform:(CGAffineTransform)transform {
    transform = CGAffineTransformConcat(transform, _baseTransform);
    [super setTransform:transform];
}
#pragma mark - Overriden
- (void) setItems:(NSArray *)items {
    [self setItems:items animated:FALSE];
}
- (void) setItems:(NSArray *)items animated:(BOOL)animated {
    [super setItems:items animated:animated];
    [self.buttonsArray setArray: items];
//    [self configure];
}
- (void) setSizeIsFixed:(BOOL)sizeIsFixed {
    if (_sizeIsFixed != sizeIsFixed) {
        _sizeIsFixed = sizeIsFixed;
    }
}
- (void) sizeToFit {
    [self configure];
}
#pragma mark - Init & Memory
- (void) toolbarInit {
    _edgeStyle = VNToolbarEdgeStyleRoundedAll;
    _baseTransform = CGAffineTransformIdentity;
    _appliedTransform = CGAffineTransformIdentity;
//    if (_edgeStyle == VNToolbarEdgeStyleRoundedAll) {
//        self.clipsToBounds = TRUE;
//    }
    self.buttonsArray = [NSMutableArray array];
    _sizeIsFixed = TRUE;
    _isLeftSideMode = TRUE;
//    [self configure];
}

- (id)initHorizontal:(BOOL)flag withFrame:(CGRect)frame {
    _isHorizontalMode = flag;
//    CGRect bounds;
//    if (_isHorizontalMode) {
//        bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    } else {
//        bounds = CGRectMake(0, 0, frame.size.height, frame.size.width);
//    }

    self = [super initWithFrame:frame];
    if (self) {
        [self toolbarInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    if ((frame.size.width / frame.size.height) < 1.5) {
        return [self initHorizontal:FALSE withFrame:frame];
    } else {
        return [self initHorizontal:TRUE withFrame:frame];
    }
}

#pragma mark - Add/Remove Items

- (NSArray *) elementsForButton:(NSArray *) aButtons {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[aButtons count]];
    for (UIButton *button in aButtons) {
        UIBarButtonItem *newItem = nil;
        if ([button isKindOfClass:[UIView class]]) {
            newItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        } else if ([button isKindOfClass:[UIImage class]])
        if (newItem) {
            [result addObject:newItem];
        }
    }
    return result;
}

- (void) addItemToToolbar:(UIBarButtonItem *) newItem atIndex:(NSInteger)anIndex {
    if (!newItem) {
        return;
    }
    if (anIndex < 0) {
        anIndex = 0;
    } else if (anIndex > [self.items count]) {
        anIndex = [self.items count];
    }
    
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.items];
    if (!newItems) {
        newItems = [NSMutableArray array];
    }
    [newItems insertObject:newItem atIndex:anIndex];
    [super setItems:newItems animated:FALSE];
}

- (void) removeItemFromToolBar:(UIBarButtonItem *) oldItem {
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.items];
    if (!newItems) {
        return;
    }
    [newItems removeObject:oldItem];
    [super setItems: newItems animated:FALSE];
}

- (void) reArrangeItems {
        NSMutableArray *reversedArray = [NSMutableArray arrayWithCapacity:[self.buttonsArray count]];
        NSEnumerator *enumerator = [self.buttonsArray reverseObjectEnumerator];
        for (id element in enumerator) {
            [reversedArray addObject:element];
        }
        [super setItems:reversedArray animated:FALSE];
}

#pragma mark - Configure
- (void) configure {
    _baseTransform = CGAffineTransformIdentity;    
    if (!_isHorizontalMode) {
        _baseTransform = CGAffineTransformRotate(_baseTransform, - 1 * M_PI_2);
    }
//    [super setTransform:_baseTransform];

    [self updateLayoutForButtons];
    
    [self updateLayout];
    self.layer.cornerRadius = 0;
    self.layer.mask = nil;

    
    switch (_edgeStyle) {
        case VNToolbarEdgeStyleRoundedAll:
            self.layer.mask = [self createRoundedClip];
            break;
        case VNToolbarEdgeStyleRoundedRight:
            self.layer.mask = [self createRightRoundedClip];
            break;
        case VNToolbarEdgeStyleRoundedLeft:
            self.layer.mask = [self createLeftRoundedClip];
            break;
        case VNToolbarEdgeStyleArrowLeft:
//            [self setTransform:CGAffineTransformMakeRotation(M_PI)];
//            _baseTransform = CGAffineTransformRotate(_baseTransform, M_PI);
            self.layer.mask = [self createLeftArrowClip];
            break;
        case VNToolbarEdgeStyleArrowRight:
            self.layer.mask = [self createRightArrowClip];
            break;
        case VNToolbarEdgeStyleArrowAll:
            self.layer.mask = [self createArrowClipAllSide];
            break;
        default:
            break;
    }
    [super setTransform:_baseTransform];
    [self restoreOrigin];
}

#pragma mark - Layout 
- (void) restoreOrigin {
    CGPoint newCenter = CGPointMake(CGRectGetMidX(_initFrame), CGRectGetMidY(_initFrame));
    if (_sizeIsFixed) {
        self.center = newCenter;
        return;
    }

    if (_isHorizontalMode && _isLeftSideMode) {
        newCenter.x += super.bounds.size.width / 2 - _initFrame.size.width / 2;
    } else if (_isHorizontalMode && !_isLeftSideMode) {
        newCenter.x -=  + super.bounds.size.width / 2 - _initFrame.size.width / 2;
    } else if (!_isHorizontalMode && _isLeftSideMode) {
        CGRect modifiedBounds = CGRectApplyAffineTransform(super.bounds, self.transform);
        newCenter.y += modifiedBounds.size.height / 2  - _initFrame.size.height / 2;
    } else if (!_isHorizontalMode && !_isLeftSideMode) {
        CGRect modifiedBounds = CGRectApplyAffineTransform(super.bounds, self.transform);
        newCenter.y -= modifiedBounds.size.height / 2  - _initFrame.size.height / 2;
    }
    self.center = newCenter;
}
- (void) updateLayoutForButtons {
    if ([self.items count] < 1) {
        return;
    }
    if (!CGAffineTransformIsIdentity(_baseTransform) || super.bounds.size.height > 20) {
        CGAffineTransform inverse = CGAffineTransformInvert(_baseTransform);
        if (CGAffineTransformEqualToTransform(inverse, _appliedTransform)) {
            return;
        }
        if ([self.items count] > 0) {
            _appliedTransform = inverse;
        }

        CGFloat radians = 0;
//        if (!CGAffineTransformIsIdentity(_baseTransform)) {
            radians = atan2f(inverse.b, inverse.a);
//        }
        CGFloat size = MIN(super.bounds.size.height, super.bounds.size.width) - 4 * kVNToolbarButtonGap;
        for (UIBarButtonItem *item in self.items) {
            if (item.customView) {
                float hfactor = item.customView.bounds.size.width / size;
                float vfactor = item.customView.bounds.size.height / size;
                float factor = fmax(hfactor, vfactor);
                factor = fmax(factor, 1);
                item.customView.transform = CGAffineTransformScale(inverse, factor, factor);
            } else if (item.image) {
                
                UIImage *newImage = rotateByRadians(item.image, radians);
                newImage = [newImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(size, size) interpolationQuality:kCGInterpolationHigh];
                item.image = newImage;
            }
            item.width = size;
        }
    }
}

- (void) updateLayout {
    [self removeGaps];    

    CGFloat width = floorf([self arrowSize].width - 13);
    if (_edgeStyle == VNToolbarEdgeStyleRoundedLeft || _edgeStyle == VNToolbarEdgeStyleRoundedRight || _edgeStyle == VNToolbarEdgeStyleRoundedAll) {
//        width /= 2;
//        width = floorf(width);
        width = 1.0;
    }
    CGFloat size = floorf(MIN(super.bounds.size.height, super.bounds.size.width) - 2 * kVNToolbarButtonGap);

    NSInteger count = [self.buttonsArray count];
    if (count > 0 && !_sizeIsFixed) {
        CGRect bounds = super.bounds;
//        bounds = CGRectApplyAffineTransform(bounds, CGAffineTransformInvert(self.transform));
//        bounds.origin = self.frame.origin;
        CGFloat newWidth = [(NSNumber *)[self.items valueForKeyPath:@"@sum.width"] floatValue];
        if (newWidth > count) {
            bounds.size.width = 2*13 + newWidth + 10 * (count -1);
        } else {
            bounds.size.width = super.bounds.size.height * count + 10 * (count - 1) + 2 * 13;
        }
        newWidth = size * count + 10 * (count - 1); // + 2 * 13;
        if (bounds.size.width < newWidth) {
            bounds.size.width = newWidth;
        }
        bounds.size.width = floorf(bounds.size.width);
        bounds.size.height = floorf(bounds.size.height);
//        bounds = CGRectApplyAffineTransform(bounds, self.transform);
        super.bounds = bounds;
    }
    
    if (width > 0) {
        //rearrange before adding
        CGFloat radians = atan2f(_baseTransform.b, _baseTransform.a);
        if ((radians >= - M_PI && radians < -0.00000001) || (radians >= M_PI && radians < 2 * M_PI && _isLeftSideMode)) {
            [self reArrangeItems];
        } else {
            super.items = self.buttonsArray;
        }
        
        switch (_edgeStyle) {
            case VNToolbarEdgeStyleRoundedAll:
            case VNToolbarEdgeStyleArrowAll: {
                UIBarButtonItem *gap =[self gapItem];
                gap.width = width;
                gap.tag = 23456;
                [self addItemToToolbar:gap atIndex:0];
                gap =[self gapItem];
                gap.width = width;
                gap.tag = 98765;
                [self addItemToToolbar:gap atIndex:count + 1];
                if (!_sizeIsFixed) {
                    CGRect bounds = super.bounds;
//                    bounds = CGRectApplyAffineTransform(bounds, CGAffineTransformInvert(self.transform));
                    bounds.size.width += width * 2;
//                    bounds = CGRectApplyAffineTransform(bounds, self.transform);
                    super.bounds = bounds;
                }
            }
                break;
            case VNToolbarEdgeStyleArrowLeft:
            case VNToolbarEdgeStyleRoundedLeft: {
                UIBarButtonItem *gap =[self gapItem];
                gap.width = width;
                gap.tag = 23456;
                [self addItemToToolbar:gap atIndex:0];
                if (!_sizeIsFixed) {
                    CGRect bounds = super.bounds;
//                    bounds = CGRectApplyAffineTransform(bounds, CGAffineTransformInvert(self.transform));
                    bounds.size.width += width;
//                    bounds = CGRectApplyAffineTransform(bounds, self.transform);
                    super.bounds = bounds;
                }
            }
                break;
            case VNToolbarEdgeStyleArrowRight:
            case VNToolbarEdgeStyleRoundedRight: {
                UIBarButtonItem *gap =[self gapItem];
                gap.width = width;
                gap.tag = 98765;
                [self addItemToToolbar:gap atIndex:count];
                if (!_sizeIsFixed) {
                    CGRect bounds = super.bounds;
//                    bounds = CGRectApplyAffineTransform(bounds, CGAffineTransformInvert(self.transform));
                    bounds.size.width += width;
//                    bounds = CGRectApplyAffineTransform(bounds, self.transform);
                    super.bounds = bounds;
                }
            }
                break;
            default:
                break;
        }
    }
    if (_sizeIsFixed) {
        if ([self.buttonsArray count] == 1) {
            UIBarButtonItem *gap = [self flexGap];
            gap.tag = 99999;
            [self addItemToToolbar:gap atIndex:0];
            gap = [self flexGap];
            gap.tag = 99998;
            [self addItemToToolbar:gap atIndex:[self.items count]];
        } else if (!_isHorizontalMode && !_isLeftSideMode) {
            UIBarButtonItem *gap = [self flexGap];
            gap.tag = 99999;
            [self addItemToToolbar:gap atIndex:0];
        } else if (!_isHorizontalMode && _isLeftSideMode) {
            UIBarButtonItem *gap = [self flexGap];
            gap.tag = 99998;
            [self addItemToToolbar:gap atIndex:[self.items count]];
        } else if (_isHorizontalMode && _isLeftSideMode) {
            UIBarButtonItem *gap = [self flexGap];
            gap.tag = 99998;
            [self addItemToToolbar:gap atIndex:[self.items count]];
        } else if (_isHorizontalMode && !_isLeftSideMode) {
            UIBarButtonItem *gap = [self flexGap];
            gap.tag = 99999;
            [self addItemToToolbar:gap atIndex:0];
        }
        //        return;
    }
}
- (void) removeGaps {
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.items];
    if ([newItems count] < 1) {
        return;
    }
    NSArray *itemsToRemove = [newItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIBarButtonItem *evaluatedObject, NSDictionary *bindings) {
        return (evaluatedObject.tag == 98765 || evaluatedObject.tag == 23456 || evaluatedObject.tag == 99999 || evaluatedObject.tag == 99998);
    }]];
    if ([itemsToRemove count] < 1) {
        return;
    }
    [newItems removeObjectsInArray:itemsToRemove];
    [super setItems: newItems animated:FALSE];
}
- (UIBarButtonItem *) gapItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
}
- (UIBarButtonItem *) flexGap {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
}

#pragma mark - Frame Calcs
- (CGSize) arrowSize {
    if (self.edgeStyle == VNToolbarEdgeStyleNone) {
        return CGSizeZero;
    }
    CGFloat height = super.bounds.size.height;
    CGFloat width = height * kVNArrowScale;
    return CGSizeMake(width, height);
}

#pragma mark - Styling
- (CAShapeLayer *) createRoundedClip  {
    UIBezierPath *oMaskPath = [UIBezierPath bezierPath];
    
    CGPoint currentPoint;
    CGPoint controlPoint;
    
    CGFloat cornerRadius = [self arrowSize].width;
    
    currentPoint.y = 0;
    currentPoint.x = cornerRadius;
    [oMaskPath moveToPoint:currentPoint];
    
    controlPoint = CGPointMake(0, 0);
    currentPoint.x = 0;
    currentPoint.y = cornerRadius;
    [oMaskPath addCurveToPoint:currentPoint controlPoint1:controlPoint controlPoint2:controlPoint];
    
    currentPoint.y = super.bounds.size.height - cornerRadius;
    [oMaskPath addLineToPoint:currentPoint];
    
    controlPoint = CGPointMake(0, super.bounds.size.height);
    currentPoint.x = cornerRadius;
    currentPoint.y = super.bounds.size.height;
    [oMaskPath addCurveToPoint:currentPoint controlPoint1:controlPoint controlPoint2:controlPoint];

    currentPoint.x = super.bounds.size.width - cornerRadius;
    [oMaskPath addLineToPoint:currentPoint];

    controlPoint = CGPointMake(super.bounds.size.width, super.bounds.size.height);
    currentPoint.x = super.bounds.size.width;
    currentPoint.y = super.bounds.size.height - cornerRadius;
    [oMaskPath addCurveToPoint:currentPoint controlPoint1:controlPoint controlPoint2:controlPoint];
    
    
    currentPoint.y = cornerRadius;
    [oMaskPath addLineToPoint:currentPoint];
    
    controlPoint = CGPointMake(super.bounds.size.width, 0);
    currentPoint.x = super.bounds.size.width - cornerRadius;
    currentPoint.y = 0;
    [oMaskPath addCurveToPoint:currentPoint controlPoint1:controlPoint controlPoint2:controlPoint];
    
    currentPoint.x = cornerRadius;
    [oMaskPath addLineToPoint:currentPoint];
    
    [oMaskPath closePath];
    
    CAShapeLayer *shapeL = [CAShapeLayer layer];
    shapeL.frame = super.bounds;
    shapeL.path = oMaskPath.CGPath;
    return shapeL;
}

- (CAShapeLayer *) createRightRoundedClip  {
    UIBezierPath *oMaskPath = [UIBezierPath bezierPath];
    
    CGPoint currentPoint;
    CGPoint controlPoint;
    
    CGFloat cornerRadius = [self arrowSize].width;
    
    currentPoint.y = 0;
    currentPoint.x = 0;
    [oMaskPath moveToPoint:currentPoint];
    currentPoint.x = super.bounds.size.width - cornerRadius;
    [oMaskPath addLineToPoint:currentPoint];
    
    controlPoint = CGPointMake(super.bounds.size.width, 0);
    currentPoint.x = super.bounds.size.width;
    currentPoint.y = cornerRadius;
    [oMaskPath addCurveToPoint:currentPoint controlPoint1:controlPoint controlPoint2:controlPoint];
    
    currentPoint.y = super.bounds.size.height - cornerRadius;
    [oMaskPath addLineToPoint:currentPoint];
    
    controlPoint = CGPointMake(super.bounds.size.width, super.bounds.size.height);
    currentPoint.x = super.bounds.size.width - cornerRadius;
    currentPoint.y = super.bounds.size.height;
    [oMaskPath addCurveToPoint:currentPoint controlPoint1:controlPoint controlPoint2:controlPoint];
    
    currentPoint.x = 0;
    [oMaskPath addLineToPoint:currentPoint];
    currentPoint.y = 0;
    [oMaskPath addLineToPoint:currentPoint];
    
    [oMaskPath closePath];
    
    CAShapeLayer *shapeL = [CAShapeLayer layer];
    shapeL.frame = super.bounds;
    shapeL.path = oMaskPath.CGPath;
    return shapeL;
}

- (CAShapeLayer *) createLeftRoundedClip  {
    UIBezierPath *oMaskPath = [UIBezierPath bezierPath];
    
    CGPoint currentPoint;
    CGPoint controlPoint;
    
    CGFloat cornerRadius = [self arrowSize].width;
    
    currentPoint.y = 0;
    currentPoint.x = cornerRadius;
    [oMaskPath moveToPoint:currentPoint];

    controlPoint = CGPointMake(0, 0);
    currentPoint.x = 0;
    currentPoint.y = cornerRadius;
    [oMaskPath addCurveToPoint:currentPoint controlPoint1:controlPoint controlPoint2:controlPoint];
    
    currentPoint.y = super.bounds.size.height - cornerRadius;
    [oMaskPath addLineToPoint:currentPoint];
    
    controlPoint = CGPointMake(0, super.bounds.size.height);
    currentPoint.x = cornerRadius;
    currentPoint.y = super.bounds.size.height;
    [oMaskPath addCurveToPoint:currentPoint controlPoint1:controlPoint controlPoint2:controlPoint];

    
    currentPoint.x = super.bounds.size.width;
    [oMaskPath addLineToPoint:currentPoint];
    
    
    currentPoint.y = 0;
    [oMaskPath addLineToPoint:currentPoint];
    currentPoint.x = cornerRadius;
    [oMaskPath addLineToPoint:currentPoint];
    
    [oMaskPath closePath];
    
    CAShapeLayer *shapeL = [CAShapeLayer layer];
    shapeL.frame = super.bounds;
    shapeL.path = oMaskPath.CGPath;
    return shapeL;
}
- (CAShapeLayer *) createLeftArrowClip {
    UIBezierPath *oMaskPath = [UIBezierPath bezierPath];
    
    CGPoint currentPoint;
    CGPoint controlPoint;
    
    CGSize arrowSize = [self arrowSize];
    
    currentPoint.x = arrowSize.width;
    currentPoint.y = 0;
    [oMaskPath moveToPoint:currentPoint];
    
    controlPoint = CGPointMake(0, arrowSize.height / 2);
    [oMaskPath addLineToPoint:controlPoint];
    currentPoint.y = super.bounds.size.height;
    [oMaskPath addLineToPoint:currentPoint];
    
    currentPoint.x = super.bounds.size.width ;
    [oMaskPath addLineToPoint:currentPoint];
    
    currentPoint.y = 0;
    [oMaskPath addLineToPoint:currentPoint];
    
    currentPoint.x = arrowSize.width;
    [oMaskPath addLineToPoint:currentPoint];
    
    [oMaskPath closePath];
    
    CAShapeLayer *shapeL = [CAShapeLayer layer];
    shapeL.frame = super.bounds;
    shapeL.path = oMaskPath.CGPath;
    return shapeL;
}
- (CAShapeLayer *) createRightArrowClip {
    UIBezierPath *oMaskPath = [UIBezierPath bezierPath];
    
    CGPoint currentPoint;
    CGPoint controlPoint;
    
    CGSize arrowSize = [self arrowSize];

    controlPoint = CGPointMake(super.bounds.size.width, arrowSize.height / 2);
    currentPoint.y = 0;
    currentPoint.x = 0;
    [oMaskPath moveToPoint:currentPoint];
    currentPoint.x = super.bounds.size.width - arrowSize.width;
    [oMaskPath addLineToPoint:currentPoint];
    [oMaskPath addLineToPoint:controlPoint];
    currentPoint.y = arrowSize.height;
    [oMaskPath addLineToPoint:currentPoint];

    currentPoint.x = 0;
    [oMaskPath addLineToPoint:currentPoint];
    currentPoint.y = 0;
    [oMaskPath addLineToPoint:currentPoint];
    [oMaskPath closePath];
    
    CAShapeLayer *shapeL = [CAShapeLayer layer];
    shapeL.frame = super.bounds;
    shapeL.path = oMaskPath.CGPath;
    return shapeL;

}
- (CAShapeLayer *) createArrowClipAllSide {
    UIBezierPath *oMaskPath = [UIBezierPath bezierPath];
    
    CGPoint currentPoint;
    CGPoint controlPoint;
    
    CGSize arrowSize = [self arrowSize];
    
    currentPoint.x = arrowSize.width;
    currentPoint.y = 0;
    [oMaskPath moveToPoint:currentPoint];
    
    controlPoint = CGPointMake(0, arrowSize.height / 2);
    [oMaskPath addLineToPoint:controlPoint];
    currentPoint.y = super.bounds.size.height;
    [oMaskPath addLineToPoint:currentPoint];
    
    currentPoint.x = super.bounds.size.width - arrowSize.width;
    [oMaskPath addLineToPoint:currentPoint];
    
    controlPoint = CGPointMake(super.bounds.size.width, super.bounds.size.height / 2);
    [oMaskPath addLineToPoint:controlPoint];
    currentPoint.y = 0;
    [oMaskPath addLineToPoint:currentPoint];
    
    
    currentPoint.x = arrowSize.width;
    [oMaskPath addLineToPoint:currentPoint];
    
    [oMaskPath closePath];
    
    CAShapeLayer *shapeL = [CAShapeLayer layer];
    shapeL.frame = super.bounds;
    shapeL.path = oMaskPath.CGPath;
    return shapeL;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@ bounds = %@", [super description], NSStringFromCGRect(super.bounds)];
}
@end
