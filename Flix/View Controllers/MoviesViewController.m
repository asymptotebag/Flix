//
//  MoviesViewController.m
//  Flix
//
//  Created by Emily Jiang on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

//NSString *CellIdentifier = @"MovieCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self fetchMovies]; // fetch movies once screen loads
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)fetchMovies {
    // API key: 856048063001a4a1f07f6980906a4a90
    // Networking code:
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=856048063001a4a1f07f6980906a4a90"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // when network call is finished
           if (error != nil) { // error happened
               NSLog(@"%@", [error localizedDescription]);
           }
           else { // API gave us smth back
               // Get the array of movies
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
//               NSLog(@"%@", dataDictionary);
               
               self.movies = dataDictionary[@"results"]; // Store the movies in a property to use elsewhere
               for (NSDictionary *movie in self.movies) {
                   NSLog(@"%@", movie[@"title"]);
               }
               
               [self.tableView reloadData]; // Reload your table view data
           }
            [self.refreshControl endRefreshing]; // need to tell the refresh animation to stop/exit refresh state
       }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // UITableViewCell *cell = [[UITableViewCell alloc] init];
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // sender is a generic ios word meaning the object that fired the event, here id is the tableview cell that was tapped
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}

@end
