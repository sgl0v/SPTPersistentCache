//
//  NSURL+ExtendedFileAttributes.h
//  SPTPersistentCache
//
//  Created by Maksym Shcheglov on 21/04/16.
//  Copyright © 2016 Spotify. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (ExtendedFileAttributes)

- (BOOL)setExtendedAttributeValue:(id<NSCoding>)value forKey:(NSString *)key error:(NSError* __autoreleasing *)error;

- (id)extendedAttributeValueForKey:(NSString *)key error:(NSError* __autoreleasing *)error;

@end
