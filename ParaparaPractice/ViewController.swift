//
//  ViewController.swift
//  ParaparaPractice
//
//  Created by zumuya on 2020/07/08.
//  Copyright © 2020 zumuya. All rights reserved.
//

import Cocoa

class ViewController: NSViewController
{
	@IBOutlet var paraparaView: ParaparaView!

	override func viewDidLoad()
	{
		super.viewDidLoad()

		paraparaView.images = (0..<5)
			.map { NSImage(named: "cat\($0)")! }
			.reversed()
		
		paraparaView.bind(.init(#keyPath(ParaparaView.speed)), to: self, withKeyPath: #keyPath(speed), options: nil)
	}
	deinit
	{
		paraparaView.unbind(.init(#keyPath(ParaparaView.speed)))
	}
	
	//MARK: - Speed
	
	@objc dynamic var speed: CGFloat = 1.0
	
	@objc class var keyPathsForValuesAffectingIsSpeedDefault: Set<String> { [
		#keyPath(speed)
	] }
	@objc dynamic var isSpeedDefault: Bool { (speed == 1.0) }
	
	//MARK: - Actions
	
	@IBAction func resetSpeed(_ sender: Any?)
	{
		speed = 1.0
	}
}
