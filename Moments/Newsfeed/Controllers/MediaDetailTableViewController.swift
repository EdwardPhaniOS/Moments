//
//  MediaDetailTableViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 2/22/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import Firebase

class MediaDetailTableViewController: UITableViewController
{
    var media: Media!
    var currentUser: User!
    var comments: [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Photo"
        
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Storyboard.mediaCellDefaultHeight
        
        if let media = media {
            self.comments = media.comments
            tableView.reloadData()
        }
        
        self.fetchComment()
    }
    
    func fetchComment()
    {
        media.observeNewComment { (comment) in
            if self.comments.contains(comment) == false {
                self.comments.insert(comment, at: 0)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Target / Action
    
    @IBAction func commentDidTap()
    {
        self.performSegue(withIdentifier: Storyboard.showCommentComposer, sender: media)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showCommentComposer {
            let commentComposerVC = segue.destination as! CommentComposerViewController
            commentComposerVC.media = media
            commentComposerVC.currentUser = currentUser
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0 {
            //mediaRow
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.mediaCell, for: indexPath) as! MediaTableViewCell
            
            cell.currentUser = self.currentUser
            cell.media = self.media
            
            return cell
        
        } else {
            //comments row
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.commentCell, for: indexPath) as! CommentTableViewCell
            
            cell.comment = self.comments[indexPath.row - 1]
            
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.mediaHeaderCell) as! MediaHeaderCell
        cell.currentUser = self.currentUser
        cell.media = self.media
        cell.backgroundColor = UIColor.white
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Storyboard.mediaHeaderHeight
    }

}
