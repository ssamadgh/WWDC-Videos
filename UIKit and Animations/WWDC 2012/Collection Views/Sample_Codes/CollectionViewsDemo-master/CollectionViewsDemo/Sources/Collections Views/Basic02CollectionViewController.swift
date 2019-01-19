//
//  Basic02CollectionViewController.swift
//
//  Copyright © 2015 Sébastien MICHOY and contributors.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer. Redistributions in binary
//  form must reproduce the above copyright notice, this list of conditions and
//  the following disclaimer in the documentation and/or other materials
//  provided with the distribution. Neither the name of the nor the names of
//  its contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

import UIKit

class Basic02CollectionViewController: UIViewController {
    
    // MARK: Properties
    
    let applicationsGroupedByCategory: [ApplicationCategoryItem]
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        self.applicationsGroupedByCategory = ApplicationManager.applicationsGroupedByCategories()
        
        super.init(coder: aDecoder)
    }
    
    // MARK: View Life Cycle
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let animation: (UIViewControllerTransitionCoordinatorContext!) -> Void = { context in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
        
        let completion: (UIViewControllerTransitionCoordinatorContext!) -> Void = {context in
        }
        
        coordinator.animate(alongsideTransition: animation, completion: completion)
        
        super.viewWillTransition(to: size, with: coordinator)
    }
}

extension Basic02CollectionViewController: UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource Protocol
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let application = self.applicationsGroupedByCategory[indexPath.section].applications[indexPath.row]
        let cell: UICollectionViewCell
        
        if indexPath.section % 2 == 0 {
            let cellIcon = collectionView.dequeueReusableCell(withReuseIdentifier: "ApplicationIconNameCollectionViewCell", for: indexPath) as! ApplicationIconNameCollectionViewCell
            cellIcon.fillWithApplicationItem(application: application)
            cell = cellIcon
        } else {
            let cellDetail = collectionView.dequeueReusableCell(withReuseIdentifier: "ApplicationDetailCollectionViewCell", for: indexPath) as! ApplicationDetailCollectionViewCell
            cellDetail.fillWithApplicationItem(application: application)
            cell = cellDetail
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.applicationsGroupedByCategory[section].applications.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.applicationsGroupedByCategory.count
    }
}

extension Basic02CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDelegateFlowLayout Protocol
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let spacesWidth = (deviceType() == .phone) ? 2 : 10 as CGFloat
        let inset = UIEdgeInsets(top: 10, left: spacesWidth, bottom: 5, right: spacesWidth)
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let spacesWidth = (deviceType() == .phone) ? 2 : 10 as CGFloat
        
        return spacesWidth
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let spacesWidth = (deviceType() == .phone) ? 2 : 10 as CGFloat
        
        return spacesWidth
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize: CGSize
        
        if indexPath.section % 2 == 0 {
            cellSize = ApplicationIconNameCollectionViewCell.standardSizeForApplicationItem()
        } else {
            let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
            let minimumInteritemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
            let cellHeight = ApplicationDetailCollectionViewCell.standardHeightForApplicationItem()
            let cellWidth = (collectionView.frame.width - minimumInteritemSpacing - inset.left - inset.right) / 2
            
            cellSize = CGSize(width: cellWidth, height: cellHeight)
        }
        
        return cellSize
    }
}
