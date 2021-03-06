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
	
	var observings: [Any] = []
	override func viewDidLoad()
	{
		super.viewDidLoad()

		paraparaView.images = (0..<5)
			.map { NSImage(named: "cat\($0)")! }
		
		observings += [
			bindParaparaView(\.speed, to: \.speed),
			bindParaparaView(\.animationMethod, to: \.animationMethod),
			bindParaparaView(\.usesDiscreteAnimation, to: \.usesDiscreteAnimation)
		]
	}
	
	//MARK: - Bindable Properties
	
	@objc dynamic var speed: CGFloat = 1.0
	
	@objc class var keyPathsForValuesAffectingIsSpeedDefault: Set<String> { [#keyPath(speed)] }
	@objc dynamic var isSpeedDefault: Bool { (speed == 1.0) }
	
	@objc public var usesDiscreteAnimation = true
	
	@objc dynamic var animationMethod = 0
	
	//MARK: - Actions
	
	@IBAction func resetSpeed(_ sender: Any?)
	{
		speed = 1.0
	}
	
	//MARK: - Parapara View Binding
	
	func bindParaparaView<Value>(_ paraparaKeyPath: WritableKeyPath<ParaparaView, Value>, to keyPath: KeyPath<ViewController, Value>) -> Any
	{
		return observe(keyPath) { [weak self] observing, change in
			guard let self = self else { return }
			
			self.paraparaView[keyPath: paraparaKeyPath] = self[keyPath: keyPath]
		}
	}
	func bindParaparaView<Value, RawValue>(_ paraparaKeyPath: WritableKeyPath<ParaparaView, Value>, to keyPath: KeyPath<ViewController, RawValue>) -> Any where Value: RawRepresentable, Value.RawValue == RawValue
	{
		return observe(keyPath) { [weak self] observing, change in
			guard
				let self = self,
				let wrappedValue = Value(rawValue: self[keyPath: keyPath])
				else { return }
			
			self.paraparaView[keyPath: paraparaKeyPath] = wrappedValue
		}
	}
}
