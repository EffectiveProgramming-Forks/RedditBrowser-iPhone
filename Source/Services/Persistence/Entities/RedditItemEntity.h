//
//  RedditItemEntity.h
//  RedditBrowser
//
//  Created by Luther Baker on 6/8/14.
//  Copyright (c) 2014 Effective Programming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RedditItemEntity : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subreddit;
@property (nonatomic, retain) NSString * permalink;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * uuid;

@end
