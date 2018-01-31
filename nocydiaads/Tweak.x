@interface CyteWebView : UIWebView
@end

%hook CyteWebView

- (void)_updateViewSettings {
    %orig;
    
    // 100% stolen from Flame, no idea what this does, really
    [self stringByEvaluatingJavaScriptFromString:@"var child = document.getElementsByClassName('spots');while(child[0]){child[0].parentNode.removeChild(child[0]);}"];
}

%end
