//
//  MovieDetailsViewController.m
//  RottenTomatoes
//
//  Created by Ramasamy Dayanand on 10/20/15.
//  Copyright © 2015 Ramasamy Dayanand. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "MoviesTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
//@property (weak, nonatomic) IBOutlet UILabel *Synopsis;
//@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@end

@implementation MovieDetailsViewController
@synthesize movieDictionary;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.movieDictionary[@"title"];
    [self.scrollView setContentSize:CGSizeMake(100, 1000)];
    self.scrollView.delegate = self;
    
    UIImageView *detailViewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 300)];
    NSString *urlString = self.movieDictionary[@"posters"][@"detailed"];
    NSRange range = [urlString rangeOfString:@".*cloudfront.net/"
                                     options:NSRegularExpressionSearch];
    
    NSString *newUrlString = [urlString stringByReplacingCharactersInRange:range
                                                                withString:@"https://content6.flixster.com/"];
    
    
    NSURL *url = [NSURL URLWithString:newUrlString];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];

    NSString *lowResImage = [newUrlString stringByReplacingOccurrencesOfString: @"ori"
                                                                 withString: @"tmb"];
    NSLog(lowResImage);
    NSURL *lowResUrl = [NSURL URLWithString:lowResImage];
    [detailViewImage setImageWithURL:lowResUrl];


    [detailViewImage setImageWithURLRequest:urlReq placeholderImage:NULL success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        [UIView transitionWithView:detailViewImage
                          duration:1
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            detailViewImage.image = image;
                        }
                        completion:NULL];
    }
                                   failure:NULL];

//    [detailViewImage setImageWithURL:url];
    [self.scrollView addSubview:detailViewImage];
    
    
    UILabel *movieTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 300, self.scrollView.frame.size.width, 50)];
    [movieTitle setTextColor:[UIColor whiteColor]];
    [self.scrollView addSubview:movieTitle];

    UILabel *synopsis = [[UILabel alloc] initWithFrame:CGRectMake(0, 350, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    [synopsis setTextColor:[UIColor whiteColor]];
    [self.scrollView addSubview:synopsis];
    

    

    movieTitle.text = self.movieDictionary[@"title"];
    movieTitle.numberOfLines=0;
    [movieTitle sizeToFit];
    
    synopsis.text = self.movieDictionary[@"synopsis"];
    synopsis.numberOfLines = 0;
    [synopsis sizeToFit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Entered");
    MoviesTableViewCell *moviesTableCell = (MoviesTableViewCell *)sender;
    NSLog(moviesTableCell.SynopsisLabel.text);
}


@end
