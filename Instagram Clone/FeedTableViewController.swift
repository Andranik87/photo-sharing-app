//
//  FeedTableViewController.swift
//  Instagram Clone
//
//  Created by Andranik Karapetyan on 5/31/20.
//  Copyright © 2020 Andranik Karapetyan. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {

    var users = [String: String]()
    var comments = [String]()
    var usernames = [String]()
    var imageFiles = [PFFileObject]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: PFUser.current()?.username)
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects
            {
                for object in users
                {
                    if let user = object as? PFUser
                    {
                        self.users[user.objectId!] = user.username!
                    }
                }
            }
            
            let getFollowedUsersQuery = PFQuery(className: "Following")
            
            getFollowedUsersQuery.whereKey("follower", equalTo: PFUser.current()?.objectId)
            
            getFollowedUsersQuery.findObjectsInBackground { (objects, errir) in
                
                if let followers = objects
                {
                    for follower in followers
                    {
                        if let followedUser = follower["following"]
                        {
                            let query = PFQuery(className: "Post")
                            
                            query.whereKey("userid", equalTo: followedUser)
                            
                            query.findObjectsInBackground { (objects, error) in
                                
                                if let posts = objects
                                {
                                    for post in posts
                                    {
                                        self.comments.append(post["message"] as! String)
                                        self.usernames.append(self.users[post["userid"] as! String]!)
                                        self.imageFiles.append(post["imageFile"] as! PFFileObject)
                                        
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 300;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //-/ Create Custom tableView Cell by casting a dequeued cell as the Custom Type
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedTableViewCell

        imageFiles[indexPath.row].getDataInBackground
        { (data, error) in
            
            if let imageData = data
            {
                if let imageToDisplay = UIImage(data: imageData)
                {
                    cell.postedImage.image = imageToDisplay
                }
            }
        }

        cell.comment.text = comments[indexPath.row]
        cell.userInfo.text = usernames[indexPath.row]
        // Configure the cell...
        cell.layoutIfNeeded()
        return cell
    }
}
