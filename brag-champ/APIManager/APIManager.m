//
//  APIManager.m
//  brag-champ
//
//  Created by Apple on 12/23/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "APIManager.h"

#import <AFNetworking.h>
#import "User.h"
#import "Me.h"
#import "Video.h"
#import "ChallengeVideo.h"
#import "Comment.h"
#import "Notification.h"
#import "Message.h"

#define kAPIBaseURL         @"https://bragchamp.com/api/api.php"

@implementation APIManager

+ (instancetype)sharedManager {
    static APIManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[APIManager alloc] init];
    });
    
    return manager;
}


- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(Me *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"login",
                                 @"user_name" : username,
                                 @"password" : password};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  Me *me = [Me userWithDictionary:responseObject[@"data"]];
                  if (success) {
                      success(me);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)signupWithFirstname:(NSString *)firstname lastname:(NSString *)lastname email:(NSString *)email birthday:(NSString *)birthday username:(NSString *)username password:(NSString *)password success:(void (^)(Me *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"signup",
                                 @"fname" : firstname,
                                 @"lname" : lastname,
                                 @"email" : email,
                                 @"birthday" : birthday,
                                 @"user_name" : username,
                                 @"password" : password};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"data"]];
                  dict[@"user_name"] = username;
                  dict[@"fname"] = firstname;
                  dict[@"lname"] = lastname;
                  dict[@"email"] = email;
                  dict[@"birthday"] = birthday;
                  
                  Me *me = [Me userWithDictionary:dict];
                  if (success) {
                      success(me);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}


- (void)uploadThumbnail:(Me *)me image:(UIImage *)image success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"upload_thumbnail",
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString *name = [NSString stringWithFormat:@"%ld-%ld.jpg", (long)me.userId, (long)time(NULL)];
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5) name:@"file" fileName:name mimeType:@"image/jpeg"];
    }
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
        NSString *status = responseObject[@"status"];
        if ([status isEqualToString:@"success"]) {
            if (success) {
                success(responseObject[@"thumbnail_url"]);
            }
        } else {
            if (failed) {
                failed(responseObject[@"message"], nil);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(nil, error);
        }
    }];
}

- (void)postVideo:(Me *)me challengeTitle:(NSString *)title challengers:(NSInteger)count public:(BOOL)isPublic hashTags:(NSString *)tags videoURL:(NSURL *)url thumbnail:(NSString *)thumbnail progress:(void (^)(NSInteger))progress success:(void (^)(Video *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"postvideo",
                                 @"user_id" : @(me.userId),
                                 @"ch_title" : title,
                                 @"ch_count" : @(count),
                                 @"ch_mode" : @(isPublic ? 0 : 1),
                                 @"hashtags" : tags,
                                 @"thumbnail_url" : thumbnail,
                                 @"authkey" : me.authKey};

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString *name = [NSString stringWithFormat:@"%ld-%ld.mp4", (long)me.userId, (long)time(NULL)];
        [formData appendPartWithFileURL:url name:@"file" fileName:name mimeType:@"video/mp4" error:nil];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress((NSInteger)(uploadProgress.completedUnitCount * 100 / uploadProgress.totalUnitCount));
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(responseObject);
        NSString *status = responseObject[@"status"];
        if ([status isEqualToString:@"success"]) {
            Video *video = [Video videoWithDictionary:responseObject[@"data"]];
            if (success) {
                success(video);
            }
        } else {
            if (failed) {
                failed(responseObject[@"message"], nil);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(nil, error);
        }
    }];
}

- (void)likeVideo:(Me *)me video:(Video *)video success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"likevideo",
                                 @"user_id" : @(me.userId),
                                 @"post_id" : @(video.postId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}
- (void)dislikeVideo:(Me *)me video:(Video *)video success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"dislikevideo",
                                 @"user_id" : @(me.userId),
                                 @"post_id" : @(video.postId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)unlikeVideo:(Me *)me video:(Video *)video success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"unlikevideo",
                                 @"user_id" : @(me.userId),
                                 @"post_id" : @(video.postId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}
