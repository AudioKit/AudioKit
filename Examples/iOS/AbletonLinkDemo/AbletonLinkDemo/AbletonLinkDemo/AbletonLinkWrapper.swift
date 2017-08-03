//
//  AbletonLinkWrapper.swift
//
//  Created by Kevin Vacquier on 24/07/17.
//  Copyright © 2017 Kevin Vacquier. All rights reserved.
//  Inspired by Jason Snell LinkWrapper.
//


import Foundation
import UIKit
import AVFoundation


struct EngineData {
	
	var outputLatency:UInt32 = 0
	var resetToBeatTime:Float64 = 0
	var proposeBpm:Float64 = 120
	var quantum:Float64 = 8
	var isPlaying:Bool = false
	
}

struct LinkData {
	
	//Structure that stores all data needed by the audio callback.
	
	var ablLink:ABLLinkRef
	// Shared between threads. Only write when engine not running.
	var sampleRate:Float64
	// Shared between threads. Only write when engine not running.
	var secondsToHostTime:Float64
	// Shared between threads. Written by the main thread and only
	// read by the audio thread when doing so will not block.
	var sharedEngineData:EngineData
	// Copy of sharedEngineData owned by audio thread.
	var localEngineData:EngineData
	// Owned by audio thread
	var timeAtLastClick:UInt64
	
}


protocol AbletonLinkDelegate {
	func tempoDidChange(bpm: Double, quantum: Double)
	func linkEnabled(enable: Bool)
	func connectionStatusChange(enable: Bool)
}

public class AbletonLinkWrapper:NSObject {
	
	//MARK:-
	//MARK:CONSTANTS
	
	fileprivate let INVALID_BEAT_TIME:Double = Double.leastNormalMagnitude
	fileprivate let INVALID_BPM:Double = Double.leastNormalMagnitude
	fileprivate let QUANTUM_DEFAULT:Float64 = 4
	
	//MARK: - VARS
	//var lock = os_unfair_lock() //ios10
	fileprivate var lock:OSSpinLock = OSSpinLock()
	
	fileprivate var linkData:LinkData?
	
	//timer
	fileprivate var timer:Timer = Timer()
	fileprivate let timerSpeed:Double = 0.1
	
	//debug
	fileprivate var debug:Bool = false
	
	//MARK: - PUBLIC API -
	
	//MARK:INIT
	
	//singleton code
	public static let sharedInstance = AbletonLinkWrapper()
	
	fileprivate override init() {
		super.init()
	}
	
	var delegate: AbletonLinkDelegate?
	
	public func setup(bpm:Double = 120, quantum:Float64 = 4.0){
		
		if (debug){ print("ABL: Init") }
		
		var timeInfo = mach_timebase_info_data_t()
		mach_timebase_info(&timeInfo)
		
		let ablLink:ABLLinkRef = ABLLinkNew(bpm)
		
		let sharedEngineData:EngineData = EngineData()
		let localEngineData:EngineData = EngineData()
		
		
		linkData = LinkData(
			ablLink: ablLink,
			sampleRate: AVAudioSession.sharedInstance().sampleRate,
			secondsToHostTime: (1.0e9 * Float64(timeInfo.denom)) / Float64(timeInfo.numer),
			sharedEngineData: sharedEngineData,
			localEngineData: localEngineData,
			timeAtLastClick: 0)
		
		if (linkData != nil){
			linkData!.sharedEngineData.outputLatency = UInt32(linkData!.secondsToHostTime * AVAudioSession.sharedInstance().outputLatency)
			linkData!.sharedEngineData.resetToBeatTime = INVALID_BEAT_TIME
			linkData!.sharedEngineData.proposeBpm = INVALID_BPM
			linkData!.sharedEngineData.quantum = quantum // incoming from sequencer during init
			linkData!.sharedEngineData.isPlaying = false
			linkData!.localEngineData = linkData!.sharedEngineData
			linkData!.timeAtLastClick = 0
			
		}
		
		addListeners()
		
	}
	
	var isConnected: Bool {
		get {
			if let linkRef:ABLLinkRef = getLinkRef() {
				return ABLLinkIsConnected(linkRef)
			}
			return false
		}
	}
	
	var isEnabled: Bool {
		get {
			if let linkRef:ABLLinkRef = getLinkRef() {
				return ABLLinkIsEnabled(linkRef)
			}
			return false
		}
	}
	
	public func set(active:Bool){
		
		if let linkRef:ABLLinkRef = getLinkRef() {
			
			if (debug){ print("ABL: Active to", active) }
			ABLLinkSetActive(linkRef, active)
			
		} else {
			
			print("ABL: Error getting ref when activating session")
			
		}
		
	}
	
