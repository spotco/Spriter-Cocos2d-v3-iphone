#import "MainScene.h"

#import "CCTextureCache.h"
#import "SpriterNode.h"
#import "SpriterJSONParser.h"
#import "SpriterData.h"

@implementation MainScene

-(id)init {
	if (self = [super init]) {
		SpriterJSONParser *frame_data = [[[SpriterJSONParser alloc] init] parseFile:@"hanoka v0.01.json"];
		CCTexture *tex = [[CCTextureCache sharedTextureCache] addImage:@"hanoka v0.01.png"];
		SpriterData *spriter_data = [SpriterData dataFromSpriteSheet:tex frames:frame_data scml:@"hanoka v0.01.scml"];
		SpriterNode *img = [SpriterNode nodeFromData:spriter_data];
		[img playAnim:@"test" repeat:YES];
		[img setPosition:ccp(150,150)];
		[self addChild:img z:0];
	}
	return self;
}

@end