- (void)viewVideo:(Me *)me video:(Video *)video success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"viewvideo",
                                 @"user_id" : @(me.userId),
                                 @"post_id" : @(video.postId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}
- (void)commentVideo:(Me *)me video:(Video *)video comment:(NSString *)comment success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"comment",
                                 @"user_id" : @(me.userId),
                                 @"post_id" : @(video.postId),
                                 @"content" : comment,
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)challengeVideo:(Me *)me video:(Video *)video url:(NSURL *)url thumbnail:(NSString *)thumbnail progress:(void (^)(NSInteger))progress success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"challengevideo",
                                 @"user_id" : @(me.userId),
                                 @"post_id" : @(video.postId),
                                 @"thumbnail_url" : thumbnail,
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString *name = [NSString stringWithFormat:@"%ld-%ld.mov", (long)me.userId, (long)time(NULL)];
        [formData appendPartWithFileURL:url name:@"file" fileName:name mimeType:@"video/quicktime" error:nil];
    }
         progress:^(NSProgress * _Nonnull uploadProgress) {
             if (progress) {
                 progress((NSInteger)(uploadProgress.completedUnitCount * 100 / uploadProgress.totalUnitCount));
             }
         }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)commentChallenge:(Me *)me challenge:(ChallengeVideo *)challenge comment:(NSString *)comment success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"challenge_comment",
                                 @"user_id" : @(me.userId),
                                 @"challenge_id" : @(challenge.challengeId),
                                 @"content" : comment,
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}


- (void)getPopularVideos:(Me *)me success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_populars",
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *videos = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      Video *video = [Video videoWithDictionary:dict];
                      if (video) {
                          [videos addObject:video];
                      }
                  }
                  if (success) {
                      success(videos);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)getOpenChallenges:(Me *)me success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_challenges",
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *videos = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      Video *video = [Video videoWithDictionary:dict];
                      if (video) {
                          [videos addObject:video];
                      }
                  }
                  if (success) {
                      success(videos);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)getRecentVideos:(Me *)me offset:(int)offset success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_recents",
                                 @"authkey" : me.authKey,
                                 @"offset": @(offset)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *videos = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      Video *video = [Video videoWithDictionary:dict];
                      if (video) {
                          [videos addObject:video];
                      }
                  }
                  if (success) {
                      success(videos);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}


