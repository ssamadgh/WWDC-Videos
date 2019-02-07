//
//  ImportEpisodesOperation.swift
//  OperationScreencast
//
//  Created by Ben Scheirman on 7/21/15.
//  Copyright (c) 2015 NSScreencast. All rights reserved.
//

import Foundation
import CoreData

//struct ParsedEpisode : Printable {
struct ParsedEpisode {

    let serverId: Int
    let episodeNumber: Int
    let title: String
    let artworkUrl: String
    
    init(_ dict: [String: Any]) {
        serverId = dict["id"] as? Int ?? -1
        episodeNumber = dict["episode_number"] as? Int ?? -1
        title = dict["title"] as? String ?? "<untitled>"
        artworkUrl = dict["retina_image_url"] as? String ?? dict["thumbnail_url"] as? String ?? dict["small_artwork_url"] as? String ?? ""
    }
    
    var description: String {
        return "\(episodeNumber) - \(title)"
    }
}

class ImportEpisodesOperation : ASOperation {
    var path: String
    var error: Error?
    
    private var importContext: NSManagedObjectContext
    
    init(path: String, context: NSManagedObjectContext) {
        self.path = path
		importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.mergePolicy = NSOverwriteMergePolicy
		importContext.parent = context
    }
    
    override func execute() {
        print("Executing import")
        if let episodes = parseEpisodes() {
			importEpisodes(episodes: episodes)
        } else {
            print("Couldn't parse episodes")
        }
        
        finish()
    }
    
	func parseEpisodes() -> [ParsedEpisode]? {
		if let inputStream = InputStream(fileAtPath: path) {
			inputStream.open()
			
			do {
				
				let json = try JSONSerialization.jsonObject(with: inputStream, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: [[String: Any]]]
				inputStream.close()
				
				let episodeDictionaries = json["episodes"]
				let episodes = episodeDictionaries!.map { ParsedEpisode($0) }
				print("Parsed \(episodes.count) episodes.")
				return episodes
				
			} catch {
				inputStream.close()
				self.error = error
				finish()
				return nil
			}
			
		} else {
			print("download file did not exist, aborting")
			finish()
			return nil
		}
	}
    
    func importEpisodes(episodes: [ParsedEpisode]) {
		importContext.perform {
            let existingEpisodes = self.existingEpisodes()
            for parsed in episodes {
                let episode: Episode
				
                if let existing = (existingEpisodes.filter {
					parsed.serverId == $0.serverId.intValue
                    }).first {
                    episode = existing
                } else {
					episode = NSEntityDescription.insertNewObject(forEntityName: "Episode", into: self.importContext) as! Episode
                }
                
				episode.serverId = NSNumber(value: parsed.serverId)
				episode.episodeNumber = NSNumber(value: parsed.episodeNumber)
                episode.title = parsed.title
                episode.artworkUrl = parsed.artworkUrl
            }
            
            self.saveContext()
        }
    }
    
    func existingEpisodes() -> Set<Episode> {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Episode")
		
		let episodes = try! importContext.fetch(request).map {  $0 as! Episode }
        return Set(episodes)
    }
	
	@discardableResult
    func saveContext() -> Error? {
        var saveError: Error?
        var context: NSManagedObjectContext? = importContext
        
        while context != nil {
            
            if context!.hasChanges {
				do {
					try context?.save()
				}
				catch {
					saveError = error
				}
				
            }
            
			context = context?.parent
        }
        
        return saveError
    }
}
