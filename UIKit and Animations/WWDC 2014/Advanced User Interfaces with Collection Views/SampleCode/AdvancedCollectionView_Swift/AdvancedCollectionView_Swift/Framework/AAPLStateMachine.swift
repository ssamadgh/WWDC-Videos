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

protocol State {
	
	var nextValidStates: [State] { get }
	func isEqual(to other: State) -> Bool

}

protocol AAPLStateMachineDelegate: class {
	
    // Completely generic state change hook
    func stateWillChange(from fromState: State?, to toState: State)
	func stateDidChange(from fromState: State?, to toState: State)
	
	func shouldEnter(to state: State) -> Bool
	func didEnter(to state: State)
	
	func didExit(from state: State)

    /// Return the new state or nil for no change for an missing transition from a state to another state. If implemented, overrides the base implementation completely.
    func missingTransition(from fromState: State?, to toState: State?) -> State?
}

extension AAPLStateMachineDelegate {
	
	/// For subclasses. Base implementation raises IllegalStateTransition exception. Need not invoke super unless desired. Should return the desired state if it doesn't raise, or nil for no change.
	func missingTransition(from fromState: State?, to toState: State?) -> State? {
//		NSException.raise(NSExceptionName(rawValue: "IllegalStateTransition"), format: "cannot transition from %@ to %@", arguments: getVaList([fromState, toState]))
		return nil
	}

}

//private let AAPLStateNil = "nil"

/**
A generic state machine implementation representing states as simple strings. It is usually not necessary to subclass AAPLStateMachine. Instead, set the delegate property and implement state transition methods as appropriate.

The state machine will call methods on the delegate based on the name of the state. For example, when transitioning from StateA to StateB, the state machine will first call `-shouldEnterStateA`. If that method isn't implemented or returns YES, the state machine updates the current state. It then calls `-didExitStateA` followed by `-didEnterStateB`. Finally, if implemented, it will call `-stateDidChange`.

Assumptions:

- The number of states and transitions are relatively few
- State transitions are relatively infrequent
- Multithreadsafety/atomicity is handled at a higher level
*/
class AAPLStateMachine: NSObject {
	
	/**
	Definition of the valid transitions for this state machine. This is a dictionary where the keys are the state names and the value for each key is an array of the valid next state. For example:
	
	doorStateMachine.validTransitions = @{
	@"Locked" : @[@"Closed"],
	@"Closed" : @[@"Open", @"Locked"],
	@"Open" : @[@"Closed"]
	};
	
	*/
//	var validTransitions: [Hashable: [State]] = [:]
	
	/// The current state of the state machine. This will only be nil after the state machine is created and before the state is set. It is not valid to set this back to nil.
    var currentState: State? {
		
        set {
			if newValue != nil {
				_currentState = newValue
			}
        }
        get {
            var currentState: State?
            // for atomic-safety, _currentState must not be released between the load of _currentState and the retain invocation
			self.stateLock.withCriticalScope { () -> Void in
				currentState = self.currentState
			}
			
            return currentState
        }
    }
    
	private var _currentState: State? = nil {
		didSet {
			self.attemptToSetCurrentState(to: self._currentState!)
		}
	}
	
	
	/// If set, AAPLStateMachine invokes transition methods on this delegate instead of self. This allows AAPLStateMachine to be used where subclassing doesn't make sense. The delegate is invoked on the same thread as -setCurrentState:
    weak var delegate: AAPLStateMachineDelegate?
	
	/// use NSLog to output state transitions; useful for debugging, but can be noisy
    var shouldLogStateTransitions = true
	
	/// A lock to guard reads and writes to the `_state` property
	fileprivate let stateLock = NSLock()
	
	
	/// Initialize a state machine with the initial state and valid transitions.
//	override init() {
//		super.init()
//
//	}
	
    /// set current state and return YES if the state changed successfully to the supplied state, NO otherwise. Note that this does _not_ bypass `-missingTransitionFromState:toState:`, so, if you invoke this, you must also supply a `-missingTransitionFromState:toState:` implementation that avoids raising exceptions.
    func applyState(_ state: State) -> Bool {
		return attemptToSetCurrentState(to: state)
    }

