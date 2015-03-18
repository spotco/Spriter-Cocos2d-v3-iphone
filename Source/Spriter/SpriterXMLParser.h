#import <Foundation/Foundation.h>

@interface TGSpriterConfigNode : NSObject {
    NSString * name_;
    TGSpriterConfigNode * parent_;
    NSMutableArray * children_;
    NSString * value_;
    NSMutableDictionary * properties_;
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) TGSpriterConfigNode * parent;
@property (nonatomic, retain) NSMutableArray * children;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSMutableDictionary * properties;
+(id) configNode:(NSString*)name;
-(int)getId;
-(float)getVal:(NSString*)key;
@end

@interface SpriterXMLParser : NSObject <NSXMLParserDelegate>
-(TGSpriterConfigNode*)parseSCML:(NSString*)filepath;
@end
