//
//  SpriterXMLParser.m
//  hobobob
//
//  Created by spotco on 17/03/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpriterXMLParser.h"

@implementation SpriterXMLParser {
	TGSpriterConfigNode * configRoot_;
    TGSpriterConfigNode * curConfigNode_;
}

-(TGSpriterConfigNode*)parseSCML:(NSString *)filepath {
	NSString * path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filepath];
	NSData * scmlData = [NSData dataWithContentsOfFile:path];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:scmlData];
	parser.delegate = self;
	[parser parse];
	return configRoot_;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    configRoot_ = [TGSpriterConfigNode configNode:@"root"];
    curConfigNode_ = configRoot_;
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    TGSpriterConfigNode * newNode = [TGSpriterConfigNode configNode:elementName];
    newNode.parent = curConfigNode_;
    
    for (NSString * s in attributeDict) {
        [newNode.properties setObject:[attributeDict objectForKey:s] forKey:s];
    }
    
    [curConfigNode_.children addObject:newNode];
    curConfigNode_ = newNode;
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    curConfigNode_ = curConfigNode_.parent;
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (curConfigNode_.value == nil) {
        curConfigNode_.value = string;
    } else {
        curConfigNode_.value = [curConfigNode_.value stringByAppendingString:string];
    }
}
@end


@implementation TGSpriterConfigNode
@synthesize name=name_,parent=parent_,children=children_, value=value_, properties=properties_;
+(id) configNode:(NSString*)name {
    TGSpriterConfigNode * configNode;
    
    if ( (configNode = [[super alloc] init]) ) {
        configNode.name = name;
        configNode.children = [[NSMutableArray alloc] init];
        configNode.properties = [[NSMutableDictionary alloc] init];
    }
    
    return configNode;
}
-(float)getVal:(NSString*)key {
	return ((NSNumber*)properties_[key]).floatValue;
}
-(int)getId {
	return [self getVal:@"id"];
}
@end