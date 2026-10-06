#import <Foundation/Foundation.h>
#import "HttpResponse.h"
#import "AppListResponse.h"
#import "TemporaryApp.h"
#include <assert.h>

@implementation TemporaryApp
@end

static NSData *xml(NSString *value) {
    return [value dataUsingEncoding:NSUTF8StringEncoding];
}

int main(void) {
    @autoreleasepool {
        HttpResponse *response = [HttpResponse new];
        [response populateWithData:xml(@"<root status_code='200' status_message='OK'>\n<state>SUNSHINE_SERVER_FREE</state><empty/>\n</root>")];
        assert(response.isStatusOk);
        assert([[response getStringTag:@"state"] isEqualToString:@"SUNSHINE_SERVER_FREE"]);
        assert([[response getStringTag:@"empty"] isEqualToString:@""]);

        NSArray<NSString *> *invalid = @[
            @"", @"not xml", @"<root>", @"<root status_code='not-a-number'/>",
            @"<!DOCTYPE root [<!ENTITY secret SYSTEM 'file:///etc/passwd'>]><root status_code='200'><secret>&secret;</secret></root>",
            @"<!DOCTYPE root [<!ENTITY text 'hello'>]><root status_code='200'><state>&text;</state></root>",
            @"<!DOCTYPE root SYSTEM 'https://example.invalid/remote.dtd'><root status_code='200'/>"
        ];
        for (NSString *input in invalid) {
            // Reuse the same parser: invalid input must not retain success/data.
            [response populateWithData:xml(input)];
            assert(!response.isStatusOk);
            assert([response getStringTag:@"state"] == nil);
            AppListResponse *apps = [AppListResponse new];
            [apps populateWithData:xml(input)];
            assert(!apps.isStatusOk);
            assert(apps.getAppList.count == 0);
        }

        AppListResponse *apps = [AppListResponse new];
        [apps populateWithData:xml(@"<root status_code='200'><App><ID>1</ID><AppTitle/><IsHdrSupported>1</IsHdrSupported></App><App><ID>2</ID><AppTitle>Desktop</AppTitle></App><App><ID>0</ID></App><App><ID>invalid</ID></App><App><AppTitle>Missing ID</AppTitle></App></root>")];
        assert(apps.isStatusOk);
        assert(apps.getAppList.count == 2);
        for (TemporaryApp *app in apps.getAppList) {
            assert(app.name != nil);
            if ([app.id isEqualToString:@"1"]) {
                assert(app.name.length == 0 && app.hdrSupported);
            }
        }
        [apps populateWithData:xml(@"<bad>")];
        assert(!apps.isStatusOk && apps.getAppList.count == 0);
        puts("PASS: actual native host XML parsers reject malformed/DTD responses and preserve valid/empty-title apps");
    }
    return 0;
}
