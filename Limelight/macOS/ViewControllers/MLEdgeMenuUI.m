//
//  MLEdgeMenuUI.m
//  Moonlight for macOS
//

#import "StreamViewController_Internal.h"

@implementation MLEdgeMenuHandleView {
    NSImageView *_iconView;
    NSView *_navigationBackground;
    NSPoint _mouseDownPointOnScreen;
    BOOL _dragStarted;
    NSTrackingArea *_trackingArea;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = YES;
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 28.0;

        _navigationBackground = [MLNavigationMaterial makeViewWithFrame:self.bounds cornerRadius:16.0];
        _navigationBackground.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self addSubview:_navigationBackground];

        _iconView = [[NSImageView alloc] initWithFrame:NSZeroRect];
        _iconView.imageScaling = NSImageScaleProportionallyUpOrDown;
        _iconView.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        [self addSubview:_iconView];

        [self updateVisualStyle];
    }
    return self;
}

- (NSImageView *)iconView {
    return _iconView;
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (NSView *)hitTest:(NSPoint)point {
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) * 0.33;
    NSBezierPath *hitPath = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:radius yRadius:radius];
    return [hitPath containsPoint:point] ? self : nil;
}

- (void)setActiveAppearance:(BOOL)activeAppearance {
    _activeAppearance = activeAppearance;
    [self updateVisualStyle];
}

- (void)setCompactAppearance:(BOOL)compactAppearance {
    _compactAppearance = compactAppearance;
    [self setNeedsLayout:YES];
    [self updateVisualStyle];
}

- (void)setDockEdge:(MLFreeMouseExitEdge)dockEdge {
    _dockEdge = dockEdge;
    [self setNeedsLayout:YES];
    [self updateVisualStyle];
}

- (void)layout {
    [super layout];

    CGFloat iconSize = MIN(self.bounds.size.width, self.bounds.size.height) * 0.32;
    _iconView.frame = NSMakeRect((NSWidth(self.bounds) - iconSize) / 2.0,
                                 (NSHeight(self.bounds) - iconSize) / 2.0,
                                 iconSize, iconSize);
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];

    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
    }

    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect;
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:options owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered:event];
    if (self.hoverHandler) {
        self.hoverHandler(YES);
    }
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    if (self.hoverHandler) {
        self.hoverHandler(NO);
    }
}

- (void)updateVisualStyle {
    _iconView.contentTintColor = self.activeAppearance ? NSColor.controlAccentColor : NSColor.labelColor;
}

- (void)mouseDown:(NSEvent *)event {
    _mouseDownPointOnScreen = [NSEvent mouseLocation];
    _dragStarted = NO;
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint screenPoint = [NSEvent mouseLocation];
    NSPoint translation = NSMakePoint(screenPoint.x - _mouseDownPointOnScreen.x,
                                      screenPoint.y - _mouseDownPointOnScreen.y);
    if (!_dragStarted) {
        if (fabs(translation.x) < 2.0 && fabs(translation.y) < 2.0) {
            return;
        }
        _dragStarted = YES;
        if (self.dragHandler) {
            self.dragHandler(NSGestureRecognizerStateBegan, NSZeroPoint);
        }
    }

    if (self.dragHandler) {
        self.dragHandler(NSGestureRecognizerStateChanged, translation);
    }
}

- (void)mouseUp:(NSEvent *)event {
    NSPoint screenPoint = [NSEvent mouseLocation];
    NSPoint translation = NSMakePoint(screenPoint.x - _mouseDownPointOnScreen.x,
                                      screenPoint.y - _mouseDownPointOnScreen.y);
    if (_dragStarted) {
        if (self.dragHandler) {
            self.dragHandler(NSGestureRecognizerStateEnded, translation);
        }
    } else if (self.activationHandler) {
        self.activationHandler(event);
    }
}

- (void)mouseMoved:(NSEvent *)event {
    [super mouseMoved:event];
    if (self.hoverHandler) {
        self.hoverHandler(YES);
    }
}


@end

@implementation MLEdgeMenuPanel

- (BOOL)canBecomeKeyWindow {
    return NO;
}

- (BOOL)canBecomeMainWindow {
    return NO;
}

@end
