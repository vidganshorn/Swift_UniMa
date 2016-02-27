//
//  NewsFeedCell.swift
//  RangeComm
//
//  Created by air on 17.11.15.
//  Copyright © 2015 Christoph Mueller. All rights reserved.
//
import UIKit

    
class NewsFeedCell: UITableViewCell {
  
    @IBOutlet var msgTLabel: UILabel!
    @IBOutlet var ClockLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    
    var onLikeButtonTapped : (() -> Void)? = nil
    
    var onCommentButtonTapped : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func likeButtonPressed(sender: AnyObject) {
        
        if let onLikeButtonTapped = self.onLikeButtonTapped {
            onLikeButtonTapped()
        }
    }
    
    @IBAction func commentButtonPressed(sender: AnyObject) {
        
        if let onCommentButtonTapped = self.onCommentButtonTapped {
            onCommentButtonTapped()
        }
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
}