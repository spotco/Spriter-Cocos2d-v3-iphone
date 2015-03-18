//
//  SpriterJSONParser.m
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpriterJSONParser.h"


@interface SpriterJSONFrame : NSObject
@property(readwrite,assign) CGRect val;
@end

@implementation SpriterJSONFrame
@synthesize val;
+(SpriterJSONFrame*)fromCGRect:(CGRect)rect {
	SpriterJSONFrame *rtv = [[SpriterJSONFrame alloc] init];
	rtv.val = rect;
	return rtv;
}
@end

@implementation SpriterJSONParser {
	NSMutableDictionary *_frames;
}

-(SpriterJSONParser*)parseFile:(NSString*)filepath {
	_frames = [NSMutableDictionary dictionary];

	NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filepath];
	NSData *jsonData = [NSData dataWithContentsOfFile:path];
	
	NSError *error = nil;
	NSDictionary *root = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
	NSDictionary *frames = root[@"frames"];
	for (NSString* key in frames) {
		NSDictionary *frame = frames[key][@"frame"];
		CGRect rect = CGRectMake(((NSNumber*)frame[@"x"]).intValue, ((NSNumber*)frame[@"y"]).intValue, ((NSNumber*)frame[@"w"]).intValue, ((NSNumber*)frame[@"h"]).intValue);
		_frames[key] = [SpriterJSONFrame fromCGRect:rect];
	}
	return self;
}

-(CGRect)cgRectForFrame:(NSString*)key {
	SpriterJSONFrame *rtv = _frames[key];
	return rtv.val;
}

@end
