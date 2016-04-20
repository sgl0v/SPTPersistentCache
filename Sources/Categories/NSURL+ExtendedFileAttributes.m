//
//  NSURL+ExtendedFileAttributes.m
//  SPTPersistentCache
//
//  Created by Maksym Shcheglov on 21/04/16.
//  Copyright © 2016 Spotify. All rights reserved.
//

#import "NSURL+ExtendedFileAttributes.h"
#import "NSError+SPTPersistentCacheDomainErrors.h"
#include <sys/xattr.h>

static int const SPTPersistentCacheExtendedFileAttributesInvalidResult = -1;

@implementation NSURL (ExtendedFileAttributes)

- (BOOL)setExtendedAttributeValue:(id<NSCoding>)value forKey:(NSString *)key error:(NSError* __autoreleasing *)error
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    int res = setxattr(self.path.fileSystemRepresentation, [key UTF8String], [data bytes], [data length], 0, 0);
    if (res == SPTPersistentCacheExtendedFileAttributesInvalidResult && error) {
        *error = [NSError spt_persistentDataCacheErrorWithCode:errno];
        return NO;
    }
    return YES;
}

- (id)extendedAttributeValueForKey:(NSString *)key error:(NSError* __autoreleasing *)error
{
    const char *filepath = self.path.fileSystemRepresentation;
    const char *attrKey = [key UTF8String];
    void *buffer;
    ssize_t res = getxattr(filepath, attrKey, NULL, SIZE_T_MAX, 0, 0);
    if (res == SPTPersistentCacheExtendedFileAttributesInvalidResult) {
        if (error) {
            *error = [NSError spt_persistentDataCacheErrorWithCode:errno];
        }
        return nil;
    }
    size_t size = (size_t)res;
    buffer = calloc(1, size);
    res = getxattr(filepath, attrKey, buffer, size, 0, 0);
    if (res == SPTPersistentCacheExtendedFileAttributesInvalidResult) {
        free(buffer);
        if (error) {
            *error = [NSError spt_persistentDataCacheErrorWithCode:errno];
        }
        return nil;
    }
    NSData* objData = [NSData dataWithBytesNoCopy:buffer length:(NSUInteger)size];
    return [NSKeyedUnarchiver unarchiveObjectWithData:objData];
}

@end
