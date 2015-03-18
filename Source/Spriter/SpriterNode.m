#import "SpriterNode.h"
#import "SpriterData.h"
#import "SpriterTypes.h"
#import "SpriterUtil.h"

@interface CCNode_Bone : CCNode
@property(readwrite,assign) int _timeline_id;
@end
@implementation CCNode_Bone
@synthesize _timeline_id;
@end

@interface CCSprite_Object : CCSprite
@property(readwrite,assign) int _timeline_id, _zindex;
@end
@implementation CCSprite_Object
@synthesize _timeline_id, _zindex;
@end

@implementation SpriterNode {
	SpriterData *_data;
	NSMutableDictionary *_bones;
	NSMutableDictionary *_objs;
	CCNode_Bone *_root_bone;
	
	NSString *_current_anim_name;
	
	float _current_anim_time;
	int _mainline_key_index;
	int _anim_duration;
	BOOL _repeat_anim;
	BOOL _anim_finished;
}

-(BOOL)current_anim_repeating { return _repeat_anim; }
-(BOOL)current_anim_finished { return _anim_finished; }

+(SpriterNode*)nodeFromData:(SpriterData*)data {
	return [[SpriterNode node] initFromData:data];
}
-(SpriterNode*)initFromData:(SpriterData*)data {
	_data = data;
	_bones = [NSMutableDictionary dictionary];
	_objs = [NSMutableDictionary dictionary];
	_root_bone = NULL;
	
	return self;
}

-(void)playAnim:(NSString *)anim_name repeat:(BOOL)repeat {
	if (![_data anim_of_name:anim_name]) {
		NSLog(@"does not contain animation %@",anim_name);
		return;
	}
	_mainline_key_index = 0;
	_current_anim_time = 0;
	_current_anim_name = anim_name;
	_anim_duration = (long)[_data anim_of_name:anim_name]._duration;
	_repeat_anim = repeat;
	_anim_finished = NO;
	
	[self update_mainline_keyframes];
	[self update_timeline_keyframes];
}

-(void)update:(CCTime)delta {
	_current_anim_time += delta * 1000;
	if (_current_anim_time > _anim_duration) {
		if (_repeat_anim) {
			_current_anim_time = _current_anim_time-_anim_duration;
		} else {
			_current_anim_time = _anim_duration;
			_anim_finished = YES;
		}
	}
	
	[self update_timeline_keyframes];
}

-(void)update_timeline_keyframes {
	for (NSNumber *itr in _bones) {
		CCNode_Bone *itr_bone = _bones[itr];
		TGSpriterTimeline *timeline = [[_data anim_of_name:_current_anim_name] timeline_key_of_id:itr_bone._timeline_id];
		TGSpriterTimelineKey *keyframe_current = [timeline keyForTime:_current_anim_time];
		TGSpriterTimelineKey *keyframe_next = [timeline nextKeyForTime:_current_anim_time];
		float t = clampf((_current_anim_time-keyframe_current.startsAt)/(keyframe_next.startsAt-keyframe_current.startsAt),0,1);
		[self interpolate:itr_bone from:keyframe_current to:keyframe_next t:t cp1:ccp(0.25,0) cp2:ccp(0.75, 1)];
	}
	for (NSNumber *itr in _objs) {
		CCSprite_Object *itr_obj = _objs[itr];
		TGSpriterTimeline *timeline = [[_data anim_of_name:_current_anim_name] timeline_key_of_id:itr_obj._timeline_id];
		TGSpriterTimelineKey *keyframe_current = [timeline keyForTime:_current_anim_time];
		TGSpriterTimelineKey *keyframe_next = [timeline nextKeyForTime:_current_anim_time];
		float t = clampf((_current_anim_time-keyframe_current.startsAt)/(keyframe_next.startsAt-keyframe_current.startsAt),0,1);
		[self interpolate:itr_obj from:keyframe_current to:keyframe_next t:t cp1:ccp(0.25,0) cp2:ccp(0.75, 1)];
		
		TGSpriterFile *file = [_data file_for_folderid:keyframe_current.folder fileid:keyframe_current.file];
		itr_obj.texture = [_data texture];
		itr_obj.textureRect = file._rect;
		itr_obj.anchorPoint = file._pivot;
	}
}

