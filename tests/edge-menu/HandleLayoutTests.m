#import "HandleDeclarations.h"
#include <math.h>

int main(void) {
    @autoreleasepool {
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        @try {
            for (NSString *appearance in @[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]) {
                MLEdgeMenuPanel *panel = [[MLEdgeMenuPanel alloc]
                    initWithContentRect:NSMakeRect(100, 100, 56, 56)
                    styleMask:NSWindowStyleMaskBorderless | NSWindowStyleMaskNonactivatingPanel
                    backing:NSBackingStoreBuffered defer:NO];
                panel.releasedWhenClosed = NO;
                panel.appearance = [NSAppearance appearanceNamed:appearance];
                MLEdgeMenuHandleView *handle = [[MLEdgeMenuHandleView alloc] initWithFrame:panel.contentView.bounds];
                handle.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
                handle.iconView.image = [NSImage imageWithSystemSymbolName:@"slider.horizontal.3" accessibilityDescription:nil];
                [panel.contentView addSubview:handle];
                [panel orderFront:nil];
                for (int i = 0; i < 100; i++) {
                    NSSize size = NSMakeSize(32 + i % 53, 32 + (i * 7) % 53);
                    [panel setContentSize:size];
                    handle.compactAppearance = i % 2;
                    handle.activeAppearance = i % 3 == 0;
                    handle.dockEdge = i % 4;
                    [panel layoutIfNeeded];
                    [panel displayIfNeeded];
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                    NSRect icon = handle.iconView.frame;
                    CGFloat expected = MIN(NSWidth(handle.bounds), NSHeight(handle.bounds)) * 0.32;
                    if (fabs(NSWidth(icon) - expected) > 0.1 ||
                        fabs(NSHeight(icon) - expected) > 0.1 ||
                        fabs(NSMidX(icon) - NSMidX(handle.bounds)) > 0.1 ||
                        fabs(NSMidY(icon) - NSMidY(handle.bounds)) > 0.1) {
                        NSLog(@"Incorrect handle geometry: %@ in %@", NSStringFromRect(icon), NSStringFromRect(handle.bounds));
                        return 1;
                    }
                }
                [panel close];
            }
        } @catch (NSException *exception) {
            NSLog(@"Handle display-cycle regression: %@", exception);
            return 1;
        }
        NSLog(@"Handle layout passed: 200 display cycles, light/dark and rectangular sizes");
    }
    return 0;
}
