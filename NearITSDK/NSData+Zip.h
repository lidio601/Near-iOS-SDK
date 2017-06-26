//
//  NSData+Zip.h
//  NearITSDK
//
//  Created by Francesco Leoni on 26/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSDataZip)

// ZLIB
- (NSData *) zlibInflate;
- (NSData *) zlibDeflate;

// GZIP
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;

@end
