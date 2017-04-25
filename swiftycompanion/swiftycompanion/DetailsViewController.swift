//
//  DetailsViewController.swift
//  swiftycompanion
//
//  Created by Antoine JOUANNAIS on 4/20/17.
//  Copyright © 2017 Antoine JOUANNAIS. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var validated: UILabel!
}

class SkillCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var level: UILabel!
}

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var Cursus: UILabel!
    @IBOutlet weak var SkillTableView: UITableView!
    @IBOutlet weak var ProjectTableView: UITableView!
    
    @IBOutlet weak var locationField: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var imageField: UIImageView!
    @IBOutlet weak var loginField: UILabel!
    
    @IBOutlet weak var emailField: UILabel!
    
    
    @IBOutlet weak var nameField: UILabel!
    
    @IBOutlet weak var phoneField: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var levelField: UILabel!
    
    var projects : [Project] = []
    var skills : [Skill] = []
    
    var login = ""
    var loginVC : ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loginField.text = login
        activity.hidesWhenStopped = true
        activity.startAnimating()
        SkillTableView.dataSource = self
        SkillTableView.delegate = self
        
        ProjectTableView.dataSource = self
        ProjectTableView.delegate = self        
        
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
                            if let responseObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String:AnyObject] {
                                // print("responseObject: \(responseObject)")
                                if let loginInMsg = responseObject["login"] as? String? {
                                    print("login trouvé : \(String(describing: loginInMsg))")
                                }
                                else {
                                    print("Erreur ! login non trouvé")
                                    self.loginField.text = "Unknown user"
                                }
                                if let location = responseObject["location"] as? String? {
                                    self.locationField.text = location
                                }
                                if let email = responseObject["email"] as? String? {
                                    self.emailField.text = email
                                }
                                if let first_name = responseObject["first_name"] as? String? {
                                    self.nameField.text = first_name
                                }
                                if let last_name = responseObject["last_name"] as! String? {
                                    self.nameField.text = self.nameField.text! + " " + last_name
                                }
                                if let phone = responseObject["phone"] as? String? {
                                    self.phoneField.text = phone
                                }
                                if let image_url = responseObject["image_url"] as! String? {
                                    let url = URL(string: image_url)
                                    let data = try Data(contentsOf: url!)
                                    self.imageField.alpha = 0
                                    self.imageField.image = UIImage(data: data)
                                    UIView.animate(withDuration: 1.0) {
                                        self.imageField.alpha = 1
                                    }
                                }
                                if let cursus_users = responseObject["cursus_users"] as! NSArray? {
                                    // print("Debug : cursus_users = \(cursus_users)")
                                    let now = Date();
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = ("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                                    
                                    for cursus_user in cursus_users {
                                        // print("cursus_user = \(cursus_user)")
                                        if let cur_user = cursus_user as? [String:AnyObject] {
                                            // print("cur_user = \(cur_user)")
                                            
                                            // si je trouve une date de fin et qu'elle est depassee, je passe au cursus suivant
                                            if let endDateStr = cur_user["end_at"] as? String {
                                                // print("date trouvée : \(endDateStr)")
                                                let endDate = dateFormatter.date(from: endDateStr)
                                                if endDate! < now {
                                                    continue
                                                }
                                            }
                                            
                                            
                                            
                                            
                                            if let level = cur_user["level"] as! Float? {
                                                // print("level = \(level)")
                                                self.progress.progress = (level - Float(Int(level)))
                                                self.levelField.text = "Level " + String(Int(level)) + " - \(Int(100 * self.progress.progress)) %"
                                            }
                                            // extraire le nom du cursus
                                            if let cursus = cur_user["cursus"] as? [String:AnyObject] {
                                                if let cur_name = cursus["name"] as? String {
                                                    self.Cursus.text = "Cursus : " + cur_name
                                                }
                                            }
                                            // extraire les skills
                                            if let skills = cur_user["skills"] as? [[String:AnyObject]] {
                                                for skill in skills {
                                                    if let skill_name = skill["name"] as? String {
                                                        var newSkill = Skill(name: skill_name)
                                                        
                                                        if let skill_level = skill["level"] as? Float {
                                                            newSkill.level = skill_level
                                                        }
                                                        self.skills.append(newSkill)
                                                    }
                                                }
                                            }
                                            
                                            break
                                            
                                            
                                            
                                        }
                                    }
                                }
                                
                                if let projects_users = responseObject["projects_users"] as! NSArray? {
                                    // print("Debug : projects_users = \(projects_users)")
                                    for projects_user in projects_users {
                                        // print("projects_user = \(projects_user)")
                                        if let pro = projects_user as? [String:AnyObject] {
                                            // print("pro = \(pro)")
                                            if let project = pro["project"] as? [String:AnyObject] {
                                                // print("project = \(project)")
                                                if let project_name = project["slug"] as? String {
                                                    // print("project_name = \(project_name)")
                                                    var newProj = Project(name: project_name)
                                                    
                                                    if let proj_status = pro["status"] as? String {
                                                        newProj.status = proj_status
                                                    }
                                                    if let proj_validated = pro["validated?"] as? Bool {
                                                        newProj.validated = proj_validated
                                                    }
                                                    self.projects.append(newProj)
                                                }
                                                
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        } catch _{
                            print("Connexion lost")
                        }
                        self.activity.stopAnimating()
                        self.ProjectTableView.reloadData()
                        self.SkillTableView.reloadData()
                    }
                }
            })
            task.resume()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of items in the sample data structure.
        
        var count:Int?
        
        if tableView == self.ProjectTableView {
            count = projects.count
            print("numberOfRowsInSection pour ProjectTableView = \(String(describing: count))")
        }
        
        if tableView == self.SkillTableView {
            count =  skills.count
            print("numberOfRowsInSection pour SkillTableView = \(String(describing: count))")
        }
        
        return count!
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if tableView == self.ProjectTableView {
            print("cellForRowAt pour ProjectTableView")
            if let cell1 : ProjectCell = tableView.dequeueReusableCell(withIdentifier: "Projects", for: indexPath as IndexPath) as? ProjectCell {
                //var str : String = projects[indexPath.row].name + " status = " + String(projects[indexPath.row].status) + " "
                cell1.name.text = projects[indexPath.row].name
                if projects[indexPath.row].validated {
                    cell1.validated.text = "✅"
                }
                else {
                    cell1.validated.text = "❌"
                }
                cell1.status.text = projects[indexPath.row].status
                cell = cell1
            }
        }
        
        if tableView == self.SkillTableView {
            print("cellForRowAt pour SkillTableView")
            
            let cell2 : SkillCell = tableView.dequeueReusableCell(withIdentifier: "Skills", for: indexPath as IndexPath) as! SkillCell
            cell2.name.text = skills[indexPath.row].name
            if let lev = skills[indexPath.row].level {
                let levstr = String(Int(lev)) + " - \(Int(100 * (lev - Float(Int(lev))))) %"
                cell2.level.text = levstr
            }
            cell = cell2
        }
        
        return cell!
    }
    
}