	@discardableResult
    func attemptToSetCurrentState(to toState: State) -> Bool {
        let fromState = self.currentState
        
        if shouldLogStateTransitions {
			print(" ••• request state change from \(fromState) to \(toState)")
        }
        
		let appliedToState = self.validateTransition(from: fromState, to: toState)
		
        if appliedToState == nil {
            return false
        }

		self.delegate?.stateWillChange(from: fromState, to: toState)
		
		self.stateLock.withCriticalScope { () -> Void in
			self.currentState = appliedToState
		}
		
        // ... send messages
		self.performTransition(from: fromState, to: appliedToState!)
		
		return toState.isEqual(to: appliedToState!)
    }
	
	
//	private func triggerMissingTransitionFromState(_ fromState: String?, toState: String?) -> String? {
//		if let delegate = self.delegate {
//			return delegate.missingTransition(from: fromState, toState: toState)
//		}
//		return self.missingTransition(from: fromState, toState: toState)
//	}

//    /// For subclasses. Base implementation raises IllegalStateTransition exception. Need not invoke super unless desired. Should return the desired state if it doesn't raise, or nil for no change.
//    func missingTransition(from fromState: String?, toState: String?) -> String? {
//		NSException.raise(NSExceptionName(rawValue: "IllegalStateTransition"), format: "cannot transition from %@ to %@", arguments: getVaList([fromState ?? "", toState ?? ""]))
//        return nil
//    }
	
    private func validateTransition(from fromState: State?, to toState: State?) -> State? {
        // Transitioning to the same state (fromState == toState) is always allowed. If it's explicitly included in its own validTransitions, the standard method calls below will be invoked. This allows us to avoid creating states that exist only to reexecute transition code for the current state.

		// Raise exception if attempting to transition to nil -- you can only transition *from* nil
		var toState = toState
		if toState == nil {
			print("  ••• \(self) cannot transition to <nil> state")
			toState = self.delegate?.missingTransition(from: fromState, to: toState)
			
			if toState == nil {
				return nil
			}
		}
		
		
		// Raise exception if this is an illegal transition (toState must be a validTransition on fromState)
        if let fromState = fromState {
            let nextStates = fromState.nextValidStates
			
            var transitionSpecified = true

			if nextStates.contains(where: { (state) -> Bool in
				return toState!.isEqual(to: state)
			}) {
				transitionSpecified = false
			}

			if !transitionSpecified {
				// Silently fail if implict transition to the same state
				if fromState.isEqual(to: toState!) {
					if self.shouldLogStateTransitions {
						print("  ••• \(self) ignoring reentry to \(toState)")
						return nil
					}
				}
				
				if self.shouldLogStateTransitions {
					print("  ••• \(self) cannot transition to \(toState) from \(fromState)")
				}
				toState = self.delegate?.missingTransition(from: fromState, to: toState!)
				
				if toState == nil {
					return nil
				}
			}
        }
		
		// Allow target to opt out of this transition (preconditions)

		if !(self.delegate?.shouldEnter(to: toState!) ?? false) {
			print("  ••• \(self) transition disallowed to \(toState) from \(fromState) via shouldEnter(to: \(toState))")
			toState = self.delegate?.missingTransition(from: fromState, to: toState!)
		}
		
        return toState
    }
	
    private func performTransition(from fromState: State?, to toState: State) {
        // Subclasses may implement several different selectors to handle state transitions:
        //
        //  did enter state (didEnterPaused)
        //  did exit state (didExitPaused)
        //  transition between states (stateDidChangeFromPausedToPlaying)
        //  generic transition handler (stateDidChange), for common tasks
        //
        // Any and all of these that are implemented will be invoked.
        
        if shouldLogStateTransitions {
            print("  ••• \(self) state change from \(fromState) to \(toState)")
        }
        
		
        if let fromState = fromState {
			self.delegate?.didExit(from: fromState)
        }
		
		self.delegate?.didEnter(to: toState)

		self.delegate?.stateDidChange(from: fromState, to: toState)
		
    }
	
	
}
