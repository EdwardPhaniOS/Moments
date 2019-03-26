//
//  NewsfeedTableViewController.swift
//  Moments
//
//  Created by Tan Vinh Phan on 1/27/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import Firebase

public struct Storyboard
{
    static let showWelcome = "ShowWelcomeViewController"
    static let postComposerNVC = "PostComposerNavigationVC"
    
    static let mediaCell = "MediaCell"
    static let mediaHeaderCell = "MediaHeaderCell"
    static let mediaHeaderHeight: CGFloat = 57
    static let mediaCellDefaultHeight: CGFloat = 597
    
    static let showMediaDetailSegue = "ShowMediaDetailSegue"
    
    static let commentCell = "CommentCell"
    static let showCommentComposer = "ShowCommentComposer"
}

class NewsfeedTableViewController: UITableViewController
{
    var imagePickerHelper: ImagePickerHelper!
    var currentUser: User?
    var media = [Media]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check if the user logged in or not
        Auth.auth().addStateDidChangeListener { (auth, firUser) in
            if let user = firUser {
                let userDataRef = FIRDatabaseReference.users(uid: user.uid).reference()
                userDataRef.observeSingleEvent(of: .value, with: { (snapShot) in
                    let userDict = snapShot.value as? [String : Any]
                    if let userDict = userDict {
                        self.currentUser = User(dictionary: userDict)
                        
                    } else {
                        let alert = UIAlertController(title: "Account Error", message: "Please log out then sign-in another account", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                
            } else {
                self.performSegue(withIdentifier: Storyboard.showWelcome, sender: nil)
            }
        }
        
        self.tabBarController?.delegate = self
        
        tableView.estimatedRowHeight = Storyboard.mediaCellDefaultHeight
        tableView.rowHeight = Storyboard.mediaCellDefaultHeight
        tableView.separatorColor = UIColor.clear
        
        fetchMedia()
    }
    
    func fetchMedia()
    {
        Media.observeNewMedia { (media) in
            if self.media.contains(media) == false {
                self.media.insert(media, at: 0)
                self.tableView.reloadData()
            }
        }
    }
    
}

extension NewsfeedTableViewController : UITabBarControllerDelegate
{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is DummyPostComposerViewController
        {
            imagePickerHelper = ImagePickerHelper(viewController: self, completion: { (image) in
                let postComposerNVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Storyboard.postComposerNVC) as! UINavigationController
                
                let postComposerVC = postComposerNVC.topViewController as! PostComposerViewController
                postComposerVC.image = image
                
                self.present(postComposerNVC, animated: true, completion: nil)
            })
            return false
            
        } else {
            return true
        }
    }
    
}

// MARK: - UI TableView DataSource

extension NewsfeedTableViewController
{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return media.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if media.count == 0 {
            return 0
        
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.mediaCell, for: indexPath) as! MediaTableViewCell
        
        cell.currentUser = self.currentUser
        cell.media = self.media[indexPath.section]
        cell.selectionStyle = .none
        cell.delegate = self
        
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.mediaHeaderCell) as! MediaHeaderCell
        cell.currentUser = self.currentUser
        cell.media = media[section]
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return Storyboard.mediaHeaderHeight
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Storyboard.mediaHeaderHeight
    }

}

//MARK: - UITableViewDelegate
extension NewsfeedTableViewController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: Storyboard.showMediaDetailSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == Storyboard.showMediaDetailSegue
        {
            let mediaDetailTVC = segue.destination as! MediaDetailTableViewController
            
            if let selectedIndex = tableView.indexPathForSelectedRow {
                mediaDetailTVC.media = media[selectedIndex.section]
                mediaDetailTVC.currentUser = self.currentUser
            }
            
            if let selectedMedia = sender as? Media {
                mediaDetailTVC.currentUser = currentUser
                mediaDetailTVC.media = selectedMedia
            }
            
        } else if segue.identifier == Storyboard.showCommentComposer {
            let commentComposer = segue.destination as! CommentComposerViewController
            
            let selectedMedia = sender as! Media
            commentComposer.currentUser = self.currentUser
            commentComposer.media = selectedMedia
        }
        
    }
    
}

//MARK: - MediaTableCellDelegate

extension NewsfeedTableViewController : MediaTableViewCellDelegate
{
    func viewAllCommentDidTap(media: Media) {
        self.performSegue(withIdentifier: Storyboard.showMediaDetailSegue, sender: media)
    }
    
    func commentButtonDidTap(media: Media) {
        self.performSegue(withIdentifier: Storyboard.showCommentComposer, sender: media)
    }
    
}
