//
//  AKTuningTable.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 3/17/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

@objc open class AKTuningTable: NSObject {

    public typealias Frequency = Double

    private static let NYQUIST: Frequency = AKSettings.sampleRate / 2
    
    public static let midiNoteCount = 128
    
    public var middleCNoteNumber: MIDINoteNumber = 60 {
        didSet {
            updateTuningTable()
        }
    }
    
    public var middleCFrequency: Frequency = 261.0 {
        didSet {
            updateTuningTable()
        }
    }
    
    // Musically useful for instrument register
    // ..., -2, -1, 0, 1, 2, ...
    public var middleCOctave: Int = 0  {
        didSet {
            updateTuningTable()
        }
    }
    
    private var content = [Frequency](repeating: 1.0, count: midiNoteCount)
    private var frequencies = [Frequency]()
    
    // default is 12ET
    public override init() {
        super.init()
        twelveToneEqualTemperament()
    }
    
    // getter
    public func frequency(forNoteNumber noteNumber: MIDINoteNumber) -> Frequency {
        return content[Int(noteNumber)]
    }
    // setter
    public func setFrequency(_ frequency: Frequency, at noteNumber: MIDINoteNumber) {
        content[Int(noteNumber)] = frequency
    }
    
    // Default tuning table is 12ET.
    // Note this is [nearly] equivalent to 440.0*exp2((noteNumber - 69.0)/12.0))
    public func twelveToneEqualTemperament() {
        var equalTempermentFrequencies = [Frequency](repeatElement(1.0, count: 12))
        for i in 0 ... 11 {
            equalTempermentFrequencies[i] = Frequency(pow(2.0, Frequency(Frequency(i) / 12.0)))
        }
        tuningTable(fromFrequencies: equalTempermentFrequencies)
    }

    // create the tuning using the input frequencies
    public func tuningTable(fromFrequencies inputFrequencies: [Frequency]) {
        if inputFrequencies.isEmpty {
            AKLog("No input frequencies")
            return
        }
        
        // octave reduce
        let frequenciesOctaveReduce = inputFrequencies.map({(frequency: Frequency) -> Frequency in
            var l2 = log2(frequency)
            while l2 < 0 {
                l2 += 1
            }
            let m = fmod(l2, 1)
            return m
        })
        
        // sort
        let frequenciesOctaveReducedSorted = frequenciesOctaveReduce.sorted {$0 < $1}
        frequencies = frequenciesOctaveReducedSorted

        // optional uniquify.
        // provide epsilon for frequency equality comparison

        // update
        updateTuningTable()
    }
    
    // Assume frequencies are set and valid:  Process and update tuning table.
    private func updateTuningTable() {
        AKLog("Updating tuning table from frequencies: \(frequencies)")
        for i in 0 ..< AKTuningTable.midiNoteCount {
            let ff = Frequency(i - Int(middleCNoteNumber)) / Frequency(frequencies.count)
            var ttOctaveFactor = Frequency(trunc(ff))
            if ff < 0 {
                ttOctaveFactor -= 1
            }
            var frac = fabs(ttOctaveFactor - ff)
            if frac == 1 {
                frac = 0
                ttOctaveFactor += 1
            }
            let frequencyIndex = Int(round(frac * Frequency(frequencies.count)))
            let tone = Frequency(exp2(frequencies[frequencyIndex]))
            let lp2 = pow(2, ttOctaveFactor)
            var f = tone * lp2 * middleCFrequency
            
            f = (0...AKTuningTable.NYQUIST).clamp(f)
            
            content[i] = Frequency(f)
        }
    }

    // From Erv Wilson
    public func presetRecurrenceRelation01() {
        tuningTable(fromFrequencies: [1, 34, 5, 21, 3, 13, 55])
    }
    // From Erv Wilson
    public func presetHighlandBagPipes() {
        tuningTable(fromFrequencies: [32, 36, 39, 171, 48, 52, 57])
    }
    // From Erv Wilson
    public func presetPersianNorthIndianMadhubanti() {
        tuningTable(fromFrequencies: [1.0,
                                      9.0 / 8.0,
                                      1215.0 / 1024.0,
                                      45.0 / 32.0,
                                      3.0 / 2.0,
                                      27.0 / 16.0,
                                      15.0 / 8.0])
    }
    
