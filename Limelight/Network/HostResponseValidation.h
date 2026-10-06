#pragma once

#import <Foundation/Foundation.h>
#include <limits.h>

// NSString's integerValue accepts a numeric prefix (for example, "200oops").
// Protocol fields must contain a complete, bounded ASCII decimal value.
static inline BOOL MLParseHostDecimal(NSString *text, NSInteger maximum, NSInteger *value) {
    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    const char *digits = trimmed.UTF8String;
    if (digits == NULL || *digits == '\0') return NO;

    NSInteger result = 0;
    for (const char *p = digits; *p != '\0'; p++) {
        if (*p < '0' || *p > '9') return NO;
        NSInteger digit = *p - '0';
        if (result > (maximum - digit) / 10) return NO;
        result = result * 10 + digit;
    }
    *value = result;
    return YES;
}
