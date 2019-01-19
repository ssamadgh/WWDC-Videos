//
//  ParseOperation.swift
//  LazyTable
//
//  Created by Seyed Samad Gholamzadeh on 6/26/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

//Abstract: NSOperation code for parsing the RSS feed.

import Foundation

typealias ArrayBlock = (([AppRecord]) -> ())
typealias ErrorBlock = ((Error) -> ())

// string contants found in the RSS feed

class ParseOperation: Operation, XMLParserDelegate {
	
	// string contants found in the RSS feed
	let kIDStr     = "id";
	let kNameStr   = "im:name";
	let kImageStr  = "im:image";
	let kArtistStr = "im:artist";
	let kEntryStr  = "entry";

	
	var completionHandler: ArrayBlock?
	var errorHandler: ErrorBlock?

	var dataToParse: Data!
	
	var workingArray: [AppRecord]!
	
	var workingEntry: AppRecord!
	
	var workingPropertyString: String!
	
	var elementsToParse: [String]!
	
	var storingCharacterData: Bool!
	
	init(data: Data, completionHandler handler: @escaping ArrayBlock) {
		super.init()
		
		self.dataToParse = data;
		self.completionHandler = handler
		self.elementsToParse = [kIDStr, kNameStr, kImageStr, kArtistStr]
	}
	
	// -------------------------------------------------------------------------------
	//	main:
	//  Given data to parse, use NSXMLParser and process all the top paid apps.
	// -------------------------------------------------------------------------------
	override func main() {
		
		autoreleasepool {
			self.workingArray = []
			self.workingPropertyString = ""
			
			// It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not
			// desirable because it gives less control over the network, particularly in responding to
			// connection errors.
			//
			let parser = XMLParser(data: dataToParse)
			parser.delegate = self
			parser.parse()
			
			if !self.isCancelled {
				// call our completion handler with the result of our parsing
				self.completionHandler?(self.workingArray)
			}
			
			self.workingArray = nil
			self.workingPropertyString = nil
			self.dataToParse = nil
		}

	}
	
	//MARK: - RSS processing
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		
		// entry: { id (link), im:name (app name), im:image (variable height) }
		//
		if elementName == kEntryStr {
			self.workingEntry = AppRecord()
		}
		storingCharacterData = self.elementsToParse.contains(elementName)
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if self.workingEntry != nil {
			if storingCharacterData {
				let trimmedString = workingPropertyString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
				workingPropertyString = ""   // clear the string for next time
				if elementName == kIDStr {
					self.workingEntry.appURLString = trimmedString
				}
				else if elementName == kNameStr {
					self.workingEntry.appName = trimmedString
				}
				else if elementName == kImageStr {
					self.workingEntry.imageURLString = trimmedString
				}
				else if elementName == kArtistStr {
					self.workingEntry.artist = trimmedString
				}
			}
			else if elementName == kEntryStr {
				self.workingArray.append(self.workingEntry)
				self.workingEntry = nil
			}
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		
		if storingCharacterData {
			workingPropertyString! += string
		}
	}
	
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		self.errorHandler?(parseError)
	}
}
