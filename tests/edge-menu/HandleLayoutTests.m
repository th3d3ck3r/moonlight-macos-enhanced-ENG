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
                    panel.appearance = [NSAppearance appearanceNamed:i % 2 ? NSAppearanceNameDarkAqua : NSAppearanceNameAqua];
                    handle.compactAppearance = i % 2;
                    handle.activeAppearance = i % 3 == 0;
                    handle.dockEdge = i % 4;
                    [panel layoutIfNeeded];
                    [panel displayIfNeeded];
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                    // SF Symbols include baseline alignment insets; Auto Layout uses
                    // the alignment rect, not the NSImageView outer frame.
                    NSRect icon = [handle.iconView alignmentRectForFrame:handle.iconView.frame];
                    CGFloat expected = MIN(NSWidth(handle.bounds), NSHeight(handle.bounds)) * 0.32;
                    if (fabs(NSWidth(icon) - expected) > 1.0 ||
                        fabs(NSHeight(icon) - expected) > 1.0 ||
                        fabs(NSMidX(icon) - NSMidX(handle.bounds)) > 1.0 ||
                        fabs(NSMidY(icon) - NSMidY(handle.bounds)) > 1.0) {
                        NSLog(@"Incorrect handle geometry: %@ in %@", NSStringFromRect(icon), NSStringFromRect(handle.bounds));
                        return 1;
                    }
                }
                [panel close];
            }
            NSWindow *library = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 640, 420)
                styleMask:NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:NO];
            library.releasedWhenClosed = NO;
            for (int i = 0; i < 50; i++) {
                [MLCollectionEmptyState updateInView:library.contentView empty:YES
                    title:@"Connect to a computer" detail:@"Use the + button to add an address." symbol:@"desktopcomputer"];
                [MLCollectionEmptyState updateInView:library.contentView empty:YES
                    title:@"No matching computers" detail:@"Try a different search." symbol:@"desktopcomputer"];
                [library layoutIfNeeded];
                if (library.contentView.subviews.count != 1) return 1;
                [MLCollectionEmptyState updateInView:library.contentView empty:NO title:@"" detail:@"" symbol:@""];
                [library layoutIfNeeded];
                if (library.contentView.subviews.count != 0) return 1;
            }
            [library close];
        } @catch (NSException *exception) {
            NSLog(@"Handle display-cycle regression: %@", exception);
            return 1;
        }
        NSLog(@"Handle layout passed: 200 display cycles, light/dark and rectangular sizes");
    }
    return 0;
}