	//MARK: - LOOP
	public func start(){
		
		if (debug){
			print("ABL: Start")
		}
		
		timer.invalidate()
		
		timer = Timer.scheduledTimer(
			timeInterval: timerSpeed,
			target: self,
			selector: #selector(update),
			userInfo: nil,
			repeats: true)
	}
	
	public func stop(){
		
		if (debug){ print("ABL: Stop") }
		
		timer.invalidate()
	}
	
	
	//MARK: - SHUTDOWN
	public func shutdown(){
		
		if (debug){ print("ABL: Shutdown") }
		
		stop()
		set(active: false)
		
	}
	
	
	//MARK: - VIEW CONTROLLER
	
	public func getViewController() -> UIViewController? {
		
		
		if let ref:ABLLinkRef = getLinkRef() {
			if let vc:UIViewController = ABLLinkSettingsViewController.instance(ref) as? UIViewController {
				return vc
			} else {
				print("ABL: Error casting ABL vc as UIViewController")
				return nil
			}
			
		} else {
			print("ABL: Error getting ref when getting view controller")
			return nil
		}
	}
	
	//MARK: - BPM
	
	public func set(bpm:Float64){
		
		if (debug){
			print("ABL: Set Bpm to", bpm)
		}
		
		if (linkData != nil){
			
			//os_unfair_lock_lock(&lock) //iOS 10
			OSSpinLockLock(&lock)
			linkData!.sharedEngineData.proposeBpm = bpm
			//os_unfair_lock_unlock(&lock) //iOS 10
			OSSpinLockUnlock(&lock)
			
		} else {
			if (debug){
				print("ABL: LinkData invalid when trying to set BPM")
			}
		}
	}
	
	
	
	
	//MARK: - PRIVATE API w LISTENER ACCESS -
	
	//MARK: timer loop
	internal func update() {
		
		// Get a copy of the current link timeline.
		let timeline:ABLLinkTimelineRef = ABLLinkCaptureAudioTimeline(linkData!.ablLink)
		
		// update engine data (local func)
		let engineData:EngineData = updateEngineData()
		
		
		// The mHostTime member of the timestamp represents the time at
		// which the buffer is delivered to the audio hardware. The output
		// latency is the time from when the buffer is delivered to the
		// audio hardware to when the beginning of the buffer starts
		// reaching the output. We add those values to get the host time
		// at which the first sample of this buffer will reach the output.
		
		
		let hostTimeAtBufferBegin:UInt64 = mach_absolute_time() + UInt64(engineData.outputLatency)
		
		// Handle a timeline reset
		
		if (engineData.resetToBeatTime != INVALID_BEAT_TIME) {
			// Reset the beat timeline so that the requested beat time
			// occurs near the beginning of this buffer. The requested beat
			// time may not occur exactly at the beginning of this buffer
			// due to quantization, but it is guaranteed to occur within a
			// quantum after the beginning of this buffer. The returned beat
			// time is the actual beat time mapped to the beginning of this
			// buffer, which therefore may be less than the requested beat
			// time by up to a quantum.
			ABLLinkRequestBeatAtTime(
				timeline,
				engineData.resetToBeatTime,
				hostTimeAtBufferBegin,
				engineData.quantum)
		}
		
		
		// Handle a tempo proposal
		
		if (engineData.proposeBpm != INVALID_BPM) {
			// Propose that the new tempo takes effect at the beginning of this buffer.
			if (debug) { print("ABL: Proposed BPM = ", engineData.proposeBpm) }
			
			ABLLinkSetTempo(timeline, engineData.proposeBpm, hostTimeAtBufferBegin)
			
		}
		
		ABLLinkCommitAudioTimeline(linkData!.ablLink, timeline)
		
		//post the current position after doing the updates
		
		if (debug){
			print("ABL: curr beat", getBeat())
		}
		
	}
	
	//MARK: Route change
	internal func handleRouteChange(){
		
		if (debug){
			print("ABL: route change")
		}
		
		if (linkData != nil){
			
			let outputLatency:UInt32 = UInt32((linkData?.secondsToHostTime)! * AVAudioSession.sharedInstance().outputLatency)
			
			OSSpinLockLock(&lock)
			linkData?.sharedEngineData.outputLatency = outputLatency
			OSSpinLockUnlock(&lock)
			
		} else {
			if (debug){
				print("ABL: Error accesing LinkData during route change")
			}
		}
	}
	
	
	func getIsPlaying() -> Bool {
		
		if (linkData != nil){
			return linkData!.sharedEngineData.isPlaying
		} else {
			return false
		}
		
	}
	
	
	
