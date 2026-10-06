#import <Foundation/Foundation.h>
#import "Logger.h"
#import "LogBuffer.h"
#include <assert.h>

int main(void) {
    @autoreleasepool {
        LoggerSetMinimumLevel(LOG_D);
        NSArray<NSString *> *secrets = @[@"SENSITIVE_KEY_VALUE", @"SENSITIVE_UID_VALUE",
            @"SENSITIVE_PAIR_VALUE", @"SENSITIVE_XML_VALUE", @"SENSITIVE_DICT_VALUE",
            @"SENSITIVE_PIN_VALUE", @"SENSITIVE_SALT_VALUE"];
        Log(LOG_I, @"Requesting: https://host/launch?appid=7&RIKEY=%@&uniqueid=%@&mode=1920x1080x60", secrets[0], secrets[1]);
        LogTag(LOG_W, @"pair", @"https://host/pair?clientpairingsecret=%@", secrets[2]);
        LogTag(LOG_W, @"pair", @"https://host/pair?clientpairingsecret=%@", secrets[2]);
        LoggerPersistMessage(LOG_D, [NSString stringWithFormat:@"<root><serverpairingsecret>%@</serverpairingsecret></root>", secrets[3]]);
        LogMessage(LOG_I, [NSString stringWithFormat:@"Parsed XML data: {challengeresponse = %@; state = FREE;}", secrets[4]]);
        LogTaggedMessage(LOG_I, @"pair", [NSString stringWithFormat:@"PIN: %@, saltedPIN: <%@>", secrets[5], secrets[6]]);
        Log(LOG_I, @"Normal frame pacing: 60 fps");

        NSString *overlay = [[[LogBuffer shared] allLines] componentsJoinedByString:@"\n"];
        assert([overlay containsString:@"[REDACTED]"]);
        assert([overlay containsString:@"appid=7"] && [overlay containsString:@"mode=1920x1080x60"]);
        assert([overlay containsString:@"Normal frame pacing: 60 fps"]);
        for (NSString *secret in secrets) assert(![overlay containsString:secret]);

        NSString *library = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        NSString *directory = [library stringByAppendingPathComponent:@"Logs/Moonlight"];
        for (NSString *filename in @[@"moonlight-debug.log", @"moonlight-debug-curated.log"]) {
            NSString *content = [NSString stringWithContentsOfFile:[directory stringByAppendingPathComponent:filename]
                encoding:NSUTF8StringEncoding error:NULL];
            assert(content != nil && [content containsString:@"[REDACTED]"]);
            for (NSString *secret in secrets) assert(![content containsString:secret]);
        }
        puts("PASS: production logger redacts protocol credentials from overlay, raw and curated files");
    }
    return 0;
}
