//
//  StickyFooterTableView.swift
//  StickyFooterTableView
//
//  Created by Michael Golubev on 27.02.2021.
//

import UIKit

class StickyFooterTableView: UITableView {

	override func layoutSubviews() {
		super.layoutSubviews()
		stickFooter()
	}
	
	override weak var delegate: UITableViewDelegate? {
		set {
			privateDelegate = newValue
			super.delegate = self
		}
		get {
			privateDelegate
		}
	}
	
	override open func responds(to aSelector: Selector!) -> Bool {
		let respondesToSelector = super.responds(to: aSelector) ||  privateDelegate?.responds(to: aSelector) == true
		return respondesToSelector
	}

	override open func forwardingTarget(for aSelector: Selector!) -> Any? {
		if privateDelegate?.responds(to: aSelector) == true {
			return privateDelegate
		}
		else {
			return super.forwardingTarget(for: aSelector)
		}
	}
	
	private func stickFooter() {
		if let footer = tableFooterView {
			stickyFooter = footer
			tableFooterView = nil
		}
		guard let stickView = stickyFooter, let superview = superview else { return }
		
		guard stickView.superview != superview else {
			updateStickViewPosition(for: self)
			return
		}
		stickView.translatesAutoresizingMaskIntoConstraints = false
		superview.insertSubview(stickView, aboveSubview: self)
		stickView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		stickView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		bottomConstraint = bottomAnchor.constraint(equalTo: stickView.bottomAnchor, constant: adjustedContentInset.bottom)
		bottomConstraint?.isActive = true
		stickView.layoutIfNeeded()
		var inset = contentInset
		inset.bottom = stickView.bounds.height
		contentInset = inset
		updateStickViewPosition(for: self)
	}

	private func updateStickViewPosition(for scrollView: UIScrollView) {
		let value = scrollView.frame.height - (scrollView.contentInset.top + scrollView.contentSize.height - scrollView.contentOffset.y + (stickyFooter?.frame.height ?? 0))
		let inset = scrollView.adjustedContentInset.bottom - scrollView.contentInset.bottom
		if value < inset {
			bottomConstraint?.constant = value
		}
		else {
			bottomConstraint?.constant = inset
		}
	}

	private var stickyFooter: UIView?
	private var bottomConstraint: NSLayoutConstraint?
	private weak var privateDelegate: UITableViewDelegate?
}

extension StickyFooterTableView: UITableViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateStickViewPosition(for: scrollView)
		privateDelegate?.scrollViewDidScroll?(scrollView)
	}
}
