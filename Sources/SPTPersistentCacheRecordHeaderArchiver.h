//
//  SPTPersistentCacheFileAttributesArchiver.h
//  SPTPersistentCache
//
//  Created by Maksym Shcheglov on 07/05/16.
//  Copyright © 2016 Spotify. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SPTPersistentCacheFileAttributesCoder;
@class SPTPersistentCacheRecordHeader;

@protocol SPTPersistentCacheFileAttributesCoding <NSObject>

- (void)encodeWithCoder:(SPTPersistentCacheFileAttributesCoder *)aCoder;
- (nullable instancetype)initWithCoder:(SPTPersistentCacheFileAttributesCoder *)aDecoder; // NS_DESIGNATED_INITIALIZER

@end

@interface SPTPersistentCacheFileAttributesCoder : NSObject

- (nullable instancetype)init NS_UNAVAILABLE;
+ (nullable instancetype)new NS_UNAVAILABLE;

- (nullable instancetype)initWithFilePath:(NSString*)filePath;

- (void)encodeUInt32:(uint32_t)intv forKey:(NSString *)key;
- (void)encodeUInt64:(uint64_t)intv forKey:(NSString *)key;

- (uint32_t)decodeUInt32ForKey:(NSString *)key;
- (uint64_t)decodeUInt64ForKey:(NSString *)key;

@end

@interface SPTPersistentCacheFileAttributesArchiver : NSObject

+ (BOOL)archivedCacheRecordHeader:(SPTPersistentCacheRecordHeader*)header toFileAtPath:(NSString*)filePath;
+ (nullable SPTPersistentCacheRecordHeader*)unarchivedCacheRecordHeaderFromFileAtPath:(NSString*)filePath;

@end

NS_ASSUME_NONNULL_END
