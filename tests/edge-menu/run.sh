#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
test_build="$(mktemp -d)"
trap 'rm -rf "$test_build"' EXIT
# Compile the actual shared material and handle implementations; isolate only
# declarations from the large streaming-controller header, not their behavior.
python3 - "$root" "$test_build" <<'PY'
import pathlib, sys
root, out = map(pathlib.Path, sys.argv[1:])
header = (root / 'Limelight/macOS/ViewControllers/StreamViewController_Internal.h').read_text()
start = header.index('@interface MLEdgeMenuHandleView')
end = header.index('@interface StreamViewController ()', start)
(out / 'HandleDeclarations.h').write_text('#import <AppKit/AppKit.h>\n#import <QuartzCore/QuartzCore.h>\n@interface MLNavigationMaterial : NSObject\n+ (NSView *)makeViewWithFrame:(NSRect)frame cornerRadius:(CGFloat)radius;\n@end\n@interface MLCollectionEmptyState : NSObject\n+ (void)updateInView:(NSView *)view empty:(BOOL)empty title:(NSString *)title detail:(NSString *)detail symbol:(NSString *)symbol;\n@end\ntypedef NSInteger MLFreeMouseExitEdge;\n' + header[start:end])
source = (root / 'Limelight/macOS/ViewControllers/MLEdgeMenuUI.m').read_text()
(out / 'Handle.m').write_text(source.replace('#import "StreamViewController_Internal.h"', '#import "HandleDeclarations.h"'))
PY
xcrun swiftc -parse-as-library -emit-library -emit-objc-header -module-name Materials \
  "$root/Limelight/macOS/Helpers/ViewExtensions.swift" \
  -emit-objc-header-path "$test_build/Materials-Swift.h" -o "$test_build/libMaterials.dylib"
xcrun clang -fobjc-arc -fblocks -framework AppKit -framework QuartzCore \
  -I "$test_build" "$test_build/Handle.m" "$root/tests/edge-menu/HandleLayoutTests.m" \
  -L "$test_build" -lMaterials -Wl,-rpath,"$test_build" -o "$test_build/handle-tests"
"$test_build/handle-tests"