-(void)interpolate:(CCNode*)node from:(TGSpriterTimelineKey*)from to:(TGSpriterTimelineKey*)to t:(float)t cp1:(CGPoint)cp1 cp2:(CGPoint)cp2 {
	float cubic_c1 = 0;
	float cubic_c2 = 1;

	node.position = ccp(scubic_interp(from.position.x, to.position.x, cubic_c1, cubic_c2, t),scubic_interp(from.position.y, to.position.y, cubic_c1, cubic_c2, t));
	node.rotation = scubic_angular_interp(from.rotation, to.rotation, cubic_c1, cubic_c2, t);
	node.scaleX = scubic_interp(from.scaleX, to.scaleX, cubic_c1, cubic_c2, t);
	node.scaleY = scubic_interp(from.scaleY, to.scaleY, cubic_c1, cubic_c2, t);
	node.anchorPoint = ccp(scubic_interp(from.anchorPoint.x, to.anchorPoint.x, cubic_c1, cubic_c2, t),scubic_interp(from.anchorPoint.y, to.anchorPoint.y, cubic_c1, cubic_c2, t));
}

-(void)update_mainline_keyframes {
	TGSpriterAnimation *anim = [_data anim_of_name:_current_anim_name];
	TGSpriterMainlineKey *mainline_key = [anim nth_mainline_key:_mainline_key_index];
	[self make_bone_hierarchy:mainline_key];
	[self attach_objects_to_bone_hierarchy:mainline_key];
	[self set_z_indexes:_root_bone];
}

-(int)set_z_indexes:(CCNode*)itr {
	if ([itr isKindOfClass:[CCNode_Bone class]]) {
		int z = 0;
		for (CCNode *child in itr.children) {
			z = MAX([self set_z_indexes:child], z);
		}
		[itr setZOrder:z];
		return z;
		
	} else {
		CCSprite_Object *itr_obj = (CCSprite_Object*)itr;
		[itr setZOrder:itr_obj._zindex];
		return itr_obj._zindex;
	}
}

-(void)make_bone_hierarchy:(TGSpriterMainlineKey*)mainline_key {
	NSMutableSet *unadded_bones = [NSMutableSet setWithSet:[_bones keySet]];
	
	for (int i = 0; i < mainline_key._bone_refs.count; i++) {
		TGSpriterObjectRef *bone_ref = [mainline_key nth_bone_ref:i];
		NSNumber *bone_ref_id = [NSNumber numberWithInt:bone_ref._id];
		if (![_bones objectForKey:bone_ref_id]) {
			_bones[bone_ref_id] = [CCNode_Bone node];
		} else {
			[unadded_bones removeObject:bone_ref_id];
		}
		CCNode_Bone *itr_bone = _bones[bone_ref_id];
		itr_bone._timeline_id = bone_ref._timeline_id;
	}
	
	for (int i = 0; i < mainline_key._bone_refs.count; i++) {
		TGSpriterObjectRef *bone_ref = [mainline_key nth_bone_ref:i];
		NSNumber *bone_ref_id = [NSNumber numberWithInt:bone_ref._id];
		CCNode_Bone *itr_bone = _bones[bone_ref_id];
		
		[itr_bone removeFromParent];
		if (bone_ref._is_root) {
			_root_bone = itr_bone;
			[self addChild:_root_bone];
		} else {
			CCNode_Bone *itr_bone_parent = _bones[[NSNumber numberWithInt:bone_ref._parent_bone_id]];
			[itr_bone_parent addChild:itr_bone];
		}
		
	}
	
	for (NSNumber *itr in unadded_bones) {
		CCNode_Bone *itr_bone = _bones[itr];
		[itr_bone removeFromParent];
		[_bones removeObjectForKey:itr];
	}
}

-(void)attach_objects_to_bone_hierarchy:(TGSpriterMainlineKey*)mainline_key {
	NSMutableSet *unadded_objects = [NSMutableSet setWithSet:[_objs keySet]];
	for (int i = 0; i < mainline_key._object_refs.count; i++) {
		TGSpriterObjectRef *obj_ref = [mainline_key nth_object_ref:i];
		NSNumber *obj_ref_id = [NSNumber numberWithInt:obj_ref._id];
		if (![_objs objectForKey:obj_ref_id]) {
			_objs[obj_ref_id] = [CCSprite_Object node];
		} else {
			[unadded_objects removeObject:obj_ref_id];
		}
		CCSprite_Object *itr_obj = _objs[obj_ref_id];
		[itr_obj removeFromParent];
		itr_obj._timeline_id = obj_ref._timeline_id;
		itr_obj._zindex = obj_ref._zindex;
		
		CCNode_Bone *itr_bone_parent = _bones[[NSNumber numberWithInt:obj_ref._parent_bone_id]];
		[itr_bone_parent addChild:itr_obj z:itr_obj._zindex];
	}
	
	for (NSNumber *itr in unadded_objects) {
		CCSprite_Object *itr_objs = _objs[itr];
		[itr_objs removeFromParent];
		[_objs removeObjectForKey:itr];
	}
}

@end
