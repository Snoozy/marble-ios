//
//  WebViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/22/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles displaying web pages within the app.
class WebViewController: UIViewController {
  
  // MARK: Properties
  
  /// The url that will be displayed by this WebViewController.
  var urlToLoad: NSURL = NSURL()
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let webView = UIWebView(frame: view.bounds)
    view.addSubview(webView)
    webView.loadRequest(NSURLRequest(URL: urlToLoad))
  }
}
