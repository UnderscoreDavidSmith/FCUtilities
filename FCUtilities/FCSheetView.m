//
//  FCSheetView.m
//  Part of FCUtilities by Marco Arment. See included LICENSE file for BSD license.
//

#define kSlideInAnimationDuration     0.40f
#define kSlideOutAnimationDuration    0.25f
#define kExtraHeightForBottomOverlap  40

#import "FCSheetView.h"
#import "UIColor+FCUtilities.h"

@interface FCSheetView ()
@property (nonatomic) UIButton *dismissButton;
@property (nonatomic) UIView *contentContainer;
@property (nonatomic) UIToolbar *blurToolbar;
@property (nonatomic) CALayer *blurLayer;
@property (nonatomic) UIView *blurView;
@end

@implementation FCSheetView

- (instancetype)initWithContentView:(UIView *)contentView
{
    if ( (self = [super init]) ) {

        CGRect contentContainerFrame = contentView.bounds;
        contentContainerFrame.size.height += kExtraHeightForBottomOverlap;
        self.contentContainer = [[UIView alloc] initWithFrame:contentContainerFrame];
        self.contentContainer.backgroundColor = UIColor.clearColor;
        self.contentContainer.autoresizesSubviews = YES;
        self.contentContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        contentContainerFrame.origin = CGPointZero;
        self.blurToolbar = [[UIToolbar alloc] initWithFrame:contentContainerFrame];
        self.blurLayer = self.blurToolbar.layer;
        self.blurView = [UIView new];
        self.blurView.userInteractionEnabled = NO;
        self.contentContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_blurView.layer addSublayer:_blurLayer];
        [self.contentContainer addSubview:_blurView];
        
        CGRect innerContentFrame = contentView.bounds;
        innerContentFrame.origin = CGPointZero;
        contentView.frame = innerContentFrame;
        [self.contentContainer addSubview:contentView];

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void)dismiss
{
    [UIView animateWithDuration:kSlideOutAnimationDuration animations:^{
        CGRect contentFrame = _contentContainer.bounds;
        contentFrame.origin.y = self.bounds.size.height;
        _contentContainer.frame = contentFrame;
        self.backgroundColor = [UIColor clearColor];
        self.window.tintColor = self.tintColor;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)presentInView:(UIView *)view
{
    if (! view.window) [[NSException exceptionWithName:NSInvalidArgumentException reason:@"FCSheetView host view must be in a window" userInfo:nil] raise];

    CGRect masterFrame = view.window.bounds;
    self.frame = masterFrame;
    [view.window addSubview:self];
    
    CGRect dismissFrame = masterFrame;
    dismissFrame.size.height = masterFrame.size.height - (_contentContainer.bounds.size.height - kExtraHeightForBottomOverlap);
    
    self.dismissButton.frame = dismissFrame;
    [self addSubview:self.dismissButton];
    
    __block CGRect contentFrame = masterFrame;
    contentFrame.size.height = _contentContainer.bounds.size.height;
    contentFrame.origin.y = masterFrame.size.height;
    _contentContainer.frame = contentFrame;
    [self addSubview:_contentContainer];
    self.tintColor = view.window.tintColor;
    
    [UIView animateWithDuration:kSlideInAnimationDuration delay:0
        usingSpringWithDamping:0.66f initialSpringVelocity:0.9f
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
            contentFrame.origin.y = masterFrame.size.height - (_contentContainer.bounds.size.height - kExtraHeightForBottomOverlap);
            _contentContainer.frame = contentFrame;
            self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
            view.window.tintColor = [view.window.tintColor fc_colorByModifyingHSBA:^(CGFloat *hue, CGFloat *saturation, CGFloat *brightness, CGFloat *alpha) {
                *saturation *= 0.1f;
                *brightness = 0.667f;
            }];
        }
        completion:^(BOOL finished) {
        }
    ];
}


@end
