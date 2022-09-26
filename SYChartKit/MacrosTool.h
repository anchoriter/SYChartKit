

#ifndef MacrosTool_h
#define MacrosTool_h

#define KWidth ([UIScreen mainScreen].bounds.size.width)
#define KHeight ([UIScreen mainScreen].bounds.size.height)

#define KStatusBar_H  [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBar_H  (44.0f)
#define KNAV_H  (KStatusBar_H + kNavBar_H)

#define kScreenScale ((MIN(KWidth, KHeight)/375))

// RGB+透明度
#define RGBA(r,g,b,al) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(al)]
#define RGB(A,B,C) [UIColor colorWithRed:((float)A)/255.0 green:((float)B)/255.0 blue:((float)C)/255.0 alpha:1.0]


// 普通字体
#define UIFontMake(size) [UIFont systemFontOfSize:size]
#define UIFontBoldMake(size) [UIFont boldSystemFontOfSize:size]
#define UIMediumFontMake(size) [UIFont systemFontOfSize:size weight:UIFontWeightMedium]
#define UIFontPingFangRegularMake(font) [UIFont fontWithName:@"PingFang-SC-Regular"size:font]
// 数字字体（需要导入plumbmec.ttf文件，并在info.plist中配置字体，否则报错）
#define UIFontNumberMake(font) [UIFont fontWithName:@"PlumbMediumC"size:font]

// 动态字体大小
#define kFontScale(font) UIFontMake(kFontSizeScale(font))
#define kFontBoldScale(font) UIFontBoldMake(kFontSizeScale(font))
#define kFontMediumScale(font) UIMediumFontMake(kFontSizeScale(font))
#define kFontPingFangSCScale(font) UIFontPingFangRegularMake(kFontSizeScale(font))
#define kFontNumberScale(font) UIFontNumberMake(kFontSizeScale(font))
// 动态字体大小
static inline CGFloat kFontSizeScale(CGFloat fontSize){
    if (KWidth==320) {
        return fontSize-1;
    }else if (KWidth==375){
        return fontSize;
    }else{
        return fontSize+1.5;
    }
}

/// 判断数组是否为空
#define KArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)

//字符串高度
#define KStringHeight(string,widthLimit,font) ([string boundingRectWithSize:CGSizeMake(widthLimit, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.height)

//字符串宽度
#define KStringWidth(string,heightLimit,font) ([string boundingRectWithSize:CGSizeMake(MAXFLOAT, heightLimit) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width)

#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

//数据输出
#ifdef DEBUG
#   define DLog(fmt, ...) {NSLog((@"%s [Line %d] \n " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#   define ELog(err) {if(err) //DLog(@"%@", err)}
#else
#   define DLog(...)
#   define ELog(err)
#endif

#endif /* MacrosTool_h */
