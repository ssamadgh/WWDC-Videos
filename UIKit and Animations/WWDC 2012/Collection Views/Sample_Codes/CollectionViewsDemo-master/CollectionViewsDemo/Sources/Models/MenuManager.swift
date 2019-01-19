//
//  MenuManager.swift
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

import Foundation

class MenuManager {
   
    // MARK: Methods
    
    class func menuItemsList() -> [MenuItem] {
        var menuItemsList: [MenuItem] = []
        menuItemsList.append(MenuItem(title: "Basic 01", subtitle: "A basic collection view using a flow layout", andStoryboardId: "Basic01CollectionViewController"))
        menuItemsList.append(MenuItem(title: "Basic 02", subtitle: "A basic collection view using a flow layout delegate", andStoryboardId: "Basic02CollectionViewController"))
        menuItemsList.append(MenuItem(title: "Header/footer", subtitle: "A collection view displaying headers & footers", andStoryboardId: "HeaderFooterCollectionViewController"))
        menuItemsList.append(MenuItem(title: "Decoration", subtitle: "A collection view using decoration views", andStoryboardId: "DecorationCollectionViewController"))
        menuItemsList.append(MenuItem(title: "Horizontal", subtitle: "A horizontal collection view", andStoryboardId: "HorizontalCollectionViewController"))
        
        return menuItemsList
    }
}
