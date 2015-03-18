#import <Foundation/Foundation.h>

@interface TGSpriterFolder : NSObject
@property(readwrite,assign) int _id;
@property(readwrite,strong) NSMutableDictionary *_files;
@end

@interface TGSpriterFile : NSObject
@property(readwrite,assign) int _id;
@property(readwrite,assign) NSString *_name;
@property(readwrite,assign) CGRect _rect;
@property(readwrite,assign) CGPoint _pivot;
@end

@interface TGSpriterObjectRef : NSObject
@property(readwrite,assign) int _id, _parent_bone_id, _timeline_id, _zindex;
@property(readwrite,assign) bool _is_root;
@end

@interface TGSpriterMainlineKey : NSObject
@property(readwrite,assign) int _start_time;
@property(readwrite,strong) NSMutableArray *_bone_refs, *_object_refs;
-(TGSpriterObjectRef*)nth_bone_ref:(int)i;
-(TGSpriterObjectRef*)nth_object_ref:(int)i;
@end

@interface TGSpriterTimelineKey : NSObject {
    int file_;
    int folder_;
    double startsAt_;
    CGPoint position_;
    CGPoint anchorPoint_;
    double rotation_;
    int spin_;
    double scaleX_;
    double scaleY_;
}
@property int file;
@property int folder;
@property double startsAt;
@property CGPoint position;
@property CGPoint anchorPoint;
@property double rotation;
@property int spin;
@property double scaleX;
@property double scaleY;
+(id) spriterTimelineKey;
@end

@interface TGSpriterTimeline : NSObject {
    NSMutableArray * keys_; 
}
@property (nonatomic, readonly) NSMutableArray * keys;
@property(readwrite,strong) NSString *_name;
@property(readwrite,assign) int _id;
+(id)spriterTimeline;
-(void)addKeyFrame:(TGSpriterTimelineKey*)frame;
-(TGSpriterTimelineKey*)keyForTime:(float)val;
-(TGSpriterTimelineKey*)nextKeyForTime:(float)val;
-(int)indexOfKeyForTime:(float)val;
@end

@interface TGSpriterAnimation : NSObject
@property(readwrite,assign) NSString *_name;
@property(readwrite,strong) NSMutableArray *_mainline_keys;
@property(readwrite,strong) NSMutableDictionary *_timelines;
@property(readwrite,assign) long _duration;
-(TGSpriterMainlineKey*)nth_mainline_key:(int)i;
-(TGSpriterTimeline*)timeline_key_of_id:(int)i;
@end
