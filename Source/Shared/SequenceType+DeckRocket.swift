//
//  SequenceType+DeckRocket.swift
//  DeckRocket
//
//  Created by JP Simard on 4/9/15.
//  Copyright (c) 2015 JP Simard. All rights reserved.
//

/**
Returns an array of the non-nil elements of the input sequence.

- parameter sequence: Sequence to compact.

- returns: An array of the non-nil elements of the input sequence.
*/
public func compact<T, S: SequenceType where S.Generator.Element == Optional<T>>(sequence: S) -> [T] {
    return sequence.filter({
        $0 != nil
    }).map {
        $0! // Safe to force unwrap
    }
}
