//
//  HttpResponse.m
//  Moonlight
//
//  Created by Diego Waxemberg on 1/30/15.
//  Copyright (c) 2015 Moonlight Stream. All rights reserved.
//

#import "HttpResponse.h"
#import "TemporaryApp.h"
#import <libxml2/libxml/xmlreader.h>
#import "HostResponseValidation.h"
#include <limits.h>

@implementation HttpResponse {
    NSMutableDictionary* _elements;
}
@synthesize data, statusCode, statusMessage;

- (void) populateWithData:(NSData*)xml {
    self.data = xml;
    [self parseData];
}

- (NSString*) getStringTag:(NSString*)tag {
    return [_elements objectForKey:tag];
}

- (BOOL) getIntTag:(NSString *)tag value:(NSInteger*)value {
    NSString* stringVal = [self getStringTag:tag];
    return MLParseHostDecimal(stringVal, INT_MAX, value);
}

- (BOOL) isStatusOk {
    return self.statusCode == 200;
}

- (void) parseData {
    _elements = [[NSMutableDictionary alloc] init];
    self.statusCode = 0;
    self.statusMessage = @"Invalid host response";
    if (self.data.length == 0 || self.data.length > INT_MAX) {
        Log(LOG_W, @"Empty or oversized host XML response");
        return;
    }
    xmlDocPtr docPtr = xmlReadMemory(self.data.bytes, (int)self.data.length,
        NULL, NULL, XML_PARSE_NONET);

    if (docPtr == NULL) {
        Log(LOG_W, @"Unable to parse host XML response.");
        return;
    }
    
    // GameStream responses do not use DTDs. Reject entity declarations and
    // external subsets rather than expanding untrusted host XML.
    if (docPtr->intSubset != NULL || docPtr->extSubset != NULL) {
        Log(LOG_W, @"Rejected host XML containing a DTD");
        xmlFreeDoc(docPtr);
        return;
    }
    xmlNodePtr node = xmlDocGetRootElement(docPtr);
    if (node == NULL || xmlStrcmp(node->name, (const xmlChar *)"root") != 0) {
        Log(LOG_W, @"Missing or unexpected host XML root element.");
        xmlFreeDoc(docPtr);
        return;
    }

    xmlChar* statusStr = xmlGetProp(node, (const xmlChar*)[TAG_STATUS_CODE UTF8String]);
    NSInteger status = 0;
    BOOL validStatus = statusStr != NULL && MLParseHostDecimal(
        [NSString stringWithUTF8String:(const char *)statusStr], INT_MAX, &status);
    xmlFree(statusStr);
    if (!validStatus) {
        Log(LOG_W, @"Invalid host XML status code");
        xmlFreeDoc(docPtr);
        return;
    }
    self.statusCode = status;
    
    xmlChar* statusMsgXml = xmlGetProp(node, (const xmlChar*)[TAG_STATUS_MESSAGE UTF8String]);
    NSString* statusMsg;
    if (statusMsgXml != NULL) {
        statusMsg = [NSString stringWithUTF8String:(const char*)statusMsgXml];
        xmlFree(statusMsgXml);
    }
    else {
        statusMsg = @"Server Error";
    }
    self.statusMessage = statusMsg;

    node = node->children;
    
    while (node != NULL) {
        if (node->type != XML_ELEMENT_NODE) {
            node = node->next;
            continue;
        }
        xmlChar* nodeVal = xmlNodeListGetString(docPtr, node->xmlChildrenNode, 1);
        
        NSString* value;
        if (nodeVal == NULL) {
            value = @"";
        } else {
            value = [[NSString alloc] initWithCString:(const char*)nodeVal encoding:NSUTF8StringEncoding];
        }
        NSString* key = [[NSString alloc] initWithCString:(const char*)node->name encoding:NSUTF8StringEncoding];
        if (key != nil && value != nil) {
            [_elements setObject:value forKey:key];
        }
        xmlFree(nodeVal);
        node = node->next;
    }
    
    xmlFreeDoc(docPtr);
    
    Log(LOG_D, @"Parsed XML data: %@", _elements);
}

@end
