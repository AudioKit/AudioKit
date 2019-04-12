//
//  KeyboardListener.swift
//  DropDown
//
//  Created by Kevin Hirsch, revision history on Githbub.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

internal final class KeyboardListener {

	static let sharedInstance = KeyboardListener()

	fileprivate(set) var isVisible = false
	fileprivate(set) var keyboardFrame = CGRect.zero
	fileprivate var isListening = false

	deinit {
		stopListeningToKeyboard()
	}

}

// MARK: - Notifications

extension KeyboardListener {

	func startListeningToKeyboard() {
		if isListening {
			return
		}

		isListening = true

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow(_:)),
			name: UIResponder.keyboardWillShowNotification,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide(_:)),
			name: UIResponder.keyboardWillHideNotification,
			object: nil)
	}

	func stopListeningToKeyboard() {
		NotificationCenter.default.removeObserver(self)
	}

	@objc
	fileprivate func keyboardWillShow(_ notification: Notification) {
		isVisible = true
		keyboardFrame = keyboardFrame(fromNotification: notification)
	}

	@objc
	fileprivate func keyboardWillHide(_ notification: Notification) {
		isVisible = false
		keyboardFrame = keyboardFrame(fromNotification: notification)
	}

	fileprivate func keyboardFrame(fromNotification notification: Notification) -> CGRect {
		return ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
	}

}
