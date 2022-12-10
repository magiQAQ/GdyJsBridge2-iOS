# GdyJsBridge2 for iOS

## 特性

1. api简单易用

2. 支持原生与js之间互相调用其方法

## 集成

目前本sdk仅支持手动集成(xcframework), xcframework文件可在demo中获得
将 GdyJSBridge.xcframework 拖入自己的项目中， 在项目设置（General -> Frameworks， Libraries，and Embedded Content）将GdyJSBridge.xcframework Embed 修改成 Embed & Sign 即可

## 使用

###初始化

iOS端初始化

In OC
```objective-c
#import <GdyJsBridge2/GdyJsBridge2.h>
...
        _webView = [[GDYWKWebView alloc]initWithFrame:self.view.bounds];
        [self.view addSubview:_webView];
```

In Swift
```swift
import GdyJsBridge2
...
        self.wkwebView = GDYWKWebView(frame: self.view.bounds)
        self.view.addSubview(self.wkwebView)
```
GDYWKWebView继承于原生的WKWebView，因此WebView的方法都可以正常使用。

⚠️注意：前端通过识别userAgent是否包含“GdyBridgeWebView”来执行，如果用户修改了userAgent的话，记得给修改后的userAgent加上“GdyBridgeWebView”  （重要！！）

前端初始化

In Html
```html
<script src="./gdyBridge.js"></script>
```
该js脚本会根据当前用户的userAgent自动去初始化，前端不用过多处理，只需保证window下没有挂载"\_gdyBridge"同名对象即可。

### JavaScript 提供一个方法，iOS 原生去调用
注意：调用方法的时机只要在self.wkwebView.load之后即可，不需要自己去主动监听网页加载是否完成， 封装的wkwebVew内部已经处理过了。

传递字符串:

In JavaScript
```javascript
window._gdyBridge.register('getStringFromJs', function(a, b, c) {
   return a + b + c + " from JavaScript";
})
```
注意: 返回值可以为基本类型或null，也可以是json Element(对象、数组等)

In OC
```objective-c
NSArray * js = @[@1,@"a",@false];
[self.webView callJsFunctionWithMethod:@"getStringFromJs" args:js returnValueHandler:^(BOOL success, id _Nullable value) {
    if (success) {
        NSLog(@"getStringFromJs: %@",(NSString*)value);
    } else {
        NSLog(@"调用失败，原因：%@",(NSString*)value);
    }
}];
```

In Swift
```swift
let js = [1,"a",false] as [Any]
self.wkwebView.callJsFunction(method: "getStringFromJs", args: js) { [weak self] (success,value) in
    if success {
        self?.showMessage(message: "message From js: \(value as? String ?? "无返回值")")
    } else {
        self?.showMessage(message: "方法调用失败, 原因：\(value as! String)")
    }
}
```

传递对象:

In JavaScript 
```javascript
window._gdyBridge.register('getObjectFromJs', function() {
   return { key1: "value1", key2: "value2" };
});
```

In OC
```objective-c
[self.webView callJsFunctionWithMethod:@"getObjectFromJs" returnValueHandler:^(BOOL success,  id _Nullable value) {
    if (success) {
        NSDictionary *dict = (NSDictionary*) value;
        NSLog(@"getObjectFromJs:%@", dict.description);
    } else {
        NSLog(@"调用失败，原因：%@", (NSString*)value);
    }
}];
```

In Swift
```swift
self.wkwebView.callJsFunction(method: "getObjectFromJs") { [weak self] (success, value) in
    if success {
        self?.showMessage(message: "objectFromJs: \(value as? Dictionary ?? [String : AnyObject]())")
    } else {
        self?.showMessage(message: "方法返回失败，原因：\(value as? String ?? "")")
    }
}
```
如果调用不成功的话，success 为 false，同时value字段将是错误信息（String）。
value字段前端如果返回的是json Element的话，则为字典或数组。

### iOS 原生提供方法，JavaScript 来调用

传递字符串

In OC
```objective-c
[self.webView registApiWithMethod:@"getStringFromNative" with:^(NSArray* _Nonnull args) {
    NSLog(@"getStringFromNative: %@",args);
    NSString *str = @"";
    for (id arg in args) {
        if ([arg isKindOfClass:[NSString class]]) {
            str = [str stringByAppendingString: (NSString*)arg];
        }
        if ([arg isKindOfClass: [NSNumber class]]) {
            if ([arg boolValue]) {
                str = [str stringByAppendingString:@"true"];
            } else {
                str = [str stringByAppendingString:@"false"];
            }
        }
    }
    return str;
}];
```

In Swift
```swift
self.wkwebView.registApi(method: "getStringFromNative") { args in
    print("-----> recived js message: \(args.description)\n\n")
    var str = ""
    for arg in args {
        if arg is String {
            str += arg as! String
        }
        if arg is Bool {
            str += (arg as! Bool ? "true" : "false")
        }
    }
    return str
}
```

In JavaScript
```javascript
window._gdyBridge.callNative('getStringFromNative', ['aaa','bbb', true], function(ret) {
   if (ret.success) {
      console.log(`返回结果:${ret.data}`);
   } else {
      console.log(`调用失败:${ret.data}`);
   }
});
```

传递对象

如果前端调用的时候没有传参的话, args将是个空数组, 而不是nil

In OC
```objective-c
[self.webView registApiWithMethod:@"getObjectFromNative" with:^(NSArray* _Nonnull args) {
    NSDictionary *dict =  @{@"key1":@"value1", @"key2":@"value2"};
    return dict;
}];
```

In Swift
```swift
self.wkwebView.registApi(method: "getObjectFromNative") { _ in
    return ["key1":"value1", "key2":"value2"]
}
```

In JavaScript
```javascript 
window._gdyBridge.callNative('getObjectFromNative', null, function(success, data) {
   if (success) {
      const str = JSON.stringify(data);
      console.log(`返回结果:${str}`);
      document.getElementById('bbb').innerHTML = str;
   } else {
      console.log(`调用失败:${data}`);
      document.getElementById('bbb').innerHTML = `调用失败:${data}`;
   }
});
```

### 移除方法

In OC
```objective-c
[self.webView unRegister:@"medthodName"];
```

In Swift
```swift
self.wkwebView.unRegister("medthodName")
```

In JavaScript
```javascript
window._gdyBridge.unRegister('methodName');
```
