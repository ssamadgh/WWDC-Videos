CopyPasteTile

=============================================
The CopyPasteTile project demonstrates how to implement the copy-cut-paste feature introduced in iPhone OS v3.0. The application built by the project is a grid of squares on which four tiles of different colors are situated. You copy, cut, and paste these tiles to create simple designs or pictures. To start over, tap the reset button or shake the device. (The project also includes a very simple handler of shake-motion events, which were also introduced in iPhone OS v3.0.)

=============================================
Classes of Interest

CopyPasteTileAppDelegate — Creates a UIViewController object that manages a ColorTileView. Displays a help message when the application launches. 

ColorTileView — A custom view that draws the grid and the tiles and responds to touch and shake-motion events. This class has the methods implementing copy, cut, and paste.

ColorTile — A model object that ColorTileView uses for drawing tiles. Each object encapsulates a color and a location on the grid. The class conforms to the NSCoder protocol so that ColorTileView can archive a ColorTile object to a data object, which it then writes to the pasteboard.

=============================================
ColorTileView Methods of Interest

• touchesEnded:WithEvent: —Responds to the double-tap gesture by identifying the selection (the square tapped). It then uses the shared instance of the UIMenuController class to display the editing menu right above or below the selected square.

• canPerformAction:withSender: — Implements this UIResponder method to validate the commands of the editing menu before it's displayed. Returns NO for a given selector if it is not appropriate to include the associated command.

• copy:, cut:, and paste: — Implements these methods of the UIResponderStandardEditActions informal protocol to respond to taps on the associated menu commands. 

• motionEnded:withEvent: — Implements this UIResponder method to respond to the user shaking the device; the implementation resets the original tiles on the grid.

=============================================
Build Requirements
iOS 4.0 SDK

=============================================
Runtime Requirements
iPhone OS 3.2 or later

=============================================
Related Information

For conceptual information, see "Copy and Paste Operations" in the "Event Handling" chapter of iPhone Application Programming Guide. Also see the reference documentation for the UIPasteboard, UIMenuController, and UIResponder classes.