	func set(isPlaying:Bool){
		
		if (linkData != nil){
			
			//os_unfair_lock_lock(&lock) //ios10
			OSSpinLockLock(&lock)
			
			linkData!.sharedEngineData.isPlaying = isPlaying
			if (isPlaying){
				linkData!.sharedEngineData.resetToBeatTime = 0
			}
			OSSpinLockUnlock(&lock)
			//os_unfair_lock_unlock(&lock) //ios10
			
		}
		
		
	}
	
	
	
	func getBpm() -> Float64 {
		
		if (linkData != nil){
			return ABLLinkGetTempo(ABLLinkCaptureAppTimeline(linkData!.ablLink))
		} else {
			return 0
		}
	}
 
	func setBpm(bpm: Double) {
		ABLLinkSetTempo(ABLLinkCaptureAppTimeline(linkData!.ablLink), bpm, mach_absolute_time())
	}
	
	func getBeat() -> Float64 {
		
		if (linkData != nil){
			
			return ABLLinkBeatAtTime(
				ABLLinkCaptureAppTimeline(linkData!.ablLink),
				mach_absolute_time(),
				getQuantum())
			
		} else {
			if (debug){
				print("ABL: LinkData invalid when trying to get beat. Returning 0.")
			}
			return 0
		}
		
	}
	
	
	//Attempt to map the given beat time to the given host time in the context. Now by default.
	
	func requestBeatAtTime(beatTime: Double, hostTimeAtOutput: UInt64 = mach_absolute_time()) {
		ABLLinkRequestBeatAtTime(ABLLinkCaptureAppTimeline(linkData!.ablLink), beatTime, hostTimeAtOutput, getQuantum())
	}
	
	//not being used, "beat" in Position is being calculated with the getBeat
	//v 2.1.2
	func getPhase() -> Float64 {
		
		if (linkData != nil){
			
			return ABLLinkPhaseAtTime(
				ABLLinkCaptureAppTimeline(linkData!.ablLink),
				mach_absolute_time(),
				getQuantum())
			
		} else {
			if (debug){
				print("ABL: LinkData invalid when trying to get phase. Returning 0.")
			}
			return 0
		}
		
	}
	
	// Quantum = number of beat per mesure, usualy 4
	func getQuantum() -> Float64 {
		
		if (linkData != nil){
			return linkData!.sharedEngineData.quantum
		} else {
			if (debug){
				print("ABL: LinkData invalid when trying to get quantum. Returning default.")
			}
			return QUANTUM_DEFAULT
		}
		
	}
	
	
	func setQuantum(quantum:Float64) {
		
		if (linkData != nil){
			
			OSSpinLockLock(&lock)
			//os_unfair_lock_lock(&lock) //ios10
			linkData!.sharedEngineData.quantum = quantum
			OSSpinLockUnlock(&lock) //ios10
			//os_unfair_lock_unlock(&lock)
			
		}
		
	}
	
	
	
	//MARK: Link ref
	//this is a ref to the abLink system
	//accessed internally during init and by outside classes
	func getLinkRef() -> ABLLinkRef? {
		
		if (linkData != nil){
			return linkData!.ablLink
		} else {
			if (debug) { print("ABL: No link ref available during getLinkRef") }
			return nil
		}
		
	}
	
	//MARK: add listeners
	fileprivate func addListeners(){
		
		//route change
		NotificationCenter.default.addObserver(
			self, selector: #selector(handleRouteChange),
			name: NSNotification.Name.AVAudioSessionRouteChange,
			object: AVAudioSession.sharedInstance())
		
		// Void pointer to self for C callbacks below
		// http://stackoverflow.com/questions/33260808/swift-proper-use-of-cfnotificationcenteraddobserver-w-callback
		let selfAsURP = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
		let selfAsUMRP = UnsafeMutableRawPointer(mutating:selfAsURP)
		
		
		if let ref:ABLLinkRef = getLinkRef() {
			
			//add listerner to detect tempo changes from other devices
			/*
			//set callback format
			void ABLLinkSetSessionTempoCallback(
			ABLLinkRef,
			ABLLinkSessionTempoCallback callback,
			void* context)
			*/
			
			ABLLinkSetSessionTempoCallback(
				ref,
				{ (sessionTempo, context) -> Void in
					
					if let context = context {
						let localSelf = Unmanaged<AbletonLinkWrapper>.fromOpaque(context).takeUnretainedValue()
						let localSelfAsUMRP = UnsafeMutableRawPointer(mutating:context)
						localSelf.onSessionTempoChanged(bpm: sessionTempo, context: localSelfAsUMRP)
					}
					
					
			},
				selfAsUMRP
				
			)
			
			//add onLinkEnabled listener
			
			/*
			//callback format:
			ABLLinkIsEnabledCallback
			typedef void (*ABLLinkIsEnabledCallback)(
			bool isEnabled,
			void *context)
			
			//set callback format:
			ABLLinkSetIsEnabledCallback
			void ABLLinkSetIsEnabledCallback(
			ABLLinkRef,
			ABLLinkIsEnabledCallback callback,
			void* context)
			*/
			
			ABLLinkSetIsEnabledCallback(
				ref,
				{ (isEnabled, context) -> Void in
					
					if let context = context {
						let localSelf = Unmanaged<AbletonLinkWrapper>.fromOpaque(context).takeUnretainedValue()
						let localSelfAsUMRP = UnsafeMutableRawPointer(mutating:context)
						localSelf.onLinkEnabled(isEnabled: isEnabled, context: localSelfAsUMRP)
					}
			},
				selfAsUMRP
				
			)
			
			ABLLinkSetIsConnectedCallback(
				ref,
				{ (isConnected, context) -> Void in
					
					if let context = context {
						let localSelf = Unmanaged<AbletonLinkWrapper>.fromOpaque(context).takeUnretainedValue()
						let localSelfAsUMRP = UnsafeMutableRawPointer(mutating:context)
						localSelf.onConnectionStatusChanged(isConnected: isConnected, context: localSelfAsUMRP)
					}
			},
				selfAsUMRP
				
			)
			
			
		} else {
			print("ABL: Error getting linkRef when adding listeners")
		}
	}
	
