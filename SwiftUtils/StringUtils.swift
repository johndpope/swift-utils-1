//
//  StringUtils.swift
//  Anagram Solver
//
//  Created by Mark Bailey on 09/02/2015.
//  Copyright (c) 2015 MPD Bailey Technology. All rights reserved.
//

import Foundation

public extension String
{
    
    public func replace(_ target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    //return the string in specified range
    public subscript (r: Range<Int>) -> String
    {
        let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        return String(self[startIndex ..< endIndex])
    }
    
    public func mpdb_contains(_ s : String) -> Bool
    {
        return self.range(of: s) != nil
    }
    
    var length : Int{
        return self.utf8.count
    }
    /*
        Returns all the words that are one letter less, 
        eg ABCD returns
        BCD, ACD, ABD, ABC
    */
    public func getSubWords() ->[String]
    {
        //sort letter into a Array[Character]
        let sortedLetters = self.sorted(by: <)
        let len = self.count
        var subwords = [String]()
        for i in 0  ..< len
        {
            //string builder to make the sub word
            var builder = ""
            //copy the sortedLetters string but
            //skip the letter at index i
            for j in 0  ..< len
            {
                if (i != j)
                {
                    builder.append(sortedLetters[j])
                }
            }
            //don't add words already found
            if !subwords.contains(builder)
            {
                subwords.append(builder)
            }
        }
        return subwords
    }
    /*
        Recursively find subwords
    
        If the string is 9 letters and min length is 6, will generate
        9 eight letter words
        9*8 seven letter words
        9*8*7 six letter words
    */
    public func getSubWords(_ minLength: Int) -> [String]
    {
        var aggregate = [String]()
        let len = self.length
        if len>minLength
        {
            let parentList = self.getSubWords()
            aggregate.append(contentsOf: parentList)
            for subword in parentList
            {
                aggregate.append(contentsOf: subword.getSubWords(minLength))
            }
        }
        return aggregate
    }
    /*
        Subtracts the letters of word from the string
    */
    public func subtractLetters(_ word : String) ->String
    {
        var builder = self
        for delChar in word
        {
            if let index = builder.index(of: delChar) {
                builder.remove(at: index)
            }
        }
        return builder
    }

    public func doesNotContainBannedLetters(_ bannedLetters: CharacterSet) -> Bool
    {
        return self.rangeOfCharacter(from: bannedLetters) == nil
    }
   
}
