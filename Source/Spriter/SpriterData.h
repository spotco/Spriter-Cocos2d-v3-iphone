#import "CCNode.h"

@class TGSpriterAnimation;
@class TGSpriterFile;

@protocol SpriteSheetReader <NSObject>
-(CGRect)cgRectForFrame:(NSString*)key;
@end

@interface SpriterData : NSObject
+(SpriterData*)dataFromSpriteSheet:(CCTexture*)spriteSheet frames:(id<SpriteSheetReader>)frames scml:(NSString*)scml;
-(NSDictionary*)folders;
-(NSDictionary*)animations;
-(NSArray*)bones;
-(CCTexture*)texture;
-(TGSpriterAnimation*)anim_of_name:(NSString*)name;
-(TGSpriterFile*)file_for_folderid:(int)folderid fileid:(int)fileid;
@end
