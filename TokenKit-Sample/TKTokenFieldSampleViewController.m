#import "TKTokenFieldSampleViewController.h"
#import "TKToken.h"
#import "TKDynamicTokenField.h"

@interface TKTokenFieldSampleViewController () <TKTokenFieldDelegate>
@end

@implementation TKTokenFieldSampleViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	TKDynamicTokenField *tokenField = (TKDynamicTokenField *)self.tokenField;
	((UICollectionViewFlowLayout *)tokenField.collectionView.collectionViewLayout).minimumLineSpacing = 8;
	((UICollectionViewFlowLayout *)tokenField.collectionView.collectionViewLayout).minimumInteritemSpacing = 8;
	tokenField.collectionView.contentInset = (UIEdgeInsets){ 8, 8, 8, 8 };
	[tokenField.collectionView registerNib:[UINib nibWithNibName:@"TKTokenCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:TKTokenFieldCellReuseIdentifier];
	[tokenField.collectionView registerNib:[UINib nibWithNibName:@"TKAdditionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:TKDynamicTokenFieldAdditionCellReuseIdentifier];
	tokenField.usableTokens = ((^{
		NSString *path = [[NSBundle mainBundle] pathForResource:@"TKProgrammingLanguages" ofType:@"json"];
		NSData *data = [NSData dataWithContentsOfMappedFile:path];
		NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		NSMutableArray *toTokens = [NSMutableArray array];
		for (NSString *object in array) {
			[toTokens addObject:[[TKToken alloc] initWithTitle:object value:object]];
		}
		return toTokens;
	})());
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self resizeTokenFieldAnimated:NO];
	[self.tokenField addObserver:self forKeyPath:@"collectionView.contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.tokenField removeObserver:self forKeyPath:@"collectionView.contentSize" context:nil];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.tokenField) {
		if ([keyPath isEqualToString:@"collectionView.contentSize"]) {
			[self resizeTokenFieldAnimated:YES];
		}
	}
}

- (void) resizeTokenFieldAnimated:(BOOL)animated {
	[UIView animateWithDuration:(animated ? 0.3f : 0.0f) delay:0.0f options:UIViewAnimationOptionAllowUserInteraction| UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
		CGSize size = self.tokenField.collectionView.contentSize;
		UIEdgeInsets insets = self.tokenField.collectionView.contentInset;
		self.tokenField.frame = (CGRect){
			CGPointZero,
			(CGSize){
				320.0f,
//				self.tokenField.bounds.size.width,
//				size.width + insets.left + insets.right,
				MIN(size.height, 0.8f * CGRectGetHeight(self.view.bounds)) + insets.top + insets.bottom
			}
		};
	} completion:nil];
}

@end
