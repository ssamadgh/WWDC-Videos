//
//  ApplicationManager.swift
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

class ApplicationManager {
    
    // MARK: Properties
    
    private class var applicationsItems: [ApplicationItem] {
        return [
            ApplicationItem(name: "Alto's adventure", bundleName: "Alto", authorName: "Snowman", imageName: "alto", andCategory: .Games),
            ApplicationItem(name: "Calcbot — The Intelligent Calculator and Unit Converter", bundleName: "Calcbot", authorName: "Tapbots", imageName: "calcbot", andCategory: .Productivity),
            ApplicationItem(name: "Capitaine Train : achat de billets de train", bundleName: "Capitaine Train", authorName: "Capitaine Train", imageName: "capitaine_train", andCategory: .Transportation),
            ApplicationItem(name: "Carcassonne", bundleName: "Carcassonne", authorName: "TheCodingMonkeys", imageName: "carcassonne", andCategory: .Games),
            ApplicationItem(name: "Chauffeur-Privé", bundleName: "Chauffeur-Privé", authorName: "Chauffeur Privé", imageName: "chauffeur_prive", andCategory: .Transportation),
            ApplicationItem(name: "Cut the Rope 2", bundleName: "Cut the Rope", authorName: "ZeptoLab UK Limited", imageName: "cut_the_rope", andCategory: .Games),
            ApplicationItem(name: "Dash API Docs", bundleName: "Dash", authorName: "Bogdan Popescu", imageName: "dash", andCategory: .ComputerScienceTools),
            ApplicationItem(name: "Google Docs", bundleName: "Docs", authorName: "Google, Inc.", imageName: "docs", andCategory: .Productivity),
            ApplicationItem(name: "Google Drive - free online storage from Google", bundleName: "Drive", authorName: "Google, Inc.", imageName: "drive", andCategory: .Productivity),
            ApplicationItem(name: "Dropbox", bundleName: "Dropbox", authorName: "Dropbox", imageName: "dropbox", andCategory: .Productivity),
            ApplicationItem(name: "Facebook", bundleName: "Facebook", authorName: "Facebook, Inc.", imageName: "facebook", andCategory: .SocialNetwork),
            ApplicationItem(name: "Google+", bundleName: "Google+", authorName: "Google, Inc.", imageName: "google_plus", andCategory: .SocialNetwork),
            ApplicationItem(name: "Hangouts - free messaging, video, and voice", bundleName: "Hangouts", authorName: "Google, Inc.", imageName: "hangouts", andCategory: .InstantMessaging),
            ApplicationItem(name: "Leo's Fortune", bundleName: "Leo's Fortune", authorName: "1337 & Senri LLC", imageName: "leo_s_fortune", andCategory: .Games),
            ApplicationItem(name: "Letterpress – Word Game", bundleName: "Letterpress", authorName: "atebits", imageName: "letterpress", andCategory: .Games),
            ApplicationItem(name: "LinkedIn", bundleName: "LinkedIn", authorName: "LinkedIn Corporation", imageName: "linkedin", andCategory: .SocialNetwork),
            ApplicationItem(name: "Facebook Messenger", bundleName: "Messenger", authorName: "Facebook, Inc.", imageName: "messenger", andCategory: .InstantMessaging),
            ApplicationItem(name: "Monument Valley", bundleName: "Monument", authorName: "ustwo™", imageName: "monument", andCategory: .Games),
            ApplicationItem(name: "Prompt 2", bundleName: "Prompt", authorName: "Panic, Inc.", imageName: "prompt", andCategory: .ComputerScienceTools),
            ApplicationItem(name: "Shadowmatic", bundleName: "Shadowmatic", authorName: "TRIADA Studio", imageName: "shadowmatic", andCategory: .Games),
            ApplicationItem(name: "Google Sheets", bundleName: "Sheets", authorName: "Google, Inc.", imageName: "sheets", andCategory: .Productivity),
            ApplicationItem(name: "Skype for iPhone", bundleName: "Skype", authorName: "Skype Communications S.a.r.l", imageName: "skype", andCategory: .InstantMessaging),
            ApplicationItem(name: "Slack - Team Communication", bundleName: "Slack", authorName: "", imageName: "slack", andCategory: .InstantMessaging),
            ApplicationItem(name: "Google Slides", bundleName: "Slides", authorName: "Google, Inc.", imageName: "slides", andCategory: .Productivity),
            ApplicationItem(name: "Transmit for iOS", bundleName: "Transmit", authorName: "Panic, Inc.", imageName: "transmit", andCategory: .ComputerScienceTools),
            ApplicationItem(name: "Tweetbot 3 for Twitter. An elegant client for iPhone and iPod touch", bundleName: "Tweetbot", authorName: "Tapbots", imageName: "tweetbot", andCategory: .SocialNetwork),
            ApplicationItem(name: "Tydlig - Calculator Reimagined", bundleName: "Tydlig", authorName: "Tydlig Software AB", imageName: "tydlig", andCategory: .Productivity),
            ApplicationItem(name: "VK", bundleName: "VK", authorName: "VKontakte", imageName: "vk", andCategory: .SocialNetwork),
            ApplicationItem(name: "Voyages-sncf : réserver échanger vos billets de train", bundleName: "Voyages-sncf", authorName: "Voyages-sncf.com", imageName: "voyages_sncf", andCategory: .Transportation),
            ApplicationItem(name: "WhatsApp Messenger", bundleName: "WhatsApp", authorName: "WhatsApp Inc.", imageName: "whatsapp", andCategory: .InstantMessaging),
            ApplicationItem(name: "Workflow: Powerful Automation Made Simple", bundleName: "Workflow", authorName: "DeskConnect, Inc.", imageName: "workflow", andCategory: .ComputerScienceTools)
        ]
    }
    
    // MARK: Get Applications
    
    class func applications() -> [ApplicationItem] {
        return self.applicationsItems
    }
    
    class func applicationsGroupedByCategories() -> [ApplicationCategoryItem] {
        var applicationsGroupedByCategories: [String: ApplicationCategoryItem] = [:]
        
        for applicationItem in self.applicationsItems {
            if applicationsGroupedByCategories[applicationItem.category.rawValue] == nil {
                applicationsGroupedByCategories[applicationItem.category.rawValue] = ApplicationCategoryItem(category: applicationItem.category)
            }
            
            applicationsGroupedByCategories[applicationItem.category.rawValue]!.applications.append(applicationItem)
        }
        
        return Array(applicationsGroupedByCategories.values)
    }
}
