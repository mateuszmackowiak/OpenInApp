OpenInApp
=========

Adobe Air Native Extension for "Open In..."

![](https://github.com/mateuszmackowiak/OpenInApp/raw/master/Screenshot.png)

Works only on IOS6.
Packed with Adobe air 3.6 beta

This is a quick wraper for the [TTOpenInAppActivity](https://github.com/honkmaster/TTOpenInAppActivity).

I have used the https://github.com/mateuszmackowiak/ANE-Wizard

*Usage:*
		var b:Button = Button(event.target);
		OpenInApp..getInstance().showOpenInAppDialog(path,new Rectangle(b.x,b.y,b.width,b.height));
