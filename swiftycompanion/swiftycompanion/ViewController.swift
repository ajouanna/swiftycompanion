//
//  ViewController.swift
//  swiftycompanion
//
//  Created by Antoine JOUANNAIS on 4/18/17.
//  Copyright © 2017 Antoine JOUANNAIS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let consumerKey : String = "f833c3cb76771590d718ea287b618ad9557cf351761e6682ac8d3641a6553a3c"
    let consumerSecret : String = "618e7c8009abfe61ed61ca8b7856851c4f5e3a2c5aa3bdf71365adcbd68b78db"
    var token : String?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initToken()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initToken() {
        let bearer_credentials = ((consumerKey + ":" + consumerSecret).data(using: String.Encoding.utf8))?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let url = URL(string: "https://api.intra.42.fr/oauth/token")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("Basic " + bearer_credentials!, forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            print(response!)
            guard let data = data, error == nil else {
                print(error!)
                return
            }
            do {
                if let dic: NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    print(dic)
                    self.token = (dic["access_token"] as? String)!
                    print("token recupéré de 42 : \(String(describing: self.token))")

                }
            }
            catch (let err) {
                print(err)
            }
        }
        task.resume()
    }
}

