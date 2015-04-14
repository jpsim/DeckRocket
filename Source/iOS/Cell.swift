//
//  Cell.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit

var gNotesHidden = true

final class Cell: UICollectionViewCell {
    var notesHidden: Bool {
        get {
            return gNotesHidden
        }
        set {
            gNotesHidden = newValue
            self.resetHidden()
        }
    }
    let imageView = UIImageView()
    let notesView = UITextView()
    let nextSlideView = UIImageView()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupNextSlideView()
        setupNotesView()
        resetHidden()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toggleNotes:"))
    }

    func resetHidden() {
        effectView.hidden = notesHidden
        notesView.hidden = notesHidden
        nextSlideView.hidden = notesHidden
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetHidden()
    }

    func toggleNotes(sender: UITapGestureRecognizer) {
        notesHidden = !notesHidden
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    private func setupImageView() {
        imageView.contentMode = .ScaleAspectFit
        contentView.addSubview(imageView)

        effectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        imageView.addSubview(effectView)

        let horizontal2 = NSLayoutConstraint.constraintsWithVisualFormat("|[effectView]|", options: nil, metrics: nil, views: ["effectView": effectView])
        let vertical2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[effectView]|", options: nil, metrics: nil, views: ["effectView": effectView])
        imageView.addConstraints(horizontal2)
        imageView.addConstraints(vertical2)
    }

    private func setupNotesView() {
        notesView.setTranslatesAutoresizingMaskIntoConstraints(false)
        notesView.font = UIFont.systemFontOfSize(30)
        notesView.backgroundColor = UIColor.clearColor()
        notesView.textColor = UIColor.whiteColor()
        notesView.userInteractionEnabled = false
        contentView.addSubview(notesView)

        let horizontal = NSLayoutConstraint.constraintsWithVisualFormat("|[notesView]|", options: nil, metrics: nil, views: ["notesView": notesView])
        let vertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[notesView]|", options: nil, metrics: nil, views: ["notesView": notesView])
        addConstraints(horizontal)
        addConstraints(vertical)
    }

    private func setupNextSlideView() {
        nextSlideView.setTranslatesAutoresizingMaskIntoConstraints(false)
        nextSlideView.contentMode = .ScaleAspectFit
        nextSlideView.userInteractionEnabled = false
        contentView.addSubview(nextSlideView)

        // Constraints
        let ratio = NSLayoutConstraint(item: nextSlideView,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nextSlideView,
            attribute: .Height,
            multiplier: 16/9,
            constant: 0)
        let height = NSLayoutConstraint(item: nextSlideView,
            attribute: .Height,
            relatedBy: .LessThanOrEqual,
            toItem: self,
            attribute: .Height,
            multiplier: 0.5,
            constant: 0)
        let left = NSLayoutConstraint(item: nextSlideView,
            attribute: .Left,
            relatedBy: .GreaterThanOrEqual,
            toItem: self,
            attribute: .Left,
            multiplier: 1,
            constant: 10)
        let right = NSLayoutConstraint(item: nextSlideView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Right,
            multiplier: 1,
            constant: -10)
        let bottom = NSLayoutConstraint(item: nextSlideView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Bottom,
            multiplier: 1,
            constant: -10)
        addConstraints([ratio, height, left, right, bottom])
    }
}