	//MARK: Tempo changes from other Link devices
	fileprivate func onSessionTempoChanged(bpm:Double, context:Optional<UnsafeMutableRawPointer>) -> (){
		
		if (debug){
			print("ABL: onSessionTempoChanged")
		}
		
		//update local var
		self.set(bpm: bpm)
		
		if (debug){
			print("ABL: curr bpm", bpm)
		}
		
		delegate?.tempoDidChange(bpm: bpm, quantum: self.getQuantum())
	}
	
	
	
	//MARK: Connection Status from ther devices changed
	fileprivate func onConnectionStatusChanged(isConnected:Bool, context:Optional<UnsafeMutableRawPointer>) -> (){
		
		if (debug){
			print("ABL: onConnectionStatusChanged")
		}
		
		
		if (debug){
			print("ABL: isConnected",isConnected)
		}
		
		delegate?.connectionStatusChange(enable: isConnected)
	}
	
	
	//MARK: onLinkEnabled
	fileprivate func onLinkEnabled(isEnabled:Bool, context:Optional<UnsafeMutableRawPointer>) -> (){
		
		if (debug){
			print("ABL: Link is", isEnabled)
		}
		delegate?.linkEnabled(enable: isEnabled)
	}
	
	//MARK: Metronome loop sub function
	fileprivate func updateEngineData() -> EngineData {
		
		//create new engine object with generic values
		var output:EngineData = EngineData()
		
		// Always reset the signaling members to their default state
		output.resetToBeatTime = INVALID_BEAT_TIME
		output.proposeBpm = INVALID_BPM
		
		// Attempt to grab the lock guarding the shared engine data but
		// don't block if we can't get it.
		if (OSSpinLockTry(&lock)) {
			//if (os_unfair_lock_trylock(&lock)) { //ios 10
			
			// Copy non-signaling members to the local thread cache
			linkData!.localEngineData.outputLatency = linkData!.sharedEngineData.outputLatency
			linkData!.localEngineData.quantum = linkData!.sharedEngineData.quantum
			linkData!.localEngineData.isPlaying = linkData!.sharedEngineData.isPlaying
			
			// Copy signaling members directly to the output and reset
			output.resetToBeatTime = linkData!.sharedEngineData.resetToBeatTime
			linkData!.sharedEngineData.resetToBeatTime = INVALID_BEAT_TIME
			
			output.proposeBpm = linkData!.sharedEngineData.proposeBpm
			linkData!.sharedEngineData.proposeBpm = INVALID_BPM
			
			OSSpinLockUnlock(&lock)
			//os_unfair_lock_unlock(&lock) //ios10
		}
		
		// Copy from the thread local copy to the output. This happens
		// whether or not we were able to grab the lock.
		output.outputLatency = linkData!.localEngineData.outputLatency
		output.quantum = linkData!.localEngineData.quantum
		output.isPlaying = linkData!.localEngineData.isPlaying
		
		if (output.proposeBpm != INVALID_BEAT_TIME){
			if (debug) { print("ABL: output propose bpm = ", output.proposeBpm) }
		}
		
		return output
	}
	
 
	
	
	
	//MARK:-
	//MARK: DEINIT
	
	
	
	deinit {
		// perform the deinitialization
		
		if (linkData != nil){
			ABLLinkDelete(linkData!.ablLink)
			//deletes Link (don't have multiples of this). Do this during app shutdown
		}
		
	}
	
	
}
