//
//  MyLibraryVC.swift
//  AndreySandbox
//
//  Created by Александр on 12.10.2017.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class MyLibraryVC: CollectionContainerVC {

    @IBOutlet var infoLabel: StyledLabel!
    @IBOutlet var dataView: UIView!
    @IBOutlet var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.title = localized("MyLibrary.TabTitle")
        //self.collectionVC.collectionView?.contentInset.top = Const.kBaseSectionInsets.top
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideInfo()
        self.getLibrary()
    }
    
    func displayInfo(info: String) {
        self.infoLabel.text = info
        self.infoLabel.isHidden = false
        self.signInButton.isHidden = false
        self.dataView.isHidden = true
    }
    
    func hideInfo() {
        self.infoLabel.isHidden = true
        self.signInButton.isHidden = true
        self.dataView.isHidden = false
    }
    
    func showWithEmptyInfo() {
        self.infoLabel.text = localized("MyLibrary.EmptyLibrary")
        self.infoLabel.isHidden = false
        self.signInButton.isHidden = true
        self.dataView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLibrary() {
        
        if (ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn == true) {
            ZypeAppleTVBase.sharedInstance.getMyLibrary({ (videos, error) -> Void in
                //print(videos?.count)
                let section = CollectionSection()
                section.headerStyle = .centered
                section.title = localized("MyLibrary.Title")
                if (videos != nil) {
                    if (videos!.count == 0) {
                        self.showWithEmptyInfo()
                        self.signInButton.isHidden = true
                    } else {
                        let uniqueVideos = videos?.unique{ $0.objectID }
                        for model in uniqueVideos! {
                            section.items.append(FavoriteCollectionItem(videoID: model.objectID))
                        }
                    }
                }
                if (!self.collectionVC.isConfigurated) {
                    self.collectionVC.configWithSections([section])
                } else {
                    self.collectionVC.update([section])
                }
                
                section.items.forEach {
                    $0.loadResources() { success in
                        if success {
                            DispatchQueue.main.async { [weak self] in
                                self?.collectionVC.collectionView.reloadData()
                            }
                        }
                    }
                }
                
                if (error != nil) {
                    displayError(error)
                }
            })
            
        } else {
            self.displayInfo(info: localized("MyLibrary.LoginNeededMsg"))
        }
        
    }

    override func onItemSelected(_ item: CollectionLabeledItem, section: CollectionSection?) {
        let favorite = item as! FavoriteCollectionItem
        if let _ = favorite.object {
            self.playVideo(favorite.object as! VideoModel)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onSignInTapped(_ sender: Any) {
        ZypeUtilities.presentLoginVC(self)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
