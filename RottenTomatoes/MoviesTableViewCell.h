//
//  MoviesTableViewCell.h
//  RottenTomatoes
//
//  Created by Ramasamy Dayanand on 10/20/15.
//  Copyright © 2015 Ramasamy Dayanand. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *SynopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *Thumbnail;

@end
