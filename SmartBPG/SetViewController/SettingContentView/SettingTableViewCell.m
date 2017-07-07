//
//  SettingTableViewCell.m
//  
//
//  Created by Faith on 2017/5/3.
//
//

#import "SettingTableViewCell.h"


@interface SettingTableViewCell ()

@property (strong, nonatomic)  UIImageView *headImageView;
@property (strong, nonatomic)  UILabel *funNameLabel;

@end

@implementation SettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headImageView = [[UIImageView alloc] init];
        [self addSubview:_headImageView];
        [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(18);
        }];
        
        _funNameLabel = [[UILabel alloc] init];
        _funNameLabel.textColor = TEXT_WHITE_COLOR_LEVEL4;
        [self addSubview:_funNameLabel];
        [_funNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(72);
        }];
        self.backgroundColor = CLEAR_COLOR;
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setter model
- (void)setModel:(SettingCellModel *)model
{
    _model = model;
    [_headImageView setImage:[UIImage imageNamed:model.headImageName]];
    [_funNameLabel setText:model.fucName];
}

@end
