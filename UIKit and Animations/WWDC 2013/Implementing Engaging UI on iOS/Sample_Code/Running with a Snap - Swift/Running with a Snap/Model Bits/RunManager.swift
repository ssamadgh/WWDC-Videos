//
//  RunManager.swift
//  Running with a Snap
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class RunManager: NSObject {

	var runs: [Run]!
	
	var numberOfRuns: Int {
		let count = self.runs?.count
		return count ?? 0
	}
	
	static var rootDataPath: URL = {
		let fileManager = FileManager.default
		let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
		let rootPath = path.appendingPathComponent("data")
		
		if !fileManager.fileExists(atPath: rootPath.appendingPathComponent("runs").path) {
			try! fileManager.createDirectory(at: rootPath, withIntermediateDirectories: true, attributes: nil)
			try! fileManager.createDirectory(at: rootPath.appendingPathComponent("runs"), withIntermediateDirectories: true, attributes: nil)
			try! fileManager.createDirectory(at: rootPath.appendingPathComponent("photos"), withIntermediateDirectories: true, attributes: nil)
			try! fileManager.createDirectory(at: rootPath.appendingPathComponent("interface"), withIntermediateDirectories: true, attributes: nil)
		}
		
		return rootPath
	}()
	
	static func save(_ run: Run) {
		let runPath = self.rootDataPath.appendingPathComponent("/runs/\(run.identifier)")
		let runData = NSKeyedArchiver.archivedData(withRootObject: run)
		try! runData.write(to: runPath)
	}
	
	static var photoSavePath: URL {
		return RunManager.rootDataPath.appendingPathComponent("photos")
	}
	
	override init() {
		super.init()
		
		let fileManager = FileManager()
		let runPath = RunManager.rootDataPath.appendingPathComponent("runs")
		let savedRuns = try! fileManager.contentsOfDirectory(atPath: runPath.path)
		var runs: [Run] = []
		for runIdentifier in savedRuns {
			if let runData = try? Data(contentsOf: runPath.appendingPathComponent(runIdentifier)) {
				let run = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(runData) as! Run
				runs.append(run)
			}
		}
		self.runs = runs
	}
	
	func run(at index: Int) -> Run {
		return self.runs[index]
	}
}
