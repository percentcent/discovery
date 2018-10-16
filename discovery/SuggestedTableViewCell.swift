//
//  SuggestedTableViewCell.swift
//  discovery
//
//  Created by peishan lee on 14/10/18.
//  Copyright © 2018 The University of Melbourne. All rights reserved.
//

import UIKit
import Alamofire

protocol SuggestedTableViewCellDelegate: NSObjectProtocol {
    
    func deleteCell(cell: SuggestedTableViewCell, button: UIButton)
}


class SuggestedTableViewCell: UITableViewCell {
    //use js to implement the navigation from search results/suggested table view cell to user profile, and send request to server meanwhile
    //MARK: properties
    
    @IBOutlet weak var suggestedUserImage: UIImageView!
    @IBOutlet weak var suggestedUserName: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var suggestedUserIntro: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    weak var delegate:SuggestedTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func BtnClick(_ sender: UIButton) {
        delegate?.deleteCell(cell: self, button: sender)
    }
    
    @IBAction func followSuggestedUser(_ sender: UIButton) {
        self.changeFollowButton()
        let urlString : String = "http://localhost:3004/followingSuggested"
        let postParameters = [
            "followedUserName" : suggestedUserName.text,
            "followingUserName" : "myself"
        ]
        
        Alamofire.request(urlString, method: .post, parameters: postParameters as Parameters,encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response)
                break
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    //MARK: private func
    private func changeFollowButton(){
        self.followButton.backgroundColor = UIColor.gray
        self.followButton.setTitle("Following", for: .normal)
        self.followButton.setTitleColor(UIColor.black, for: .normal)
        self.followButton.frame = CGRect(x: 265, y: 12, width: 100, height: 30)
        self.deleteButton.isHidden = true
        //need to transition to initial state when suggested users show again?
    }
}
