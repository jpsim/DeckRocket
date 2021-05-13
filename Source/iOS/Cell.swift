//
//  Cell.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit
import Cartography

private var gNotesHidden = true

private let gDefaultNotesFont = UIFont.systemFont(ofSize: 30)

final class Cell: UICollectionViewCell {

    // MARK: Properties

    var notesHidden: Bool {
        get {
            return gNotesHidden
        }
        set {
            gNotesHidden = newValue
            resetHidden()
        }
    }
    let imageView = UIImageView()
    let notesView = UITextView()
    let nextSlideView = UIImageView()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    // MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupNextSlideView()
        setupNotesView()
        resetHidden()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleNotes)))
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init(frame: .zero)
    }

    // MARK: UI

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.addSubview(effectView)

        constrain(imageView, effectView, contentView) {
            $0.edges == $2.edges
            $1.edges == $2.edges
        }
    }

    private func setupNotesView() {
        notesView.font = gDefaultNotesFont
        notesView.backgroundColor = .clear
        notesView.textColor = .white
        notesView.isUserInteractionEnabled = false
        contentView.addSubview(notesView)

        constrain(notesView, contentView) {
            $0.left == $1.left
            $0.right == $1.right
            $0.bottom == $1.bottom
            $0.top == $1.top + 20
        }
    }

    private func setupNextSlideView() {
        nextSlideView.contentMode = .scaleAspectFit
        nextSlideView.isUserInteractionEnabled = false
        contentView.addSubview(nextSlideView)

        constrain(nextSlideView, contentView) {
            $0.width  == $0.height * 16/9
            $0.height <= $1.height / 2
            $0.left   >= $1.left   + 10
            $0.right  == $1.right  - 10
            $0.bottom == $1.bottom - 10
        }
    }

    // MARK: Actions

    private func resetHidden() {
        effectView.isHidden = notesHidden
        notesView.isHidden = notesHidden
        nextSlideView.isHidden = notesHidden
    }

    @objc func toggleNotes(sender: UITapGestureRecognizer) {
        notesHidden = !notesHidden
    }

    // MARK: Overrides

    override func prepareForReuse() {
        super.prepareForReuse()
        resetHidden()
        notesView.font = gDefaultNotesFont
    }
}
