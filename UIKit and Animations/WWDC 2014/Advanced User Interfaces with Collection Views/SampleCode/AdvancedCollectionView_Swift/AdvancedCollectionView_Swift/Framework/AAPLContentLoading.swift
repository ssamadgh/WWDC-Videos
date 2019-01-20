/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
AAPLLoadableContentStateMachine — This is the state machine that manages transitions for all loadable content.
AAPLLoading — This is a signalling object used to simplify transitions on the statemachine and provide update blocks.
AAPLContentLoading — A protocol adopted by the AAPLDataSource class for loading content.
*/

import Foundation


/// A block that performs updates on the object that is loading. The object parameter is the receiver of the `-loadContentWithProgress:` message.
typealias AAPLLoadingUpdateBlock = (Any) -> Void




/** A specialization of AAPLStateMachine for content loading.

The valid transitions for AAPLLoadableContentStateMachine are the following:

- AAPLLoadStateInitial → AAPLLoadStateLoadingContent
- AAPLLoadStateLoadingContent → AAPLLoadStateContentLoaded, AAPLLoadStateNoContent, or AAPLLoadStateError
- AAPLLoadStateRefreshingContent → AAPLLoadStateContentLoaded, AAPLLoadStateNoContent, or AAPLLoadStateError
- AAPLLoadStateContentLoaded → AAPLLoadStateRefreshingContent, AAPLLoadStateNoContent, or AAPLLoadStateError
- AAPLLoadStateNoContent → AAPLLoadStateRefreshingContent, AAPLLoadStateContentLoaded or AAPLLoadStateError
- AAPLLoadStateError → AAPLLoadStateLoadingContent, AAPLLoadStateRefreshingContent, AAPLLoadStateNoContent, or AAPLLoadStateContentLoaded

The primary difference between `AAPLLoadStateLoadingContent` and `AAPLLoadStateRefreshingContent` is whether or not the owner had content to begin with. Refreshing content implies there was content already loaded and it just needed to be refreshed. This might require a different presentation (no loading indicator for example) than loading content for the first time.
*/

enum AAPLLoadState: State {
	
	/// The initial state.
	case initial
	
	/// The first load of content.
	case loadingContent
	
	/// Subsequent loads after the first.
	case refreshingContent
	
	/// After content is loaded successfully.
	case contentLoaded
	
	/// No content is available.
	case noContent
	
	/// An error occurred while loading content.
	case error
	
	var nextValidStates: [State] {
		switch self {
		case .initial:
			return [AAPLLoadState.loadingContent]
			
		case .loadingContent:
			return [AAPLLoadState.contentLoaded, AAPLLoadState.noContent, AAPLLoadState.error]
			
		case .refreshingContent:
			return [AAPLLoadState.contentLoaded, AAPLLoadState.noContent, AAPLLoadState.error]
			
		case .contentLoaded:
			return [AAPLLoadState.refreshingContent, AAPLLoadState.noContent, AAPLLoadState.error]
			
		case .noContent:
			return [AAPLLoadState.refreshingContent, AAPLLoadState.contentLoaded, AAPLLoadState.error]
			
		case .error:
			return [AAPLLoadState.loadingContent, AAPLLoadState.refreshingContent, AAPLLoadState.noContent, AAPLLoadState.contentLoaded]
		}
	}
	
	func isEqual(to other: State) -> Bool {
		if let state = other as? AAPLLoadState {
			return self == state
		}
		return false
	}
	
}

class AAPLLoadableContentStateMachine: AAPLStateMachine {
	
    override init() {
        super.init()
		
        currentState = AAPLLoadState.initial
    }
}



/** A class passed to the `-loadContentWithProgress:` method of an object adopting the `AAPLContentLoading` protocol.

Implementers of `-loadContentWithProgress:` can use this object to signal the success or failure of the loading operation as well as the next state for their data source.
*/
class AAPLLoadingProgress {

    /// Has this loading operation been cancelled? It's important to check whether the loading progress has been cancelled before calling one of the completion methods (-ignore, -done, -doneWithError:, updateWithContent:, or -updateWithNoContent:). When loading has been cancelled, updating via a completion method will throw an assertion in DEBUG mode.
	var isCancelled: Bool = false {
		// When cancelled, we immediately ignore the result of this loading operation. If one of the completion methods is called in DEBUG mode, we'll get an assertion.
        didSet {
			if isCancelled {
				ignore()
			}
        }
    }

    private var block: ((State?, Error?, AAPLLoadingUpdateBlock?) -> Void)?

    /// create a new loading helper
	class func loadingProgress(with handler: @escaping (State?, Error?, AAPLLoadingUpdateBlock?) -> Void) -> AAPLLoadingProgress {
		let loading = AAPLLoadingProgress.init()
		loading.block = handler
		loading.isCancelled = false
		return loading
    }

	private func done(with toState: State?, error: Error?, update: AAPLLoadingUpdateBlock?) {
		
        let block = self.block

        DispatchQueue.main.async {
            block?(toState, error, update)
        }

        self.block = nil
    }
	
	/// Signals that this result should be ignored. Sends a nil value for the state to the completion handler.
	func ignore() {
		done(with: nil, error: nil, update: nil)
	}

	/// Signals that loading is complete with no errors. This triggers a transition to the Loaded state.
	/// Signals that loading failed with an error. This triggers a transition to the Error state.
	func done(with error: Error? = nil) {
		let toState = error != nil ? AAPLLoadState.error : AAPLLoadState.contentLoaded
		self.done(with: toState, error: error, update: nil)
	}

	/// Signals that loading is complete, transitions into the Loaded state and then runs the update block.
	func updateWithContent(_ update: @escaping AAPLLoadingUpdateBlock) {
		self.done(with: AAPLLoadState.contentLoaded, error: nil, update: update)
	}
	
	/// Signals that loading completed with no content, transitions to the No Content state and then runs the update block.
	func updateWithNoContent(_ update: @escaping AAPLLoadingUpdateBlock) {
		self.done(with: AAPLLoadState.noContent, error: nil, update: update)
	}

}

/// A protocol that defines content loading behavior
protocol AAPLContentLoading {

    /// The current state of the content loading operation
    var loadingState: State { set get }

    /// Any error that occurred during content loading. Valid only when loadingState == AAPLLoadStateError.
    var loadingError: Error? { set get }

    /// Public method used to begin loading the content.
    func loadContentWithProgress(_ progress: AAPLLoadingProgress)

    /// Public method used to reset the content of the receiver.
    func resetContent()
}
