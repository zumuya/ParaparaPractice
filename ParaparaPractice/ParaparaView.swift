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
	
	//MARK: - Discrete Animation
	
	public var usesDiscreteAnimation = true
	{
		didSet { needsDisplay = true }
	}
	
	//MARK: - Animation Method
	
	public enum AnimationMethod: Int, CaseIterable
	{
		case images
		case sprite
		
		var animatedKeyPath: String
		{
			switch self {
			case .images:
				return "contents"
			case .sprite:
				return "contentsRect.origin.y"
			}
		}
	}
	public var animationMethod = AnimationMethod.images
	{
		didSet { needsDisplay = true }
	}
	
	//MARK: - Drawing
	
	override var isFlipped: Bool { true }
	override var wantsUpdateLayer: Bool { true }
	
	override func updateLayer()
	{
		guard
			let firstImage = images.first,
			let layer = layer
			else { return }
		
		layer.contents = nil
		layer.contentsRect = .init(x: 0, y: 0, width: 1, height: 1)
		
		let viewHeight = max(1.0, bounds.height)
		let scaleFactor = window?.backingScaleFactor ?? 1.0
		
		var singleImageSize_pt = firstImage.size
		singleImageSize_pt.width = round(viewHeight * (singleImageSize_pt.width / singleImageSize_pt.height))
		singleImageSize_pt.height = viewHeight
		
		let animation = CAKeyframeAnimation(keyPath: animationMethod.animatedKeyPath); do {
			animation.repeatCount = .infinity
			animation.duration = 0.5
			animation.timingFunction = .init(name: .linear)
			animation.keyTimes = (0..<images.count)
				.map { TimeInterval($0) / .init(images.count - 1) }
				.map { (pow($0, 1.1)) as NSNumber }
			
			animation.calculationMode = (usesDiscreteAnimation ? .discrete : .linear)
		}
		
		switch animationMethod {
		case .images:
			
			animation.values = images
				.map { image in
					NSImage(size: singleImageSize_pt, flipped: true) { _ in
						image.draw(in: NSRect(origin: .zero, size: singleImageSize_pt))
						return true
					}.layerContents(forContentsScale: scaleFactor)
				}
			
		case .sprite:
			let spriteImage = NSImage(size: singleImageSize_pt.applying(.init(scaleX: 1.0, y: .init(images.count))), flipped: true) { _ in
				for indexedImage in self.images.enumerated() {
					var rect = NSRect(origin: .zero, size: singleImageSize_pt)
					rect.origin.y += (singleImageSize_pt.height * .init(indexedImage.offset))
					
					indexedImage.element.draw(in: rect)
				}
				return true
			}
			
			layer.contents = spriteImage.layerContents(forContentsScale: scaleFactor)
			layer.contentsRect = CGRect(origin: .zero, size: .init(width: 1.0, height: (1.0 / .init(images.count))))
			
			animation.values = (0..<images.count)
				.map { CGFloat($0) / .init(images.count) }
		}
		
		layer.add(animation, forKey: "parapara")
	}
}