    public func hexany(_ A:Frequency, _ B:Frequency, _ C:Frequency, _ D:Frequency) {
        tuningTable(fromFrequencies: [A*B, A*C, A*D, B*C, B*D, C*D])
    }
    
    
    // MARK: Scala file support
    public func scalaFile(_ filePath: String) {
        guard
            let contentData = FileManager.default.contents(atPath: filePath),
            let contentStr = String(data: contentData, encoding: .utf8) else {
                AKLog("can't read filePath: \(filePath)")
                return
        }
        
        if let scalaFrequencies = frequencies(fromScalaString: contentStr) {
            tuningTable(fromFrequencies: scalaFrequencies)
        }
    }

    fileprivate func stringTrimmedForLeadingAndTrailingWhiteSpacesFromString(_ inputString: String?) -> String? {
        guard let string = inputString else {return nil}
        
        let leadingTrailingWhiteSpacesPattern = "(?:^\\s+)|(?:\\s+$)"
        var regex: NSRegularExpression?
        
        do {
            try regex = NSRegularExpression.init(pattern: leadingTrailingWhiteSpacesPattern,
                                                 options: NSRegularExpression.Options.caseInsensitive)
        } catch let error as NSError {
            AKLog("ERROR: create regex: \(error)")
            return nil
        }
        
        let stringRange = NSMakeRange(0, string.characters.count)
        let trimmedString = regex?.stringByReplacingMatches(in: string,
                                                            options: NSRegularExpression.MatchingOptions.reportProgress,
                                                            range: stringRange,
                                                            withTemplate: "$1")
        
        return trimmedString
    }
    
    
    
    open func frequencies(fromScalaString rawStr: String?) -> [Frequency]? {
        guard let inputStr = rawStr else {return nil}
        
        // default return value is [1.0]
        var noteArray = [Frequency(1)]
        var actualNumberOfNotes = 1
        var numberOfNotes = 1
        
        var parsedScala = true
        var parsedFirstCommentLine = false
        let values = inputStr.components(separatedBy: NSCharacterSet.newlines)
        var parsedFirstNonCommentLine = false
        var parsedNumberOfNotes = false
        
        // REGEX match for a cents or ratio
        //              (RATIO      |CENTS                                  )
        //              (  a   /  b |-   a   .  b |-   .  b |-   a   .|-   a )
        let regexStr = "(\\d+\\/\\d+|-?\\d+\\.\\d+|-?\\.\\d+|-?\\d+\\.|-?\\d+)"
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression.init(pattern: regexStr,
                                                 options: NSRegularExpression.Options.caseInsensitive)
        } catch let error as NSError {
            AKLog("ERROR: cannot parse scala file: \(error)")
            return noteArray
        }
        
