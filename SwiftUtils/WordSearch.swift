//
//  WordSearch.swift
//  Anagram Solver
//
//  Created by Mark Bailey on 09/02/2015.
//  Copyright (c) 2015 MPD Bailey Technology. All rights reserved.
//

import Foundation

public enum SearchType
{
    case crossword
    case anagram
    case twoWordAnagram
    case wildcard
    case wildcardAndCrossword
    case blanks
    case supergram
    case codeword
}

open class WordSearch
{
    open var findSubAnagrams = true
    open var findThreeWordAnagrams = true
    open var findCodewords = true
    open let wordList : WordList!
    fileprivate lazy var codewordSolver = CodewordSolver()
    fileprivate let usLocale = Locale(identifier: "en_US")

    open let MAX_WORD_LEN = 42
    static open let CROSSWORD_STR = "."
    static open let TWO_WORD_STR = " "
    static open let WILDCARD_STR = "@"
    static open let BLANK_STR = "+"
    static open let SUPERGRAM_STR = "*"

    fileprivate let CROSSWORD_CHAR_VALUE = UnicodeScalar(".").value
    fileprivate let TWO_WORD_CHAR_VALUE = UnicodeScalar(" ").value
    fileprivate let WILDCARD_CHAR_VALUE = UnicodeScalar("@").value
    fileprivate let BLANK_CHAR_VALUE = UnicodeScalar("+").value
    fileprivate let SUPERGRAM_VALUE = UnicodeScalar("*").value
    fileprivate let CODEWORD_CHAR = UnicodeScalar("1")
    fileprivate let LOWEST_CHAR_VALUE = UnicodeScalar("a").value
    fileprivate let HIGHEST_CHAR_VALUE = UnicodeScalar("z").value

    fileprivate let LOWEST_ASCII_VALUE = UnicodeScalar(" ").value
    fileprivate let HIGHEST_ASCII_VALUE = UnicodeScalar("z").value

    public class func getGoogleUrl(word : String)->String{
        return "https://www.google.com/search?q=dictionary:\(word)"
    }
    public class func getMerriamWebsterUrl(word : String)->String{
        return "https://www.merriam-webster.com/dictionary/\(word)"
    }
    public class func getThesaurusUrl(word : String)->String{
        return "https://www.merriam-webster.com/thesaurus/\(word)"
    }
    public class func getCollinsUrl(word : String)->String{
        return "https://www.collinsdictionary.com/dictionary/english/\(word)"
    }
    public class func getOxfordDictionariesUrl(word : String)->String{
        return "https://en.oxforddictionaries.com/definition/\(word)"
    }
    public class func getAmericanHeritageUrl(word : String)->String{
        return "https://www.ahdictionary.com/word/search.html?q=\(word)"
    }
    public class func getWikipediaUrl(word : String)->String{
        return "https://en.wikipedia.org/wiki/\(word)"
    }
    public class func getWordGameDictionaryUrl(word : String)->String{
        return "https://www.wordgamedictionary.com/dictionary/word/\(word)"
    }

    public init(wordList: WordList)
    {
        self.wordList = wordList
    }
    
    /*
        Remove non-ascii chars
        Chop down to max length
        Trim whitespace
        Lowercase
    */
    open func clean(_ raw: String)->String
    {
        if raw.length==0
        {
            return ""
        }
        var builder =  ""
        let chars = raw
            .trimmingCharacters(in: CharacterSet.whitespaces)
            .unicodeScalars
        for c in chars
        {
            let v = c.value
            if v>=LOWEST_ASCII_VALUE && v<=HIGHEST_ASCII_VALUE
            {
                builder.append(String(c))
            }
            if builder.length > MAX_WORD_LEN
            {
                break
            }
        }
        builder = builder.trimmingCharacters(in: CharacterSet.whitespaces)
        
        return builder.lowercased()
    }
  
    open func preProcessQuery(_ query: String)->String
    {
        var processedQuery : String
        if isCodeword(query: query){
            processedQuery = query
                .lowercased(with: usLocale)
                .replace("?", withString: ".")
        } else {
            processedQuery = query
                .lowercased(with: usLocale)
                .replace("?", withString: ".")
                .replace("1", withString: ".")
                .replace("2", withString: "..")
                .replace("3", withString: "...")
                .replace("4", withString: "....")
                .replace("5", withString: ".....")
                .replace("6", withString: "......")
                .replace("7", withString: ".......")
                .replace("8", withString: "........")
                .replace("9", withString: ".........")
        }
        if processedQuery.length > MAX_WORD_LEN
        {
            processedQuery = processedQuery[0..<MAX_WORD_LEN]
        }
        
        return processedQuery
    }
    
