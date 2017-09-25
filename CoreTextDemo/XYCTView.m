//
//  XYCTView.m
//  CoreTextDemo
//
//  Created by ChenQing on 17/8/18.
//  Copyright © 2017年 ChenQing. All rights reserved.
//

#import "XYCTView.h"
#import <CoreText/CoreText.h>

@implementation XYCTView

-(void)drawRect:(CGRect)rect{
    //获取上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    //翻转坐标系(coreText坐标系是以左下角为坐标原点，UIKit是以左上角为坐标原点)
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    //创建一条限定绘图区域的路径
    CGMutablePathRef path=CGPathCreateMutable();
    //CGPathAddRect(path, NULL, self.bounds);
    CGPathAddEllipseInRect(path, NULL, self.bounds);
    NSMutableAttributedString *string=[[NSMutableAttributedString alloc]initWithString:@"hello world hello world hello world hello world hello world hello world hello world hello world hello world hello world"];
    CTFontRef font=CTFontCreateWithName(CFSTR("Georgia"), 40, NULL);
    [string addAttribute:(id)kCTFontAttributeName value:(__bridge id _Nonnull)(font) range:NSMakeRange(0, 10)];
    
    //CTRunDelegateCallbacks:一个用户保存指针的结构体，由CTRun delegate进行回调
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    //图片信息字典
    NSDictionary *imgInfoDict=@{@"width":@208,@"height":@280};
    //设置CTRun的代理
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)(imgInfoDict));
    
    //使用0xfffc作为空白的占位符
    UniChar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *space=[[NSMutableAttributedString alloc]initWithString:content];
    
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    //将创建的空白AttributedString插入进当前的attrString中，位置可以随便指定，不能越界
    [string insertAttributedString:space atIndex:50];
    
    
    //开始绘制
    CTFramesetterRef ctFrameSetting=CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    CTFrameRef ctFrameRef=CTFramesetterCreateFrame(ctFrameSetting, CFRangeMake(0, [string length]), path, NULL);
    CTFrameDraw(ctFrameRef, context);
    
    UIImage *image = [UIImage imageNamed:@"logo"];
    CGContextDrawImage(context, [self calculateImagePositionInCTFrame:ctFrameRef], image.CGImage);
}

/**
 <#Description#>

 @param ctFrame <#ctFrame description#>
 @return <#return value description#>
 */
-(CGRect)calculateImagePositionInCTFrame:(CTFrameRef)ctFrame{
    //获取CTLine数组
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
    NSInteger lineCount = [lines count];
    //利用CGPoint数组获取所有的CTLine的起始坐标
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    //遍历每个CTLine
    for(NSInteger i=0;i<lineCount;i++){
        //得到一行的信息
        CTLineRef line = (__bridge CTLineRef)(lines[i]);
        //得到该行CTRun的信息
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        //遍历每个CTLine中的CTRun
        for(id runObj in runObjArray){
            //判断该CTRun是否设置有代理，若无代理直接进行下次循环
            CTRunRef run = (__bridge CTRunRef)(runObj);
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)([runAttributes valueForKey:(id)kCTRunDelegateAttributeName]);
            if (delegate==nil) {
                continue;
            }
             //若CTRun有代理，则获取代理信息，代理信息若不为字典直接进行下次循环
            NSDictionary *metaDic=CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            //获取CTRunDelegate中的宽度并给上升和下降高度赋值
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            //height = 上升高度+下降高度
            runBounds.size.height = ascent + descent;
            //获取此CTRun在x上的偏移量
            CGFloat xOffSet = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            //设置起始点坐标
            runBounds.origin.x=lineOrigins[i].x+xOffSet;
            runBounds.origin.y=lineOrigins[i].y-descent;
            //获取CTFrame的路径
            CGPathRef pathRef = CTFrameGetPath(ctFrame);
            //根据runBounds配置图片在绘制视图中的实际位置
            CGRect colRect=CGPathGetBoundingBox(pathRef);
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            return delegateBounds;
        }
    }
    return CGRectZero;
}

static CGFloat ascentCallback(void *ref){
    return [(NSNumber *)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void *ref){
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
}
@end
