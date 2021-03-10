//
//  UserTableViewController.swift
//  Instagram Clone
//
//  Created by Andranik Karapetyan on 5/26/20.
//  Copyright © 2020 Andranik Karapetyan. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController
{
    var usernames = [""]
    var objectIDs = [""]
    var isFollowing = ["" : false]
    
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        updateTable();
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(UserTableViewController.updateTable), for: UIControl.Event.valueChanged)
        tableView.addSubview(refresher)
    }

    //-/ RETRIEVE PARSE DATA ADN REFLECT LOCALLY TO DISPLAY PFUsers ON A TABLEVIEW
    @objc func updateTable()
    {
    //-/ Get User Data
        let query = PFUser.query()
    //-/ Exclude current (self) user
        query?.whereKey("username", notEqualTo: PFUser.current()?.username)
        
    //-/ Look for object - user in this case - in background
        query?.findObjectsInBackground(block: { (users, error) in
            
    //-/ Check for errors in block
            if error != nil
            {
                print (error)
            }
    //-/ Check if a user exsts
            else if let users = users
            {
    //-/ Clear all iniial values
                self.usernames.removeAll()
                self.objectIDs.removeAll()
                self.isFollowing.removeAll()
                
    //-/ Look through all returned objects (PFObjects)
                for object in users
                {
    //-/ Check if PFObject is a PFUser
                    if let user = object as? PFUser
                    {
    //-/ Check if there is a username
                        if let username = user.username
                        {
    //-/ Check if user has objectIds
                            if let objectID = user.objectId
                            {
                                let userName = username.components(separatedBy: "@")[0]
                                
    //-/ Store usernames and objectIDs locally
                                self.usernames.append(userName)
                                self.objectIDs.append(objectID)
                                
    //-/ Find followed user with query
                                let query = PFQuery(className: "Following")
                                
                                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                                query.whereKey("following", equalTo: objectID)
                                
    //-/ Find the query in background
                                query.findObjectsInBackground { (objects, error) in
                                    
    //-/ Check if query returned objects
                                    if let objects = objects
                                    {
    //-/ Store "following" status locally
                                        if objects.count > 0
                                        {
                                            self.isFollowing[objectID] = true
                                        }
                                        else
                                        {
                                            self.isFollowing[objectID] = false
                                        }
                                        
    //-/ Check if updating of followers is complete before ending view refresh
                                        if self.usernames.count == self.isFollowing.count
                                        {
                                        //-/ Reload TableView data
                                            self.tableView.reloadData()
                                        //-/ End view refresh
                                            self.refresher.endRefreshing()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func LogoutUser(_ sender: Any)
    {
        //-/ Log out user from Parse
        PFUser.logOut()
        
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = usernames[indexPath.row]
        
        if let followsBoolean = isFollowing[objectIDs[indexPath.row]]
        {
            if followsBoolean
            {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        }

        return cell
    }
    
    //-/ When a particular Row is Tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let cell = tableView.cellForRow(at: indexPath)

    //-/ Check follow status locally based on cell selected
        if let followsBollean = isFollowing[objectIDs[indexPath.row]]
        {
    //-/ Check if is following
            if followsBollean
            {
    //-/ Set to follow to false locally
                isFollowing[objectIDs[indexPath.row]] = false
                
    //-/ Remove checkmark on a TableView Cell
                cell?.accessoryType = UITableViewCell.AccessoryType.none
                
    //-/ Find followed user with query
                let query = PFQuery(className: "Following")
                
                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                query.whereKey("following", equalTo: objectIDs[indexPath.row])
                
    //-/ Find the query in background
                query.findObjectsInBackground
                { (objects, error) in
                    
    //-/ Check if the objects are returned
                    if let objects = objects
                    {
    //-/ Delete each object (User) in the list of users returned
                        for object in objects
                        {
                            object.deleteInBackground()
                        }
                    }
                }
            }
            else
            {

            //-/ Update value of user being followed:followed locally
                isFollowing[objectIDs[indexPath.row]] = true

            //-/ Put checkmark on a TableView Cell
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                
            //-/ Retrieve a Class from Parse by PFObject
                let following = PFObject(className: "Following")
                
            //-/ Assign curent PFUser as a "follower"
                following["follower"] = PFUser.current()?.objectId
            //-/ Assign selected user at Cell to "following" - the one being followed
                following["following"] = objectIDs[indexPath.row]
                
            //-/ Save Parse Object in background
                following.saveInBackground()
            }
        }
    }
}