    open func getQueryType(_ query: String) ->SearchType
    {
        if query.mpdb_contains(WordSearch.WILDCARD_STR) && query.mpdb_contains(WordSearch.CROSSWORD_STR)
        {
            return SearchType.wildcardAndCrossword
        }
        else if query.mpdb_contains(WordSearch.WILDCARD_STR)
        {
            return SearchType.wildcard
        }
        else if isCodeword(query: query)
        {
            return SearchType.codeword
        }
        else if query.mpdb_contains(WordSearch.CROSSWORD_STR)
        {
            return SearchType.crossword
        }
        else if query.mpdb_contains(WordSearch.TWO_WORD_STR)
        {
            return SearchType.twoWordAnagram
        }
        else if query.mpdb_contains(WordSearch.BLANK_STR)
        {
            return SearchType.blanks
        }
        else if query.mpdb_contains(WordSearch.SUPERGRAM_STR)
        {
            return SearchType.supergram
        }
        return SearchType.anagram
    }

    open func postProcessQuery(_ query: String, type: SearchType)->String
    {
        var query = query
        switch type
        {
        case .anagram:
            //keep a-z but remove any other char
            query = stripChars(query)
        case .crossword:
            //keep a-z and .
            query = stripChars(query, except1: CROSSWORD_CHAR_VALUE)
        case .blanks:
            //keep a-z and +
            query = stripChars(query, except1: BLANK_CHAR_VALUE)
        case .supergram:
            //keep a-z and *
            query = stripChars(query, except1: SUPERGRAM_VALUE)
        case .twoWordAnagram:
            //keep a-z and ' '
            query = stripChars(query, except1: TWO_WORD_CHAR_VALUE)
        case .wildcard:
            //keep a-z and @
            query = stripChars(query, except1: WILDCARD_CHAR_VALUE)
        case .wildcardAndCrossword:
            //keep a-z . @
            query = stripChars(query, except1: CROSSWORD_CHAR_VALUE, except2: WILDCARD_CHAR_VALUE)
        case .codeword:
            query = stripCharsForCodeword(query)
        }
        return query
    }
    fileprivate func stripChars(_ s: String, except1: UInt32 = 0, except2: UInt32 = 0)->String
    {
        var builder =  ""
        let chars = s.unicodeScalars
        for c in chars
        {
            let v = c.value
            if (v>=LOWEST_CHAR_VALUE && v<=HIGHEST_CHAR_VALUE) || v == except1 || v == except2
            {
                builder.append(String(c))
            }
        }
        return builder
    }
    fileprivate func stripCharsForCodeword(_ s: String) -> String
    {
        //Codewords can use numbers 1 to 7 to represent letters
        let CHAR_1 = UnicodeScalar("1").value
        let CHAR_7 = UnicodeScalar("7").value
        var builder =  ""
        let chars = s.unicodeScalars
        for c in chars
        {
            let v = c.value
            if (v>=LOWEST_CHAR_VALUE && v<=HIGHEST_CHAR_VALUE) || (v>=CHAR_1 && v<=CHAR_7) || v == CROSSWORD_CHAR_VALUE
            {
                builder.append(String(c))
            }
        }
        return builder
    }
    open func runQuery(_ query: String, type: SearchType, callback: WordListCallback)
    {
        let len = query.length
        //an empty query will return a match, as an empty string is in the word list
        if len == 0 {
            return
        }
        self.wordList.reset()
        switch type
        {
        case .anagram:
            self.wordList.findAnagrams(query, callback: callback)
            if self.findSubAnagrams && len<=self.MAX_WORD_LEN
            {
                //don't show the same word twice
                let filterWrapper = WordListFilterWrapper(callback: callback)
                self.wordList.findSubAnagrams(query, callback: filterWrapper)
            }
        case .crossword:
            self.wordList.findCrosswords(query, callback: callback)
        case .blanks:
            let queryRemovedSymbol = query.replace("+", withString: "")
            let numberOfBlanks = len - queryRemovedSymbol.length
            if self.findSubAnagrams {
                self.wordList.findAnagrams(queryRemovedSymbol, numberOfBlanks: numberOfBlanks, callback: callback)
            } else {
                self.wordList.findAnagramsExactLength(queryRemovedSymbol, numberOfBlanks: numberOfBlanks, callback: callback)
            }
        case .supergram:
            let queryRemovedSymbol = query.replace("*", withString: "")
            self.wordList.findSupergrams(queryRemovedSymbol, callback: callback, length: 0)
        case .twoWordAnagram:
            let words = query.split(separator: " ")
            if self.findThreeWordAnagrams && words.count > 2 {
                self.wordList.findMultiwordAnagrams(String(words[0]), String(words[1]), String(words[2]), callback: callback)
            } else if words.count >= 2 {
                self.wordList.findMultiwordAnagrams(String(words[0]+words[1]), startLen: words[0].count, callback: callback)
            }
        case .wildcard, .wildcardAndCrossword:
            self.wordList.findWildcards(query, callback: callback)
        case .codeword:
            self.codewordSolver.parse(query: query)
            self.wordList.findCodewords(codewordSolver: codewordSolver, callback: callback)
        }
    }
    
    fileprivate func isCodeword(query : String) -> Bool {
        return findCodewords && query.unicodeScalars.filter({$0==CODEWORD_CHAR}).count>1
    }
    
}