- (void)getVideo:(Me *)me postId:(NSInteger)postId success:(void (^)(Video *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_video",
                                 @"user_id" : @(me.userId),
                                 @"post_id" : @(postId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  Video *video = [Video videoWithDictionary:responseObject[@"data"]];
                  if (success) {
                      success(video);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)getChallengeVideos:(Me *)me video:(Video *)video success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_challenge",
                                 @"post_id" : @(video.postId),
                                 @"user_id" : @(me.userId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *challenges = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      ChallengeVideo *challenge = [ChallengeVideo challengeVideoWithDictionary:dict];
                      if (challenge) {
                          [challenges addObject:challenge];
                      }
                  }
                  if (success) {
                      success(challenges);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)getComments:(Me *)me video:(Video *)video success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_comment",
                                 @"post_id" : @(video.postId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *comments = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      Comment *comment = [Comment commentWithDictionary:dict];
                      if (comment) {
                          [comments addObject:comment];
                      }
                  }
                  if (success) {
                      success(comments);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)getChallengeComments:(Me *)me challenge:(ChallengeVideo *)challenge success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_challenge_comment",
                                 @"challenge_id" : @(challenge.challengeId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *comments = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      Comment *comment = [Comment commentWithDictionary:dict];
                      if (comment) {
                          [comments addObject:comment];
                      }
                  }
                  if (success) {
                      success(comments);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)getFollowers:(Me *)me user_id:(NSInteger)user_id follow_type:(NSString*)follow_type success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_followers",
                                 @"user_id" : @(user_id),
                                 @"follow_type" : follow_type,
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *users = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      User *user = [User userWithDictionary:dict];
                      if (user) {
                          [users addObject:user];
                      }
                  }
                  if (success) {
                      success(users);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}


- (void)likeChallengeVideo:(Me *)me postId:(NSInteger)postId success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"like_challenge",
                                 @"user_id" : @(me.userId),
                                 @"ch_id" : @(postId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}
- (void)dislikeChallengeVideo:(Me *)me postId:(NSInteger)postId success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"dislike_challenge",
                                 @"user_id" : @(me.userId),
                                 @"ch_id" : @(postId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)unlikeChallengeVideo:(Me *)me postId:(NSInteger)postId success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"unlike_challenge",
                                 @"user_id" : @(me.userId),
                                 @"ch_id" : @(postId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}


- (void)uploadAvatar:(Me *)me image:(UIImage *)image success:(void (^)(NSString *, NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"upload_avatar",
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString *name = [NSString stringWithFormat:@"%ld-%ld.jpg", (long)me.userId, (long)time(NULL)];
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5) name:@"file" fileName:name mimeType:@"image/jpeg"];
    }
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSString *status = responseObject[@"status"];
         if ([status isEqualToString:@"success"]) {
             if (success) {
                 success(responseObject[@"avatar_name"], responseObject[@"avatar_url"]);
             }
         } else {
             if (failed) {
                 failed(responseObject[@"message"], nil);
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if (failed) {
             failed(nil, error);
         }
     }];
}

