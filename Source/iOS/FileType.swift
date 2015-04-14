//
//  FileType.swift
//  DeckRocket
//
//  Created by JP Simard on 6/15/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation

enum FileType {
    case PDF, Markdown

    init?(fileExtension: String) {
        let ext = fileExtension.lowercaseString
        if contains(FileType.extensionsForType(PDF), ext) {
            self = PDF
            return
        } else if contains(FileType.extensionsForType(Markdown), ext) {
            self = Markdown
            return
        }
        return nil
    }

    static func extensionsForType(fileType: FileType) -> [String] {
        switch fileType {
            case PDF:
                return ["pdf"]
            case Markdown:
                return ["markdown", "mdown", "mkdn", "md", "mkd", "mdwn", "mdtxt", "mdtext", "text"]
        }
    }
}
