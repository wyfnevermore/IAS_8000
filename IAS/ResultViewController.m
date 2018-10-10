//
//  ResultViewController.m
//  IAS
//
//  Created by wyfnevermore on 2017/3/30.
//  Copyright © 2017年 wyfnevermore. All rights reserved.
//

#import "ResultViewController.h"
#import "DateValueFormatter.h"
#import "SetValueFormatter.h"
#import "Masonry.h"
#define screenWidth  [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
#define ARC4RANDOM_MAX      0x100000000
#define BgColor [UIColor colorWithRed:230/255.0f green:253/255.0f blue:253/255.0f alpha:1]

@import Charts;
@interface ResultViewController ()
{
    double Ymax;
    double Ymin;
}
@property (nonatomic,strong) LineChartView * lineView;
@property (nonatomic,strong) UILabel * markY;
@property (nonatomic, strong) PieChartView *pieChartView;

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _type.frame = CGRectMake(screenWidth*0.07246, screenHeight*0.1753, screenWidth*0.8575, screenHeight*0.0611);
    if ([_name containsString:@"能量"]){
        _type.textAlignment = NSTextAlignmentLeft;
    }else{
        _type.textAlignment = NSTextAlignmentCenter;
    }
    [_type setText:_name];
    NSLog(@"结果页数据：%@",_name);
    _type.numberOfLines =0;
    [_type sizeToFit];
    self.title = @"检测结果";
    // Do any additional setup after loading the view.
    Ymax = [[_dataXGDArray valueForKeyPath:@"@max.floatValue"]doubleValue];
    Ymin = [[_dataXGDArray valueForKeyPath:@"@min.floatValue"]doubleValue];
    NSLog(@"最大最小值：%f,%f",Ymax,Ymin);
    //吸光度图谱
//    [self.view addSubview:self.lineView];
//    self.lineView.data = [self setData];
    
    _lineView.hidden = YES;
    
    if ([_pic containsString:@"豆浆"]) {
        _resImg.hidden = true;
        _type.hidden = true;
    
        
        //updateData btn
        UIButton *display_btn = [[UIButton alloc] init];
        [display_btn setTitle:@"updateData" forState:UIControlStateNormal];
        [display_btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        display_btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:display_btn];
        [display_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 50));
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view.mas_centerY).offset(240);
        }];
        [display_btn addTarget:self action:@selector(updateData) forControlEvents:UIControlEventTouchUpInside];
        
        //创建饼状图
        self.pieChartView = [[PieChartView alloc] init];
        self.pieChartView.backgroundColor = BgColor;
        [self.view addSubview:self.pieChartView];
        [self.pieChartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(screenWidth, screenHeight));
            make.center.mas_equalTo(self.view);
        }];
        //基本样式
        [self.pieChartView setExtraOffsetsWithLeft:30 top:50 right:30 bottom:0];//饼状图距离边缘的间隙
        self.pieChartView.usePercentValuesEnabled = YES;//是否根据所提供的数据, 将显示数据转换为百分比格式
        self.pieChartView.dragDecelerationEnabled = YES;//拖拽饼状图后是否有惯性效果
        self.pieChartView.drawSliceTextEnabled = YES;//是否显示区块文本
        //空心饼状图样式
//        self.pieChartView.drawHoleEnabled = YES;//饼状图是否是空心
//        self.pieChartView.holeRadiusPercent = 0.5;//空心半径占比
//        self.pieChartView.holeColor = [UIColor clearColor];//空心颜色
//        self.pieChartView.transparentCircleRadiusPercent = 0.52;//半透明空心半径占比
//        self.pieChartView.transparentCircleColor = [UIColor colorWithRed:210/255.0 green:145/255.0 blue:165/255.0 alpha:0.3];//半透明空心的颜色
        //实心饼状图样式
            self.pieChartView.drawHoleEnabled = NO;
        //饼状图中间描述
        if (self.pieChartView.isDrawHoleEnabled == YES) {
            self.pieChartView.drawCenterTextEnabled = YES;//是否显示中间文字
            //普通文本
            //        self.pieChartView.centerText = @"饼状图";//中间文字
            //富文本
            NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:@"饼状图"];
            [centerText setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                        NSForegroundColorAttributeName: [UIColor orangeColor]}
                                range:NSMakeRange(0, centerText.length)];
            self.pieChartView.centerAttributedText = centerText;
        }
        
        //饼状图描述
        self.pieChartView.descriptionText = @"";
//        self.pieChartView.descriptionFont = [UIFont systemFontOfSize:10];
//        self.pieChartView.descriptionTextColor = [UIColor grayColor];
        //饼状图图例
