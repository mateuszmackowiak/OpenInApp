#import "FlashRuntimeExtensions.h"
#import "TTOpenInAppActivity.h"


/* This is a TEST function that is being included as part of this template. 
 *
 * Users of this template are expected to change this and add similar functions 
 * to be able to call the native functions in the ANE from their ActionScript code
 */
DEFINE_ANE_FUNCTION(IsSupported)
{
    NSLog(@"Entering IsSupported()");

    FREObject fo;

    FREResult aResult = FRENewObjectFromBool(YES, &fo);
    if (aResult == FRE_OK)
    {
        //things are fine
        NSLog(@"Result = %d", aResult);
    }
    else
    {
        //aResult could be FRE_INVALID_ARGUMENT or FRE_WRONG_THREAD, take appropriate action.
        NSLog(@"Result = %d", aResult);
    }
    
    NSLog(@"Exiting IsSupported()");
    
    return fo;
}


///gets a param for freobject as a double
double getDoubleValue(FREObject obj,const uint8_t* param, FREContext*ctxRef){
    
    FREObject asParamObj;
    
    if(FREGetObjectProperty(obj, (const uint8_t*)param, &asParamObj, NULL)!=FRE_OK){
        NSLog(@"error getting double value form object");
        FREDispatchStatusEventAsync(ctxRef, (const uint8_t *)"Error", (const uint8_t *)"error getting double value form object");
        return NAN;
    }
    double returnVal;
    if(FREGetObjectAsDouble(asParamObj,&returnVal)!=FRE_OK){
        return NAN;
    }
    return returnVal;
}


DEFINE_ANE_FUNCTION(callOpenInApp)
{
    FREObject fo;
    FRENewObjectFromBool(NO, &fo);
    
    @try{
        
        if(argc<2 || !argv[0])
            return fo;
        
        //get url to open
        uint32_t string1Length;
        const uint8_t *string1;
        FREGetObjectAsUTF8(argv[0], &string1Length, &string1);
        
        //get frame
        CGRect rec;
        if(argv[1]){
        
            CGFloat X = getDoubleValue(argv[1], (const uint8_t *)"x",context);
            CGFloat Y = getDoubleValue(argv[1], (const uint8_t *)"y",context);
            CGFloat W = getDoubleValue(argv[1], (const uint8_t *)"width",context);
            CGFloat H = getDoubleValue(argv[1], (const uint8_t *)"height",context);
            
            rec = CGRectMake(X, Y, W, H);
        }else{
            rec = CGRectMake(0, 0, 20, 20);
        }
        
        // Convert C strings to Obj-C strings
        NSString *filePath = [NSString stringWithUTF8String:(char*)string1];
        
        
        NSURL *URL = [NSURL fileURLWithPath:filePath];
        NSError *err;
        if([URL checkResourceIsReachableAndReturnError:&err]==NO){
            FREDispatchStatusEventAsync(context, (uint8_t*)"Error", (uint8_t*)[[[err localizedDescription] stringByAppendingFormat:@" while trying to open %s",string1] UTF8String]);
            return fo;
        }
        UIViewController * controler = [[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController];
        
        TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:controler.view andRect:rec];

        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:@[openInAppActivity]];
        
       
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            // Store reference to superview (UIActionSheet) to allow dismissal
            openInAppActivity.superViewController = activityViewController;
            // Show UIActivityViewController
            [controler presentViewController:activityViewController animated:YES completion:NULL];
            FRENewObjectFromBool(YES, &fo);
            return fo;
        } else {
            // Create pop up
            UIPopoverController *activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            // Store reference to superview (UIPopoverController) to allow dismissal
            openInAppActivity.superViewController = activityPopoverController;
            // Show UIActivityViewController in popup
            [activityPopoverController presentPopoverFromRect:rec inView:controler.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
            FRENewObjectFromBool(YES, &fo);
            return fo;
        }
    }@catch (NSException * e) {
        
        FREDispatchStatusEventAsync(context, (uint8_t*)"Error", (uint8_t*)[[e reason] UTF8String]);
    }
    return fo;
}




#pragma mark - ANE setup



/* ContextInitializer()
 * The context initializer is called when the runtime creates the extension context instance.
 */
void OpenInAppContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    NSLog(@"Entering ContextInitializer()");

    /* The following code describes the functions that are exposed by this native extension to the ActionScript code.
     * As a sample, the function isSupported is being provided.
     */
    *numFunctionsToTest = 2;

    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctionsToTest));
    func[0].name = (const uint8_t*) "isSupported";
    func[0].functionData = NULL;
    func[0].function = &IsSupported;
    
    func[1].name = (const uint8_t*) "callOpenInApp";
    func[1].functionData = NULL;
    func[1].function = &callOpenInApp;

    *functionsToSet = func;


    NSLog(@"Exiting ContextInitializer()");
}

/* ContextFinalizer()
 * The context finalizer is called when the extension's ActionScript code
 * calls the ExtensionContext instance's dispose() method.
 * If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls ContextFinalizer().
 */
void OpenInAppContextFinalizer(FREContext ctx) 
{
    NSLog(@"Entering ContextFinalizer()");

    // Nothing to clean up.
    NSLog(@"Exiting ContextFinalizer()");
    return;
}


/* OpenInAppExtInitializer()
 * The extension initializer is called the first time the ActionScript side of the extension
 * calls ExtensionContext.createExtensionContext() for any context.
 *
 * Please note: this should be same as the <initializer> specified in the extension.xml
 */
void OpenInAppExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    NSLog(@"Entering OpenInAppExtInitializer()");
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &OpenInAppContextInitializer;
    *ctxFinalizerToSet = &OpenInAppContextFinalizer;
    
    NSLog(@"Exiting OpenInAppExtInitializer()");
}

/* OpenInAppExtFinalizer()
 * The extension finalizer is called when the runtime unloads the extension. However, it may not always called.
 *
 * Please note: this should be same as the <finalizer> specified in the extension.xml
 */
void OpenInAppExtFinalizer(void* extData)
{
    NSLog(@"Entering OpenInAppExtFinalizer()");
    
    // Nothing to clean up.
    NSLog(@"Exiting OpenInAppExtFinalizer()");
    return;
}


