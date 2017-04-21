//
//  DetailsViewController.swift
//  swiftycompanion
//
//  Created by Antoine JOUANNAIS on 4/20/17.
//  Copyright © 2017 Antoine JOUANNAIS. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var imageField: UIImageView!
    @IBOutlet weak var loginField: UILabel!
    
    @IBOutlet weak var emailField: UILabel!
    @IBOutlet weak var firstNameField: UILabel!
    @IBOutlet weak var lastNameField: UILabel!
    @IBOutlet weak var phoneField: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var levelField: UILabel!
    
    var login = ""
    var loginVC : ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginField.text = login
        getFrom42(login)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getFrom42(_ str : String) {
        print("getFrom42(\(str))")
        
        if let token = loginVC?.token {
            
            let q = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let url = "https://api.intra.42.fr/v2/users/\(q)"
            print("url : \(url)")
            let my_mutableURLRequest = NSMutableURLRequest(url: URL(string : url)!)
            my_mutableURLRequest.httpMethod = "GET"
            my_mutableURLRequest.setValue("Bearer " +  token, forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: my_mutableURLRequest as URLRequest, completionHandler: {
                (data, response, error) in
                if let err = error {
                    print("Erreur sur requete web : \(err)")
                } else if let d = data {
                    DispatchQueue.main.async {
                    do {
//                        if let responseObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String:AnyObject],
//                            let arrayStatuses = responseObject["statuses"] as? [[String:AnyObject]] {
                            if let responseObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String:AnyObject] {
                                print("responseObject: \(responseObject)")
                                if let loginInMsg = responseObject["login"] as! String? {
                                    print("login trouvé : \(loginInMsg)")
                                }
                                else {
                                    print("Erreur ! login non trouvé")
                                    self.loginField.text = "Unknown user"
                                }
                                
                                if let email = responseObject["email"] as! String? {
                                    self.emailField.text = email
                                }
                                if let first_name = responseObject["first_name"] as! String? {
                                    self.firstNameField.text = first_name
                                }
                                if let last_name = responseObject["last_name"] as! String? {
                                    self.lastNameField.text = last_name
                                }
                                if let phone = responseObject["phone"] as! String? {
                                    self.phoneField.text = phone
                                }
                                if let image_url = responseObject["image_url"] as! String? {
                                    let url = URL(string: image_url)
                                    let data = try Data(contentsOf: url!)
                                    self.imageField.image = UIImage(data: data)
                                }
                                if let cursus_users = responseObject["cursus_users"] as! NSArray? {
                                    print("Debug : cursus_users = \(cursus_users)")
                                    let now = Date();
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = ("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                                    
                                    for cursus in cursus_users {
                                        print("cursus = \(cursus)")
                                        if let cur = cursus as? [String:AnyObject] {
                                            print("cur = \(cur)")
                                            if let endDateStr = cur["end_at"] as? String {
                                                print("date trouvée : \(endDateStr)")
                                                let endDate = dateFormatter.date(from: endDateStr)
                                                if endDate! >= now {
                                                    if let level = cur["level"] as! Float? {
                                                        print("level = \(level)")
                                                        self.progress.progress = (level - Float(Int(level)))
                                                        self.levelField.text = "Level " + String(Int(level)) + " \(100 * self.progress.progress) %"
                                                        break
                                                    }
                                                }
 
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                else {
                                    self.progress.progress = 0
                                   self.levelField.text = "Level unknown"
                                }
                                
                                /*
                                for status in arrayStatuses {
                                let text = status["text"] as! String
                                let user = status["user"]?["name"]  as! String
                                if let date = status["created_at"] as? String {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
                                    if let date = dateFormatter.date(from: date) {
                                        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                                        let newDate = dateFormatter.string(from: date)
                                    }
                                }
 
                                print(status)
                            }
 */
                        }
                        print("Donnees recues de l'API")
                        // A FINIR
                        
                    } catch _{
                        print("Connexion lost")
                    }
                    }
                }
            })
            task.resume()
        }
    }

}