//        self.pieChartView.legend.maxSizePercent = 1;//图例在饼状图中的大小占比, 这会影响图例的宽高
//        self.pieChartView.legend.formToTextSpace = 5;//文本间隔
//        self.pieChartView.legend.font = [UIFont systemFontOfSize:10];//字体大小
//        self.pieChartView.legend.textColor = [UIColor grayColor];//字体颜色
//        self.pieChartView.legend.position = 1;//图例在饼状图中的位置
//        self.pieChartView.legend.form = ChartLegendFormCircle;//图示样式: 方形、线条、圆形
//        self.pieChartView.legend.formSize = 20;//图示大小
        self.pieChartView.legend.enabled = false;
        
        //为饼状图提供数据
        [self setDataCount:5 range:100];
        //设置动画效果
        [self.pieChartView animateWithXAxisDuration:1.0f easingOption:ChartEasingOptionEaseOutExpo];
        
        //title
        UILabel *title_label = [[UILabel alloc] init];
        title_label.text = _pic;
        title_label.font = [UIFont systemFontOfSize:45];
        title_label.textColor = [UIColor brownColor];
        title_label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:title_label];
        [title_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(260, 50));
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view.mas_centerY).offset(-200);
        }];
    }else{
        _resImg.frame = CGRectMake(screenWidth*0.12, screenHeight*0.333, screenWidth*0.776, screenHeight*0.436);
        [Tools setModelType:_pic :_resImg :0];
        _resImg.hidden = false;
        _type.hidden = false;
    }
}

- (void)updateData{
    //为饼状图提供数据
    [self setDataCount:5 range:100];
    //设置动画效果
    [self.pieChartView animateWithXAxisDuration:1.0f easingOption:ChartEasingOptionEaseOutExpo];
}

- (void)setDataCount:(int)count range:(double)range
{
    double mult = range;
    NSMutableArray *entries = [[NSMutableArray alloc] init];
//    for (int i = 0; i < count; i++) {
//        [entries addObject:[[PieChartDataEntry alloc] initWithValue:(arc4random_uniform(mult) + mult / 5) label:[NSString stringWithFormat:@"第%d个", i]]];
//    }
    [entries addObject:[[PieChartDataEntry alloc] initWithValue:(arc4random_uniform(mult) + mult / 5) label:@"蛋白质"]];
    [entries addObject:[[PieChartDataEntry alloc] initWithValue:(arc4random_uniform(mult) + mult / 5) label:@"脂肪"]];
    [entries addObject:[[PieChartDataEntry alloc] initWithValue:(arc4random_uniform(mult) + mult / 5) label:@"水分"]];
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:entries label:@""];
    dataSet.sliceSpace = 2.0;
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObjectsFromArray:ChartColorTemplates.vordiplom];
    [colors addObjectsFromArray:ChartColorTemplates.joyful];
    [colors addObjectsFromArray:ChartColorTemplates.colorful];
    [colors addObjectsFromArray:ChartColorTemplates.liberty];
    [colors addObjectsFromArray:ChartColorTemplates.pastel];
    [colors addObject:[UIColor colorWithDisplayP3Red:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
    dataSet.colors = colors;
    dataSet.valueLinePart1OffsetPercentage = 0.8;
    dataSet.valueLinePart1Length = 0.3;
    dataSet.valueLinePart2Length = 0.6;
    dataSet.yValuePosition = PieChartValuePositionOutsideSlice;
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    
    pFormatter.percentSymbol = @" %";
    [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.f]];
    [data setValueTextColor:UIColor.blackColor];
    _pieChartView.data = data;
    [_pieChartView highlightValue:nil];
}


