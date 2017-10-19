//
//  OutGoMessageTableViewCell.h
//  brag-champ
//
//  Created by Admin on 5/19/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OutGoMessageTableViewCellDelegate <NSObject>

- (void)deleteMessage:(int)index;

@end

@interface OutGoMessageTableViewCell : UITableViewCell {
     @public int index;
}
@property (weak, nonatomic) IBOutlet UITextView *tvMessage;
@property (nonatomic, weak) id <OutGoMessageTableViewCellDelegate> delegate;

@end
