#import "SpriterData.h"

@interface SpriterJSONParser : NSObject <SpriteSheetReader>
-(SpriterJSONParser*)parseFile:(NSString*)filepath;
-(CGRect)cgRectForFrame:(NSString*)key;
@end