- (void)updateProfile:(Me *)me bio:(NSString *)bio username:(NSString *)username avatarName:(NSString *)avatarName avatarUrl:(NSString *)avatarUrl success:(void (^)(Me *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters;
    if (avatarName && avatarUrl) {
        parameters = @{@"action" : @"update_profile",
                       @"bio" : bio,
                       @"user_name" : username,
                       @"avatar_name" : avatarName,
                       @"avatar_url" : avatarUrl,
                       @"authkey" : me.authKey};
    } else {
        parameters = @{@"action" : @"update_profile",
                       @"bio" : bio,
                       @"user_name" : username,
                       @"authkey" : me.authKey};
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  Me *me = [Me userWithDictionary:responseObject[@"data"]];
                  if (success) {
                      success(me);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)getUserInfo:(Me *)me userId:(NSInteger)userId success:(void (^)(User *, NSArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_userinfo",
                                 @"user_id" : @(userId),
                                 @"my_id" : @(me.userId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  User *user = [User userWithDictionary:responseObject[@"data"]];
                  NSMutableArray *videos = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"][@"videos"]) {
                      Video *video = [Video videoWithDictionary:dict];
                      if (video) {
                          [videos addObject:video];
                      }
                  }
                  if (success) {
                      success(user, videos);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}


- (void)follow:(Me *)me user:(User *)user follow:(BOOL)isFollow success:(void (^)(NSDictionary *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : isFollow ? @"follow" : @"unfollow",
                                 @"following_id" : @(user.userId),
                                 @"follower_id" : @(me.userId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"data"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)report:(Me *)me user:(User *)user content:(NSString *)content success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"report",
                                 @"user_id" : @(user.userId),
                                 @"by_userid" : @(me.userId),
                                 @"content" : content,
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)block:(Me *)me user:(User *)user block:(BOOL)isBlock success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"block",
                                 @"user_id" : @(user.userId),
                                 @"by_userid" : @(me.userId),
                                 @"state" : @(isBlock),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}


- (void)updatePassword:(Me *)me oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(void (^)())success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"change_password",
                                 @"old_password" : oldPassword,
                                 @"new_password" : newPassword,
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success();
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}


- (void)searchChallenges:(Me *)me key:(NSString *)key success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"search_video",
                                 @"keyword" : key,
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *videos = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      Video *video = [Video videoWithDictionary:dict];
                      if (video) {
                          [videos addObject:video];
                      }
                  }
                  if (success) {
                      success(videos);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)searchUsers:(Me *)me key:(NSString *)key success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"search_people",
                                 @"keyword" : key,
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *users = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      User *user = [User userWithDictionary:dict];
                      if (user) {
                          [users addObject:user];
                      }
                  }
                  if (success) {
                      success(users);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}


- (void)getNotifications:(Me *)me type:(NSString *)type success:(void (^)(NSMutableArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_notification",
                                 @"type" : type,
                                 @"user_id" : @(me.userId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *notifications = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      Notification *notification = [Notification notificationWithDictionary:dict];
                      if (notification) {
                          [notifications addObject:notification];
                      }
                  }
                  if (success) {
                      success(notifications);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)removeNotification:(Me *)me notificationId:(NSInteger)notificationId success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"ignore_notification",
                                 @"id": @(notificationId),
                                 @"authkey": me.authKey};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(status);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)viewNotification:(Me *)me notificationId:(NSInteger)notificationId success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"view_notification",
                                 @"id": @(notificationId),
                                 @"authkey": me.authKey};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(status);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)approveNotification:(Me *)me notificationId:(NSInteger)notificationId followId:(NSInteger)followId state:(NSInteger) state success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed{
    NSDictionary *parameters = @{@"action" : @"approve_friend_request",
                                 @"notification_id": @(notificationId),
                                 @"follow_id": @(followId),
                                 @"state": @(state),
                                 @"authkey": me.authKey};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)getMessage:(Me *)me userId: (NSInteger) user_id success:(void (^)(NSMutableArray *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"get_message",
                                 @"user1_id" : @(user_id),
                                 @"user2_id" : @(me.userId),
                                 @"authkey" : me.authKey};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  NSMutableArray *messages = [NSMutableArray array];
                  for (NSDictionary *dict in responseObject[@"data"]) {
                      Message *message = [Message messageWithDictionary:dict];
                      if (message) {
                          [messages addObject:message];
                      }
                  }
                  if (success) {
                      success(messages);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

- (void)sendMessage:(Me *)me receiverId: (NSInteger) receiver_id message: (NSString*) message success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"send_message",
                                 @"sender_id": @(me.userId),
                                 @"receiver_id": @(receiver_id),
                                 @"message": message,
                                 @"authkey": me.authKey};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}
- (void)deleteMessage:(Me *)me messageId: (NSInteger) message_id success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"delete_message",
                                 @"user_id": @(me.userId),
                                 @"message_id": @(message_id),
                                 @"authkey": me.authKey};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}
- (void)deletePostComment:(Me *)me commentId: (NSInteger) comment_id success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"delete_post_comment",
                                 @"user_id": @(me.userId),
                                 @"comment_id": @(comment_id),
                                 @"authkey": me.authKey};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}
- (void)deleteChallengeComment:(Me *)me commentId: (NSInteger) comment_id success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"delete_challenge_comment",
                                 @"user_id": @(me.userId),
                                 @"comment_id": @(comment_id),
                                 @"authkey": me.authKey};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}
- (void)deleteVideo:(Me *)me postId: (NSInteger) post_id success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed {
    NSDictionary *parameters = @{@"action" : @"delete_video",
                                 @"user_id": @(me.userId),
                                 @"post_id": @(post_id),
                                 @"authkey": me.authKey};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kAPIBaseURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSString *status = responseObject[@"status"];
              if ([status isEqualToString:@"success"]) {
                  if (success) {
                      success(responseObject[@"message"]);
                  }
              } else {
                  if (failed) {
                      failed(responseObject[@"message"], nil);
                  }
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failed) {
                  failed(nil, error);
              }
          }];
}

@end
