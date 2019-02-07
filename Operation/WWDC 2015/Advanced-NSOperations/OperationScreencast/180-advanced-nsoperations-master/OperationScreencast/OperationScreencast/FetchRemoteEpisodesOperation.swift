//
//  FetchRemoteEpisodesOperation.swift
//  OperationScreencast
//
//  Created by Ben Scheirman on 7/21/15.
//  Copyright (c) 2015 NSScreencast. All rights reserved.
//

import Foundation

class FetchRemoteEpisodesOperation : ASOperation {
    var path: String
    var error: Error?
    var task: URLSessionDownloadTask?
    
    lazy var session: URLSession = {
        return URLSession.shared
    }()
    
    var episodesApiURL: URL {
        return URL(string: "https://www.nsscreencast.com/api/episodes.json")!
    }
    
    init(path: String) {
        self.path = path
    }
    
    override func execute() {
		task = session.downloadTask(with: episodesApiURL, completionHandler: { (url, response, error) in
            
            if error == nil {
                let http = response as! HTTPURLResponse
                if http.statusCode != 200 {
                    print("Received HTTP \(http.statusCode)")
                    self.error = NSError(domain: "OperationScreencastErrorDomain", code: 0, userInfo: ["response": http])
                } else {

					let destinationURL = URL(fileURLWithPath: self.path)
	
					do {
						try FileManager.default.moveItem(at: url!, to: destinationURL)
						let attributes = try FileManager.default.attributesOfItem(atPath: self.path)
						let bytes = attributes[FileAttributeKey.size] as! Int64
						let formattedSize = ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
						print("Downloaded \(formattedSize)")

					} catch {
						
						print("Error moving file: \(error)")
						self.error = error
					}
					
                }
            } else {
                self.error = error!
            }
            
            self.finish()
        })
		
        task!.resume()
    }
}
