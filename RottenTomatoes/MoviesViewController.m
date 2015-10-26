//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Ramasamy Dayanand on 10/20/15.
//  Copyright © 2015 Ramasamy Dayanand. All rights reserved.
//

#import "MoviesViewController.h"
#import "MoviesTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailsViewController.h"
#import <KVNProgress/KVNProgress.h>

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *MoviesTableView;
@property (strong, nonatomic) NSArray *movies;
@property UIRefreshControl *refreshControl;
@property UILabel *errorView;
@property UITabBarController *tab;
@property UISearchBar *searchBar;
@property UISearchDisplayController *searchDisplayController;

@property (strong, nonatomic) NSArray *originalResponse;
@property NSMutableArray *searchData;
@end

@implementation MoviesViewController

-(instancetype)init{
//    self.searchData = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.MoviesTableView.dataSource = self;
    self.MoviesTableView.delegate = self;
    self.title = @"Movies";
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.MoviesTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self fetchMovies];
    self.errorView = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.MoviesTableView.frame.size.width, 20)];
    self.errorView.layer.zPosition = 10;
    self.errorView.text = @"Connection Error";
    self.errorView.backgroundColor = [UIColor redColor];
    self.errorView.hidden = YES;
    [self.MoviesTableView addSubview:self.errorView];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.MoviesTableView.tableHeaderView = self.searchBar;
//    self.tab = [[UITabBarController alloc] init];
    
//    [self.navigationController pushViewController:tabBarController animated:YES];
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{

    int i = 0;
    self.searchData = [[NSMutableArray alloc] init];
    for(i = 0;i < self.originalResponse.count; i++){
        NSDictionary *entry = self.originalResponse[i];
        NSString *title = entry[@"title"];
        NSString *synopsis = entry[@"synopsis"];
        if([title rangeOfString:searchString].location != NSNotFound ||
           [synopsis rangeOfString:searchString].location != NSNotFound){
            [self.searchData addObject:entry];
//            NSLog(self.searchData);
        }
    }
    NSLog(@"total count %lu", self.searchData.count);
    self.movies = self.searchData;
    [self.MoviesTableView reloadData];

    return YES;
}

- (void)refreshTable {
    [self.refreshControl endRefreshing];
    [self fetchMovies];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MoviesTableViewCell *cell = [self.MoviesTableView dequeueReusableCellWithIdentifier:@"movieCell"];
    cell.TitleLabel.text = self.movies[indexPath.row][@"title"];
    cell.SynopsisLabel.text = self.movies[indexPath.row][@"synopsis"];
    NSString *urlString = self.movies[indexPath.row][@"posters"][@"thumbnail"];
    NSLog(self.movies[indexPath.row][@"synopsis"]);

    urlString = [urlString stringByReplacingOccurrencesOfString: @"ori"
                                                         withString: @"tmb"];
    

    NSRange range = [urlString rangeOfString:@".*cloudfront.net/"
                                     options:NSRegularExpressionSearch];
    
    NSString *newUrlString = [urlString stringByReplacingCharactersInRange:range
                                                                withString:@"https://content6.flixster.com/"];
    NSURL *url = [NSURL URLWithString:newUrlString];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
    [cell.Thumbnail setImageWithURLRequest:urlReq placeholderImage:NULL success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        [UIView transitionWithView:cell.Thumbnail
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            cell.Thumbnail.image = image;
                        }
                        completion:NULL];
    }
     failure:NULL];
    return cell;
}

-(void) fetchMovies{
    [KVNProgress showWithStatus:@"Loading"];
    NSString *urlString =
    @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    NSLog(@"Response: %@", responseDictionary);
                                                    self.originalResponse = self.movies = responseDictionary[@"movies"];
                                                    [self.MoviesTableView reloadData];
                                                    [KVNProgress dismiss];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                    self.errorView.hidden = NO;
                                                    [KVNProgress dismiss];
                                                }
                                            }];
    [task resume];
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.MoviesTableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieDetailsViewController *vc = [[MovieDetailsViewController alloc] init];
    vc.movieDictionary = (NSDictionary *)self.movies[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void) searchBar:searchBarCancelButtonClicked:(UISearchBar *)searchBar{
//    [self fetchMovies];
//}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView NS_DEPRECATED_IOS(3_0,8_0){
    [self fetchMovies];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length] == 0) {
        [self fetchMovies];
    }
}
@end
