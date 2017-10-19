//
//  APIManager.h
//  brag-champ
//
//  Created by Apple on 12/23/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Me;
@class User;
@class Video;
@class ChallengeVideo;

@interface APIManager : NSObject

+ (instancetype)sharedManager;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(Me *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)signupWithFirstname:(NSString *)firstname lastname:(NSString *)lastname email:(NSString *)email birthday:(NSString *)birthday username:(NSString *)username password:(NSString *)password success:(void (^)(Me *))success failed:(void (^)(NSString *, NSError *))failed;

- (void)uploadThumbnail:(Me *)me image:(UIImage *)image success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)postVideo:(Me *)me challengeTitle:(NSString *)title challengers:(NSInteger)count public:(BOOL)isPublic hashTags:(NSString *)tags videoURL:(NSURL *)url thumbnail:(NSString *)thumbnail progress:(void (^)(NSInteger))progress success:(void (^)(Video *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)likeVideo:(Me *)me video:(Video *)video success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)dislikeVideo:(Me *)me video:(Video *)video success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)unlikeVideo:(Me *)me video:(Video *)video success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)viewVideo:(Me *)me video:(Video *)video success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)commentVideo:(Me *)me video:(Video *)video comment:(NSString *)comment success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)challengeVideo:(Me *)me video:(Video *)video url:(NSURL *)url thumbnail:(NSString *)thumbnail progress:(void (^)(NSInteger))progress success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)commentChallenge:(Me *)me challenge:(ChallengeVideo *)challenge comment:(NSString *)comment success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;

- (void)getPopularVideos:(Me *)me success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)getOpenChallenges:(Me *)me success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)getRecentVideos:(Me *)me offset:(int)offset success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed;

- (void)getVideo:(Me *)me postId:(NSInteger)postId success:(void (^)(Video *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)getChallengeVideos:(Me *)me video:(Video *)video success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)getComments:(Me *)me video:(Video *)video success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)getChallengeComments:(Me *)me challenge:(ChallengeVideo *)challenge success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed;

- (void)getFollowers:(Me *)me user_id:(NSInteger)user_id follow_type:(NSString*)follow_type success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed;

- (void)likeChallengeVideo:(Me *)me postId:(NSInteger)postId success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)dislikeChallengeVideo:(Me *)me postId:(NSInteger)postId success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)unlikeChallengeVideo:(Me *)me postId:(NSInteger)postId success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;

- (void)uploadAvatar:(Me *)me image:(UIImage *)image success:(void (^)(NSString *, NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)updateProfile:(Me *)me bio:(NSString *)bio username:(NSString *)username avatarName:(NSString *)avatarName avatarUrl:(NSString *)avatarUrl success:(void (^)(Me *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)getUserInfo:(Me *)me userId:(NSInteger)userId success:(void (^)(User *, NSArray *))success failed:(void (^)(NSString *, NSError *))failed;

- (void)follow:(Me *)me user:(User *)user follow:(BOOL)isFollow success:(void (^)(NSDictionary *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)report:(Me *)me user:(User *)user content:(NSString *)content success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)block:(Me *)me user:(User *)user block:(BOOL)isBlock success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;

- (void)updatePassword:(Me *)me oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(void (^)())success failed:(void (^)(NSString *, NSError *))failed;

- (void)searchChallenges:(Me *)me key:(NSString *)key success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)searchUsers:(Me *)me key:(NSString *)key success:(void (^)(NSArray *))success failed:(void (^)(NSString *, NSError *))failed;

- (void)getNotifications:(Me *)me type:(NSString *)type success:(void (^)(NSMutableArray *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)removeNotification:(Me *)me notificationId:(NSInteger)notificationId success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)viewNotification:(Me *)me notificationId:(NSInteger)notificationId success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)approveNotification:(Me *)me notificationId:(NSInteger)notificationId followId:(NSInteger)followId state:(NSInteger) state success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)getMessage:(Me *)me userId:(NSInteger)user_id success:(void (^)(NSMutableArray *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)sendMessage:(Me *)me receiverId:(NSInteger)receiver_id message:(NSString*)message success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)deleteMessage:(Me *)me messageId:(NSInteger)message_id success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)deletePostComment:(Me *)me commentId:(NSInteger)comment_id success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)deleteChallengeComment:(Me *)me commentId:(NSInteger)comment_id success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
- (void)deleteVideo:(Me *)me postId:(NSInteger)post_id success:(void (^)(NSString *))success failed:(void (^)(NSString *, NSError *))failed;
@end
