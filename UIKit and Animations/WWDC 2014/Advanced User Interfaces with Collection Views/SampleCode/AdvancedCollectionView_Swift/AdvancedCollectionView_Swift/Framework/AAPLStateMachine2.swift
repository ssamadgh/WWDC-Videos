/*

AAPLStateMachine2.swift
AdvancedCollectionView_Swift

Created by Seyed Samad Gholamzadeh on 7/22/18.
Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
A general purpose state machine implementation. The state machine will call methods on the delegate based on the name of the state. For example, when transitioning from StateA to StateB, the state machine will first call -shouldEnterStateA. If that method isn't implemented or returns YES, the state machine updates the current state. It then calls -didExitStateA followed by -didEnterStateB. Finally, if implemented, it will call -stateDidChange.
Assumptions:
- The number of states and transitions are relatively few
- State transitions are relatively infrequent
- Multithreadsafety/atomicity is handled at a higher level
*/

import Foundation

protocol AAPLStateMachineDelegate2: class {
	
	// Completely generic state change hook
	func stateWillChange()
	func stateDidChange()
	
	/// Return the new state or nil for no change for an missing transition from a state to another state. If implemented, overrides the base implementation completely.
	func missingTransition(from state: String?, toState: String?) -> String?
}

private let AAPLStateNil = "nil"

/**
A generic state machine implementation representing states as simple strings. It is usually not necessary to subclass AAPLStateMachine. Instead, set the delegate property and implement state transition methods as appropriate.

The state machine will call methods on the delegate based on the name of the state. For example, when transitioning from StateA to StateB, the state machine will first call `-shouldEnterStateA`. If that method isn't implemented or returns YES, the state machine updates the current state. It then calls `-didExitStateA` followed by `-didEnterStateB`. Finally, if implemented, it will call `-stateDidChange`.

Assumptions:

- The number of states and transitions are relatively few
- State transitions are relatively infrequent
- Multithreadsafety/atomicity is handled at a higher level
*/
class AAPLStateMachine2: NSObject {
	
	/**
	Definition of the valid transitions for this state machine. This is a dictionary where the keys are the state names and the value for each key is an array of the valid next state. For example:
	
	doorStateMachine.validTransitions = @{
	@"Locked" : @[@"Closed"],
	@"Closed" : @[@"Open", @"Locked"],
	@"Open" : @[@"Closed"]
	};
	
	*/
	var validTransitions: [String: [String]] = [:]
	
	/// The current state of the state machine. This will only be nil after the state machine is created and before the state is set. It is not valid to set this back to nil.
	var currentState: String? {
		set {
			if newValue != nil {
				_currentState = newValue
			}
		}
		get {
			var currentState: String?
			// for atomic-safety, _currentState must not be released between the load of _currentState and the retain invocation
			os_unfair_lock_lock(&lock)
			currentState = self.currentState
			os_unfair_lock_unlock(&lock)
			return currentState
		}
	}
	
	private var _currentState: String? = nil {
		didSet {
			self.attemptToSetCurrentState(self._currentState!)
		}
	}
	
	
	/// If set, AAPLStateMachine invokes transition methods on this delegate instead of self. This allows AAPLStateMachine to be used where subclassing doesn't make sense. The delegate is invoked on the same thread as -setCurrentState:
	weak var delegate: AAPLStateMachineDelegate?
	
	/// use NSLog to output state transitions; useful for debugging, but can be noisy
	var shouldLogStateTransitions = true
	
	private var lock = os_unfair_lock()
	
	var target: AnyObject {
		return delegate ?? self
	}
	
	/// Initialize a state machine with the initial state and valid transitions.
	override init() {
		super.init()
		
	}
	
	/// set current state and return YES if the state changed successfully to the supplied state, NO otherwise. Note that this does _not_ bypass `-missingTransitionFromState:toState:`, so, if you invoke this, you must also supply a `-missingTransitionFromState:toState:` implementation that avoids raising exceptions.
	func applyState(_ state: String) -> Bool {
		return attemptToSetCurrentState(state)
	}
	
	func attemptToSetCurrentState(_ toState: String) -> Bool {
		let fromState = self.currentState
		
		if shouldLogStateTransitions {
			print(" ••• request state change from \(fromState ?? "nil") to \(toState)")
		}
		
		let appliedToState = self.validateTransition(fromState, toState: toState)
		
		if appliedToState == nil {
			return false
		}
		
		// ...send will-change message for downstream KVO support...
		
		let target = self.target
		
		let genericWillChangeAction = Selector(("stateWillChange"))
		//		let genericWillChangeAction2 = #selector(stateWillChange)
		if target.responds(to: genericWillChangeAction) {
			//			typedef void (*ObjCMsgSendReturnVoid)(id, SEL);
			//			ObjCMsgSendReturnVoid sendMsgReturnVoid = (ObjCMsgSendReturnVoid)objc_msgSend;
			//			sendMsgReturnVoid(target, genericWillChangeAction);
		}
		//        if target.responds(to: genericWillChangeAction) {
		//            _ = target.perform(genericWillChangeAction)
		//        }
		
		os_unfair_lock_lock(&lock)
		self.currentState = appliedToState
		os_unfair_lock_unlock(&lock)
		
		// ... send messages
		self.performTransitionFromState(fromState, toState: appliedToState!)
		
		return toState == appliedToState
	}
	
	
	private func triggerMissingTransitionFromState(_ fromState: String?, toState: String?) -> String? {
		if let delegate = self.delegate {
			return delegate.missingTransition(from: fromState, toState: toState)
		}
		return self.missingTransition(from: fromState, toState: toState)
	}
	