        for rawLineStr in values {
            var lineStr = stringTrimmedForLeadingAndTrailingWhiteSpacesFromString(rawLineStr) ?? rawLineStr
            
            if lineStr.characters.count == 0 { continue }
            
            if lineStr.hasPrefix("!") {
                if !parsedFirstCommentLine {
                    parsedFirstCommentLine = true
                    #if false
                        // currently not using the scala file name embedded in the file
                        let components = lineStr.components(separatedBy: "!")
                        if (components.count > 1) {
                            proposedScalaFilename = components[1]
                        }
                    #endif
                }
                continue
            }
            
            if !parsedFirstNonCommentLine {
                parsedFirstNonCommentLine = true
                #if false
                    // currently not using the scala short description embedded in the file
                    scalaShortDescription = lineStr
                #endif
                continue
            }
            
            if parsedFirstNonCommentLine && !parsedNumberOfNotes {
                if let newNumberOfNotes = Int(lineStr) {
                    numberOfNotes = newNumberOfNotes
                    if numberOfNotes == 0 || numberOfNotes > 127 {
                        //#warning SPEC SAYS 0 notes is okay because 1/1 is implicit
                        AKLog("ERROR: number of notes in scala file: \(numberOfNotes)")
                        parsedScala = false
                        break
                    }
                    else {
                        parsedNumberOfNotes = true
                        continue
                    }
                }
            }
            
            if actualNumberOfNotes > numberOfNotes {
                AKLog("actualNumberOfNotes: \(actualNumberOfNotes) > numberOfNotes: \(numberOfNotes)")
            }
            
            /* The first note of 1/1 or 0.0 cents is implicit and not in the files.*/
            
            // REGEX defined above this loop
            let rangeOfFirstMatch = regex?.rangeOfFirstMatch(in: lineStr,
                                                             options: NSRegularExpression.MatchingOptions.anchored,
                                                             range: NSMakeRange(0,lineStr.characters.count))
            var scaleDegree: Frequency = 0
            if !NSEqualRanges(rangeOfFirstMatch!, NSMakeRange(NSNotFound, 0)) {
                let nsLineStr = lineStr as NSString?
                let substringForFirstMatch = nsLineStr?.substring(with: rangeOfFirstMatch!) as NSString?
                if substringForFirstMatch?.range(of: ".").length != 0 {
                    scaleDegree = Frequency(lineStr)!
                    // ignore 0.0...same as 1.0, 2.0, etc.
                    if scaleDegree != 0 {
                        scaleDegree = fabs(scaleDegree)
                        // convert from cents to frequency
                        scaleDegree /= 1200
                        scaleDegree = pow(2, scaleDegree)
                        noteArray.append(scaleDegree)
                        actualNumberOfNotes += 1
                        continue
                    }
                }
                else {
                    if (substringForFirstMatch?.range(of: "/").length) != 0 {
                        if (substringForFirstMatch?.range(of: "-").length) != 0 {
                            AKLog("ERROR: invalid ratio: \(String(describing: substringForFirstMatch))")
                            parsedScala = false
                            break
                        }
                        // Parse rational numerator/denominator
                        let slashPos = substringForFirstMatch?.range(of: "/")
                        let numeratorStr = substringForFirstMatch?.substring(to: (slashPos?.location)!)
                        let numerator = Int(numeratorStr!)
                        let denominatorStr = substringForFirstMatch?.substring(from: (slashPos?.location)! + 1)
                        let denominator = Int(denominatorStr!)
                        if denominator == nil {
                            AKLog("ERROR: invalid ratio: \(String(describing: substringForFirstMatch))")
                            parsedScala = false
                            break
                        }
                        else {
                            let mt = Frequency(numerator!)/Frequency(denominator!)
                            if mt == 1.0 || mt == 2.0 {
                                // skip 1/1, 2/1
                                continue
                            }
                            else {
                                noteArray.append(mt)
                                actualNumberOfNotes += 1
                                continue
                            }
                        }
                    }
                    else {
                        // a whole number, treated as a rational with a denominator of 1
                        if let whole = Int(substringForFirstMatch! as String) {
                            if whole <= 0 {
                                AKLog("ERROR: invalid ratio: \(String(describing: substringForFirstMatch))")
                                parsedScala = false
                                break
                            }
                            else if (whole == 1 || whole == 2) {
                                // skip degrees of 1 or 2
                                continue
                            }
                            else {
                                noteArray.append(Frequency(whole))
                                actualNumberOfNotes += 1
                                continue
                            }
                        }
                    }
                }
            }
            else {
                AKLog("ERROR: error parsing: \(lineStr)")
                continue
            }
        }
        
        if !parsedScala {
            AKLog("FATAL ERROR: cannot parse Scala file")
            return nil
        }
        
        AKLog("frequencies: \(noteArray)")
        return noteArray
    }
}