////折线图
//- (LineChartView *)lineView {
//    if (!_lineView) {
//        _lineView = [[LineChartView alloc] initWithFrame:CGRectMake(0, screenHeight*0.43, screenWidth*0.98, screenHeight*0.55)];
//        _lineView.delegate = self;//设置代理
//        _lineView.backgroundColor =  [UIColor whiteColor];
//        _lineView.noDataText = @"暂无数据";
//        _lineView.chartDescription.enabled = YES;
//        _lineView.scaleYEnabled = YES;//取消Y轴缩放
//        _lineView.autoScaleMinMaxEnabled = YES;//!!!
//        _lineView.doubleTapToZoomEnabled = YES;//双击缩放
//        _lineView.dragEnabled = YES;//启用拖拽图标
//        _lineView.dragDecelerationEnabled = YES;//拖拽后是否有惯性效果
//        _lineView.dragDecelerationFrictionCoef = 0.9;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
//        //设置滑动时候标签
//        ChartMarkerView *markerY = [[ChartMarkerView alloc]init];
//        markerY.offset = CGPointMake(-999, -8);
//        markerY.chartView = _lineView;
//        _lineView.marker = markerY;
//        [markerY addSubview:self.markY];
//        
//        //获取左边Y轴
//        _lineView.rightAxis.enabled = NO;//不绘制右边轴
//        ChartYAxis *leftAxis = _lineView.leftAxis;
//        leftAxis.labelCount = 5;//Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
//        leftAxis.forceLabelsEnabled = NO;//不强制绘制指定数量的label
//        leftAxis.axisMinValue = Ymin;//设置Y轴的最小值
//        leftAxis.axisMaxValue = Ymax;//设置Y轴的最大值
//        leftAxis.inverted = NO;//是否将Y轴进行上下翻转
//        leftAxis.axisLineColor = [UIColor blackColor];//Y轴颜色
//        
//        leftAxis.labelPosition = YAxisLabelPositionOutsideChart;//label位置
//        leftAxis.labelTextColor = [UIColor blackColor];//文字颜色
//        leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];//文字字体
//        leftAxis.gridColor = [UIColor grayColor];//网格线颜色
//        leftAxis.gridAntialiasEnabled = NO;//开启抗锯齿
//        ChartXAxis *xAxis = _lineView.xAxis;
//        xAxis.granularityEnabled = YES;//设置重复的值不显示
//        xAxis.labelPosition= XAxisLabelPositionBottom;//设置x轴数据在底部
//        xAxis.gridColor = [UIColor grayColor];
//        xAxis.labelTextColor = [UIColor blackColor];//文字颜色
//        xAxis.axisLineColor = [UIColor grayColor];
//        _lineView.maxVisibleCount = 999;
//        //描述及图例样式
//        [_lineView setDescriptionText:@"吸光度"];
//        _lineView.legend.enabled = NO;
//        
//        [_lineView animateWithXAxisDuration:1.0f];
//    }
//    return _lineView;
//}
//
//- (LineChartData *)setData{
//    NSInteger xVals_count = _dataBCArray.count;//X轴上要显示多少条数据
//    //X轴上面需要显示的数据
//    NSMutableArray *xVals = [[NSMutableArray alloc] init];
//    for (int i = 0; i < xVals_count; i++) {
//        NSString *Xdata = [NSString stringWithFormat:@"%@", _dataBCArray[i]];
//        [xVals addObject: Xdata];
//    }
//    _lineView.xAxis.valueFormatter = [[DateValueFormatter alloc]initWithArr:xVals];
//    
//    //对应Y轴上面需要显示的数据
//    NSMutableArray *yVals = [[NSMutableArray alloc] init];
//    for (int i = 0; i < xVals_count; i++) {
//        double a;
//        a = [_dataXGDArray[i] doubleValue];
//        ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:i y:a];
//        [yVals addObject:entry];
//    }
//    
//    LineChartDataSet *set1 = nil;
//    if (_lineView.data.dataSetCount > 0) {
//        LineChartData *data = (LineChartData *)_lineView.data;
//        set1 = (LineChartDataSet *)data.dataSets[0];
//        set1.values = yVals;
//        set1.valueFormatter = [[SetValueFormatter alloc]initWithArr:yVals];
//        return data;
//    }else{
//        //创建LineChartDataSet对象
//        set1 = [[LineChartDataSet alloc]initWithValues:yVals label:nil];
//        //设置折线的样式
//        set1.lineWidth = 2.0/[UIScreen mainScreen].scale;//折线宽度
//        set1.drawValuesEnabled = YES;//是否在拐点处显示数据
//        set1.valueFormatter = [[SetValueFormatter alloc]initWithArr:yVals];
//        
//        set1.valueColors = @[[UIColor brownColor]];//折线拐点处显示数据的颜色
//        
//        [set1 setColor:[UIColor blueColor]];//折线颜色
//        set1.highlightColor = [UIColor redColor];
//        set1.drawSteppedEnabled = NO;//是否开启绘制阶梯样式的折线图
//        //折线拐点样式
//        set1.drawCirclesEnabled = NO;//是否绘制拐点
//        set1.drawFilledEnabled = NO;//是否填充颜色
//        
//        //将 LineChartDataSet 对象放入数组中
//        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
//        [dataSets addObject:set1];
//        
//        //添加第二个LineChartDataSet对象
//        
//        NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
//        for (int i = 0; i <  xVals_count; i++) {
//            double a = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 1000000);
//            a = a/1000000;
//            ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:i y:a];
//            [yVals2 addObject:entry];
//        }
//        LineChartDataSet *set2 = [set1 copy];
//        set2.values = yVals2;
//        set2.drawValuesEnabled = NO;
//        [set2 setColor:[UIColor greenColor]];
//        
//        //[dataSets addObject:set2];
//        //创建 LineChartData 对象, 此对象就是lineChartView需要最终数据对象
//        LineChartData *data = [[LineChartData alloc]initWithDataSets:dataSets];
//        
//        [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];//文字字体
//        [data setValueTextColor:[UIColor blackColor]];//文字颜色
//        
//        return data;
//    }
//}
//
////当前点击的点显示数值
//- (UILabel *)markY{
//    if (!_markY) {
//        _markY = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
//        _markY.font = [UIFont systemFontOfSize:15.0];
//        _markY.textAlignment = NSTextAlignmentCenter;
//        _markY.text =@"";
//        _markY.textColor = [UIColor whiteColor];
//        _markY.backgroundColor = [UIColor grayColor];
//    }
//    return _markY;
//}
//
//- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight {
//    _markY.text = [NSString stringWithFormat:@"%.8f",(double)entry.y];
//    //将点击的数据滑动到中间
//    [_lineView centerViewToAnimatedWithXValue:entry.x yValue:entry.y axis:[_lineView.data getDataSetByIndex:highlight.dataSetIndex].axisDependency duration:1.0];
//}
//
//- (void)chartValueNothingSelected:(ChartViewBase * _Nonnull)chartView {
//    
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"XGD"]) {
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end
