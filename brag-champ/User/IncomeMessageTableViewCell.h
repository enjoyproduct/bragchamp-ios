//
//  IncomeMessageTableViewCell.h
//  brag-champ
//
//  Created by Admin on 5/19/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncomeMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UITextView *tvMessage;

@end
