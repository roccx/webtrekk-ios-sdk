//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by arsen.vartbaronov on 17/08/16.
//

import UIKit
import Webtrekk
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    var webView: WKWebView?
    @IBOutlet var containerView: UIView!
    var configuration: WKWebViewConfiguration?

    override func loadView(){
        super.loadView()
        
        
        guard  WebtrekkTracking.isInitialized() else {
            return
        }
        
        if self.configuration == nil{
            self.configuration = WKWebViewConfiguration()
            WebtrekkTracking.updateWKWebViewConfiguration(self.configuration)
        }
        
        let rect = self.containerView?.frame ?? CGRect(origin: CGPoint(x: 100, y: 300), size: CGSize(width: 100, height: 300))

        self.webView = WKWebView(frame: rect, configuration: self.configuration!)
        self.view.addSubview(self.webView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://jenkins-yat-dev-01.webtrekk.com/web/hello.html")
        let req = URLRequest(url: url!)
        self.webView?.navigationDelegate = self
        self.webView?.load(req)
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "appCallback"{
            WebtrekkTracking.defaultLogger.logDebug("message body " + (message.body as! String))
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        WebtrekkTracking.defaultLogger.logDebug("webView fail with error:\(error.localizedDescription) ")
    }
    
    #if TEST_APP
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func adClearProcess(_ sender: UIButton) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
        
        self.activityIndicator.startAnimating()
        
        delegate.initWithConfig(configName: "webtrekk_config_AdClearId_integration_test")
        WebtrekkTracking.instance().mediaCode = "wt_mc=de.inapp.webtrekkiOSTest"
        WebtrekkTracking.instance().trackPageView("pageName")
        WebtrekkTracking.instance().sendPendingEvents()
        sleep(5)
        delegate.initWithConfig()
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Alert", message: "AdClear URL has been sent", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func crashProceed(_ sender: UIButton) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate{
            delegate.setAfterCrashMode()
            DispatchQueue.global(qos: .background).async {
                let exception = ExceptionCreator()
                exception.throwCocoaPod()
            }
        }
    }
   #endif
}

