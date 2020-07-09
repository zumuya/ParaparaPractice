//
//  ParaparaView.swift
//  ParaparaPractice
//
//  Created by zumuya on 2020/07/08.
//  Copyright © 2020 zumuya. All rights reserved.
//

import Cocoa

class ParaparaView: NSView
{
	override init(frame: NSRect)
	{
		super.init(frame: frame)
		_commonInit()
	}
	required init?(coder: NSCoder)
	{
		super.init(coder: coder)
		_commonInit()
	}
	
	func _commonInit()
	{
		layerContentsRedrawPolicy = .beforeViewResize
		layerContentsPlacement = .center
		wantsLayer = true
		
		layer?.minificationFilter = .nearest
		layer?.magnificationFilter = .nearest
	}
	
	//MARK: - Images
	
	var images: [NSImage] = []
	{
		didSet {
			needsDisplay = true
		}
	}
	
	//MARK: - Speed
	
	@objc dynamic var speed: CGFloat = 1.0
	{
		didSet { updateLayerSpeed() }
	}
	func updateLayerSpeed()
	{
		guard let layer = layer else { return }
		
		let time = CACurrentMediaTime()
		layer.timeOffset = layer.convertTime(time, from: nil)
		layer.beginTime = time
		layer.speed = .init(speed)
	}
	
	//MARK: - Drawing
	
	override var wantsUpdateLayer: Bool { true }
	
	override func updateLayer()
	{
		let viewHeight = max(1.0, bounds.height)
		let scaleFactor = window?.backingScaleFactor ?? 1.0
		
		guard
			let firstImage = images.first,
			let layer = layer
			else { return }
		
		var singleImageSize_pt = firstImage.size
		singleImageSize_pt.width = round(viewHeight * (singleImageSize_pt.width / singleImageSize_pt.height))
		singleImageSize_pt.height = viewHeight
		
		let spriteImage = NSImage(size: .init(width: singleImageSize_pt.width, height: (singleImageSize_pt.height * .init(images.count))), flipped: true) { dirtyRect in
			for indexedImage in self.images.enumerated() {
				var rect = NSRect(origin: .zero, size: singleImageSize_pt)
				rect.origin.y += (singleImageSize_pt.height * .init(indexedImage.offset))
				
				indexedImage.element.draw(in: rect)
			}
			return true
		}
		
		layer.contents = spriteImage.layerContents(forContentsScale: scaleFactor)
		layer.contentsRect = CGRect(origin: .zero, size: .init(width: 1.0, height: (1.0 / .init(images.count))))
		
		let animation = CAKeyframeAnimation(keyPath: "contentsRect.origin.y"); do {
			animation.values = (0..<images.count)
				.map { CGFloat($0) / .init(images.count) }
			
			animation.keyTimes = (0..<images.count)
				.map { TimeInterval($0) / .init(images.count - 1) }
				.map { (pow($0, 1.1)) as NSNumber }
			
			animation.repeatCount = .infinity
			animation.calculationMode = .discrete /// <- fun to comment out this line ;)
			animation.duration = 0.5
			animation.timingFunction = .init(name: .linear)
		}
		layer.add(animation, forKey: "parapara")
	}
}
