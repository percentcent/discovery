//
//  ViewController.swift
//  discovery
//
//  Created by peishan lee on 4/10/18.
//  Copyright © 2018 The University of Melbourne. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import os.log
import Kingfisher

class DiscoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SuggestedTableViewCellDelegate {
    //MARK: properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var suggestedTableView: UITableView!
    
    var searchActive : Bool = false
    var searchOrSuggested : Bool = true
    var suggestedUsers = [Suggested]()
    var suggestedUsersJSON : [[String: Any]] = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        suggestedTableView.delegate = self
        suggestedTableView.dataSource = self
        searchBar.delegate = self
        
        // Load the sample data.
        //loadSampleSuggestedUsers()
        //suggestedTableView.reloadData()
        let urlString : String = "http://localhost:3004/suggestedUsers"
        let postParameters = [
            "myUserName" : "myself"
        ]
        
        Alamofire.request(urlString, method: .post, parameters: postParameters as Parameters).responseJSON { (response) in
            if let responseValue = response.result.value as! [String: Any]? {
                if let responseUsers = responseValue["data"] as! [[String: Any]]? {
                    self.suggestedUsersJSON = responseUsers
                    self.loadSuggestedFromJSON(JSON: self.suggestedUsersJSON)
                    self.suggestedTableView?.reloadData()
                }
            }
        }
        
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return suggestedUsers.count
    }
    
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            suggestedUsers.remove(at: indexPath.row)
            suggestedTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
     */
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchOrSuggested{
            return "Suggested"
        }
        else{
            return "Search Results"
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SuggestedTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SuggestedTableViewCell
            else {
            fatalError("The dequeued cell is not an instance of SuggestedTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        /*
        let user = suggestedUsers[indexPath.row]
        cell.suggestedUserName.text = user.name
        cell.suggestedUserImage.image = user.photo
        cell.suggestedUserIntro.text = user.intro
        */
        let user = suggestedUsersJSON[indexPath.row]
        cell.suggestedUserName.text = (user["userName"] as? String) ?? ""
        cell.suggestedUserIntro.text = (user["userIntro"] as? String) ?? ""
        
        let userUrl = URL(string: (user["imageUrl"] as? String)!)
        let processor = RoundCornerImageProcessor(cornerRadius: 40)
        cell.suggestedUserImage.kf.setImage(with: userUrl, options: [.processor(processor)])
        /*
        if let imageUrl = user["imageUrl"] as? String {
            Alamofire.request(imageUrl).responseImage(completionHandler: { (response) in
                print(response)
                if let image = response.result.value {
                    let circularImage = image.af_imageRoundedIntoCircle()
                    DispatchQueue.main.async {
                        cell.suggestedUserImage.image = circularImage
                    }
                }
            })
        }*/
        
        if searchOrSuggested {
            cell.deleteButton.isHidden = false
            cell.followButton.isHidden = false
            changeFollowButton(cell : cell)
        }
        else{
            cell.deleteButton.isHidden = true
            cell.followButton.isHidden = true
        }
        cell.delegate = self
        return cell
    }
    
    func deleteCell(cell: SuggestedTableViewCell, button: UIButton) {
        
        let idx:IndexPath = suggestedTableView.indexPath(for: cell)!
        
        suggestedUsers.remove(at: idx.row)
        suggestedTableView.deleteRows(at: [idx as IndexPath], with: UITableView.RowAnimation.top)

    }
    
    func changeFollowButton(cell : SuggestedTableViewCell){
        cell.followButton.backgroundColor = UIColor.blue
        cell.followButton.setTitle("Follow", for: .normal)
        cell.followButton.setTitleColor(UIColor.white, for: .normal)
        cell.followButton.frame = CGRect(x: 265, y: 12, width: 65, height: 30)
    }
    
    //MARK: Serach Bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
        searchActive = false;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchActive = true;
        let search = searchBar.text!
        if searchActive{
            postSearchUserToServer(searchUserName : search)
        }
    }
    
    //MARK: Private Methods
    private func postSearchUserToServer(searchUserName : String){
        let urlString : String = "http://localhost:3004/searchUsers"
        let postParameters = [
            "searchUserName" : searchUserName,
            "myUserName" : "myself"
        ]
        
        Alamofire.request(urlString, method: .post, parameters: postParameters as Parameters,encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                self.searchOrSuggested = false
                if let responseValue = response.result.value as! [String: Any]? {
                    if let responseUsers = responseValue["data"] as! [[String: Any]]? {
                        self.suggestedUsersJSON = responseUsers
                        //print(self.suggestedUsersJSON)
                        self.loadSuggestedFromJSON(JSON: self.suggestedUsersJSON)
                        self.suggestedTableView?.reloadData()
                    }
                }
                break
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadSuggestedFromJSON(JSON: [[String: Any]]){
        suggestedUsers = []
        if JSON.count > 0{
            let maxCount : Int = JSON.count - 1
            for i in 0...maxCount{
                let user_info = JSON[i]
                var photo : UIImage?
                
                if let imageUrl = user_info["imageUrl"] as? String {
                    Alamofire.request(imageUrl).responseImage(completionHandler: { (response) in
                        print(response)
                        if let image = response.result.value {
                            let circularImage = image.af_imageRoundedIntoCircle()
                            
                            photo = circularImage
                            
                        }
                    })
                }
                
                guard let user_i = Suggested(name: (user_info["userName"] as? String) ?? "", photo: photo, intro: (user_info["userIntro"] as? String) ?? "") else {
                    fatalError("Unable to instantiate user1")
                }
                
                suggestedUsers += [user_i]
            }
        }
    }
    
    
    private func loadSampleSuggestedUsers() {
        suggestedUsers = []
        let photo1 = UIImage(named: "user1")!.af_imageRoundedIntoCircle()
        let photo2 = UIImage(named: "user2")!.af_imageRoundedIntoCircle()
        let photo3 = UIImage(named: "user3")!.af_imageRoundedIntoCircle()
        let photo4 = UIImage(named: "user4")!.af_imageRoundedIntoCircle()
        let photo5 = UIImage(named: "user5")!.af_imageRoundedIntoCircle()
  
        
        guard let user1 = Suggested(name: "jenny2000", photo: photo1, intro: "Jenny") else {
            fatalError("Unable to instantiate user1")
        }
        
        guard let user2 = Suggested(name: "molly2000", photo: photo2, intro: "molly") else {
            fatalError("Unable to instantiate user2")
        }
        
        guard let user3 = Suggested(name: "zoe1234", photo: photo3, intro: "zoe") else {
            fatalError("Unable to instantiate user3")
        }
        
        guard let user4 = Suggested(name: "karen123", photo: photo4, intro: "karen") else {
            fatalError("Unable to instantiate user4")
        }
        
        guard let user5 = Suggested(name: "penny789", photo: photo5, intro: "penny") else {
            fatalError("Unable to instantiate user5")
        }
        guard let user6 = Suggested(name: "nick678", photo: photo5, intro: "nick") else {
            fatalError("Unable to instantiate user6")
        }
        
        
        suggestedUsers += [user1, user2, user3, user4, user5, user6]
        
        
    }
    
    

}

