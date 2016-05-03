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
    
    public func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    //return the string in specified range
    public subscript (r: Range<Int>) -> String
    {
        let startIndex = self.startIndex.advancedBy(r.startIndex)
        let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
        return self[startIndex ..< endIndex]
    }
    
    public func mpdb_contains(s : String) -> Bool
    {
        return self.rangeOfString(s) != nil
    }
    
    var length : Int{
        return self.utf16.count
    }
    /*
        Returns all the words that are one letter less, 
        eg ABCD returns
        BCD, ACD, ABD, ABC
    */
    public func getSubWords() ->[String]
    {
        //sort letter into a Array[Character]
        let sortedLetters = self.characters.sort(<)
        let len = characters.count
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
    public func getSubWords(minLength: Int) -> [String]
    {
        var aggregate = [String]()
        let len = self.length
        if len>minLength
        {
            let parentList = self.getSubWords()
            aggregate.appendContentsOf(parentList)
            for subword in parentList
            {
                aggregate.appendContentsOf(subword.getSubWords(minLength))
            }
        }
        return aggregate
    }
    /*
        Subtracts the letters of word from the string
    */
    public func subtractLetters(word : String) ->String
    {
        var builder = Array(self.characters)
        for delChar in word.characters
        {
            let len = builder.count
            for i in 0 ..< len
            {
                if delChar == builder[i]
                {
                    builder.removeAtIndex(i)
                    break;
                }
            }
        }
        return String(builder)
    }
    
    public func doesNotContainBannedLetters(bannedLetters: [Character]) -> Bool
    {
        let chars = Array(self.characters)
        for c in bannedLetters
        {
            if chars.contains(c)
            {
                return false
            }
        }
        return true
        
    }
    
}