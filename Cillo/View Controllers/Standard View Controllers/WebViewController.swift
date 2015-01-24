//
//  WebViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/22/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

// TODO: Document
class WebViewController: UIViewController {
  
  // TODO: Document
  var urlToLoad: NSURL = NSURL()
  
  // TODO: Document.
  override func viewDidLoad() {
    super.viewDidLoad()
    let webView = UIWebView(frame: view.bounds)
    view.addSubview(webView)
    webView.loadRequest(NSURLRequest(URL: urlToLoad))
  }

}