	/// For subclasses. Base implementation raises IllegalStateTransition exception. Need not invoke super unless desired. Should return the desired state if it doesn't raise, or nil for no change.
	func missingTransition(from state: String?, toState: String?) -> String? {
		NSException.raise(NSExceptionName(rawValue: "IllegalStateTransition"), format: "cannot transition from %@ to %@", arguments: getVaList([state ?? "", toState ?? ""]))
		return nil
	}
	
	private func validateTransition(_ fromState: String?, toState: String?) -> String? {
		// Transitioning to the same state (fromState == toState) is always allowed. If it's explicitly included in its own validTransitions, the standard method calls below will be invoked. This allows us to avoid creating states that exist only to reexecute transition code for the current state.
		
		// Raise exception if attempting to transition to nil -- you can only transition *from* nil
		var toState = toState
		if toState == nil {
			print("  ••• \(self) cannot transition to <nil> state")
			toState = self.triggerMissingTransitionFromState(fromState!, toState: toState)
			
			if toState == nil {
				return nil
			}
		}
		
		
		// Raise exception if this is an illegal transition (toState must be a validTransition on fromState)
		if let fromState = fromState {
			let validTransitions = self.validTransitions[fromState]
			var transitionSpecified = true
			
			// Multiple valid transitions
			if validTransitions is [String] {
				if !(validTransitions as! [String]).contains(toState!) {
					transitionSpecified = false
				}
			}
				// Otherwise, single valid transition object
			else if validTransitions is String {
				if (validTransitions as! String) != toState! {
					transitionSpecified = false
				}
			}
			
			if !transitionSpecified {
				// Silently fail if implict transition to the same state
				if fromState == toState {
					if self.shouldLogStateTransitions {
						print("  ••• \(self) ignoring reentry to \(toState)")
						return nil
					}
				}
				
				if self.shouldLogStateTransitions {
					print("  ••• \(self) cannot transition to \(toState) from \(fromState)")
				}
				toState = self.triggerMissingTransitionFromState(fromState, toState: toState)
				
				if toState == nil {
					return nil
				}
			}
		}
		
		// Allow target to opt out of this transition (preconditions)
		let target = self.target
		//		typedef BOOL (*ObjCMsgSendReturnBool)(id, SEL);
		//		ObjCMsgSendReturnBool sendMsgReturnBool = (ObjCMsgSendReturnBool)objc_msgSend;
		//
		let enterStateAction = NSSelectorFromString("shouldEnter".appending(toState!))
		if target.responds(to: enterStateAction) {
			print("  ••• \(self) transition disallowed to \(toState) from \(fromState) (via \(NSStringFromSelector(enterStateAction)))")
			toState = self.triggerMissingTransitionFromState(fromState, toState: toState)
		}
		
		return toState
	}
	
	private func performTransitionFromState(_ fromState: String?, toState: String) {
		// Subclasses may implement several different selectors to handle state transitions:
		//
		//  did enter state (didEnterPaused)
		//  did exit state (didExitPaused)
		//  transition between states (stateDidChangeFromPausedToPlaying)
		//  generic transition handler (stateDidChange), for common tasks
		//
		// Any and all of these that are implemented will be invoked.
		
		if shouldLogStateTransitions {
			print("  ••• \(self) state change from \(fromState ?? "") to \(toState)")
		}
		
		let target = self.target
		
		//		typedef void (*ObjCMsgSendReturnVoid)(id, SEL);
		//		ObjCMsgSendReturnVoid sendMsgReturnVoid = (ObjCMsgSendReturnVoid)objc_msgSend;
		
		if let fromState = fromState {
			let exitStateAction = Selector("didExit\(fromState)")
			if target.responds(to: exitStateAction) {
				//				sendMsgReturnVoid(target, exitStateAction);
				
			}
		}
		
		let enterStateAction = Selector("didEnter\(toState)")
		if target.responds(to: enterStateAction) {
			//				sendMsgReturnVoid(target, enterStateAction);
		}
		
		let fromStateNotNil = fromState ?? AAPLStateNil
		
		let transitionAction = Selector("stateDidChangeFrom\(fromStateNotNil)To\(toState)")
		if target.responds(to: transitionAction) {
			//			sendMsgReturnVoid(target, transitionAction);
		}
		
		let genericDidChangeAction = Selector(("stateDidChange"))
		if target.responds(to: genericDidChangeAction) {
			//			sendMsgReturnVoid(target, genericDidChangeAction);
		}
	}
}
