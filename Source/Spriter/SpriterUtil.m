//
//  SpriterUtil.m
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpriterUtil.h"

@implementation NSDictionary (KeySet)
-(NSSet*)keySet {
	NSMutableArray *rtv = [NSMutableArray array];
	for (id obj in [self keyEnumerator]) {
		[rtv addObject:obj];
	}
	return [NSSet setWithArray:rtv];
}
@end

float sbezier_val_for_t(float p0, float p1, float p2, float p3, float t) {
	float cp0 = (1 - t)*(1 - t)*(1 - t);
	float cp1 = 3 * t * (1-t)*(1-t);
	float cp2 = 3 * t * t * (1 - t);
	float cp3 = t * t * t;
	return cp0 * p0 + cp1 * p1 + cp2 * p2 + cp3 * p3;
}

CGPoint sbezier_point_for_t(CGPoint p0, CGPoint p1, CGPoint p2, CGPoint p3, float t) {
	return ccp(
		sbezier_val_for_t(p0.x, p1.x, p2.x, p3.x, t),
		sbezier_val_for_t(p0.y, p1.y, p2.y, p3.y, t)
	);
}

float scubic_interp(float a, float b, float c1, float c2, float t) {
	CGPoint bez = sbezier_point_for_t(ccp(0,0), ccp(0.25,c1), ccp(0.75,c2), ccp(1,1), t);
	return bez.y * (b-a) + a;
}

float sshortest_angle(float src, float dest) {
	float shortest_angle=fmod((fmod((dest - src) , 360) + 540), 360) - 180;
	return shortest_angle;
}

float scubic_angular_interp(float src, float dest, float c1, float c2, float t) {
	t = scubic_interp(0, 1, c1, c2, t);
	return src + sshortest_angle(src, dest) * t;
}
