#import "SpriterTypes.h"

@implementation TGSpriterFolder
-(id)init {
	self = [super init];
	_files = [NSMutableDictionary dictionary];
	return self;
}
@synthesize _files;
@end

@implementation TGSpriterFile
@synthesize _id;
@synthesize _name;
@synthesize _pivot;
@synthesize _rect;
@end

@implementation TGSpriterAnimation
@synthesize _duration;
@synthesize _mainline_keys;
@synthesize _timelines;
@synthesize _name;
-(id) init {
    self = [super init];
	_mainline_keys = [NSMutableArray array];
	_timelines = [NSMutableDictionary dictionary];
    return self;
}
-(TGSpriterMainlineKey*)nth_mainline_key:(int)i { return _mainline_keys[i]; }
-(TGSpriterTimeline*)timeline_key_of_id:(int)i {
	return [_timelines objectForKey:[NSNumber numberWithInt:i]];
}
@end

@implementation TGSpriterObjectRef
@synthesize _parent_bone_id,_timeline_id, _zindex;
@synthesize _is_root;
@end

@implementation TGSpriterMainlineKey
@synthesize _bone_refs, _object_refs;
@synthesize _start_time;
-(id) init {
    self = [super init];
	_bone_refs = [NSMutableArray array];
	_object_refs = [NSMutableArray array];
    return self;
}
-(TGSpriterObjectRef*)nth_bone_ref:(int)i { return _bone_refs[i]; }
-(TGSpriterObjectRef*)nth_object_ref:(int)i { return _object_refs[i]; }
@end

@implementation TGSpriterTimeline
@synthesize keys=keys_;
@synthesize _id;
@synthesize _name;
+(id)spriterTimeline {
    return [[super alloc] init];
}
-(void) addKeyFrame:(TGSpriterTimelineKey*)frame {
    [keys_ addObject:frame];
}
-(id) init {
    if ( (self = [super init]) ) {
        keys_ = [[NSMutableArray alloc] init];
    }
    return self;
}
-(int)indexOfKeyForTime:(float)val {
	int i = 0;
	for (; i < keys_.count-1; i++) {
		TGSpriterTimelineKey *keyframe = keys_[i+1];
		if (keyframe.startsAt >= val) break;
	}
	return i;
}
-(TGSpriterTimelineKey*)keyForTime:(float)val {
	return keys_[[self indexOfKeyForTime:val]];
	
}
-(TGSpriterTimelineKey*)nextKeyForTime:(float)val {
	return keys_[([self indexOfKeyForTime:val]+1)%keys_.count];
}

@end

@implementation TGSpriterTimelineKey

@synthesize file=file_, folder=folder_, position=position_, anchorPoint=anchorPoint_, rotation=rotation_, startsAt=startsAt_, spin=spin_, scaleX=scaleX_, scaleY=scaleY_;

+(id)spriterTimelineKey {
    return [[super alloc] init];
}

@end