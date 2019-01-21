# Building Apps with Dynamic Type

This sample demonstrates several common tips and tricks for supporting Dynamic Type.

## Overview

Cute Battle Pets is an app that allows you to own a pet and send it into battle with other people's pets.
There are four primary views in the app:

- Pet view:  `PetViewController`
- Table view of battle opponents: `BattleViewController`
- Score card for a battle: `ScoreCardViewController`
- Table view of badges achieved by your pet: `AchievementsViewController`

## Concepts

**Text style fonts (`UIFontTextStyle`)**

Almost all labels use text styles, including the labels created in Interface Builder for `Main.storyboard`: Pet Scene. The only exceptions are the labels in `BattleCell`.

**Automatic adjustment of fonts when the content size category changes (`adjustsFontForContentSizeCategory`)**

All labels have this property set to `true`. In `Main.storyboard`: Pet Scene, this is denoted by the "Automatically Adjusts Font" checkbox in the attribute inspector.

**Line wrapping (`numberOfLines`)**

All labels that appear multiline in the UI have `numberOfLines` set to a value other than the default of 1.
  * The description for each pet in the `BattleCell` is limited to 3 lines. This is because the same description appears in the detail view for each pet. In cases where a detail view contains the same information, it is acceptable to truncate the cell text after a reasonable length. This helps to reduce the need for scrolling.
  
**Custom fonts that scale with Dynamic Type**

Several labels in `BattleCell` use the Noteworthy font instead of the standard text style fonts. The developer is responsible for choosing an appropriate font at the default content size category (`UIContentSizeCategoryLarge`), and optionally, an appropriate text style whose metrics should be used for scaling. The `UIFontMetrics` class then scales the font for the user's content size category automatically.
  
**Auto Layout standard spacing (system spacing) constraints**

These allow constraining the baseline of a text-containing view to another view such that the spacing scales with the font in the text-containing view.
  * Examples in code in `AchievementsCell` and `BattleCell`.
  * Examples in Interface Builder in `Main.storyboard`: Pet Scene.
  
**Point values that scale with Dynamic Type**

`ScoreCardViewController` uses manual layout, so it is unable to take advantage of Auto Layout standard spacing (system spacing) baseline-to-baseline constraints. `UIFontMetrics` can be used to scale point values directly for calculations. This allows the class to specify a  default height for each row (popularity, health, etc.) and have that height scale based on the user's content size category.
  
**Scrolling when necessary for larger text sizes**

`Main.storyboard`: Pet Scene embeds a content view within a scroll view. It only scrolls when the font size causes text to run out of the screen bounds.
  
  **Shrinking fonts when scrolling is not possible**
  
`ScoreCardViewController` has a design requirement where all content must fit on one screen without scrolling. As a result, `adjustsFontSizeToFitWidth` is utilized as a fallback to reduce the size of the text and prevent truncation.

  * When using multiline labels, `adjustsFontSizeToFitWidth` will also shrink to fit the height.
  * This is not an ideal solution.
  
**Variable heights using self-sizing cells in table views**

Both `AchievementsViewController` and `BattleViewController` use `estimatedRowHeight`, `rowHeight`, and `UITableViewAutomaticDimension` to enable self-sizing cells.
  * Both `AchievementsCell` and `BattleCell` have constraints that are sufficient to determine the height of the cell.
  
**Vertical stacking for larger text sizes**

In `BattleViewController`, the "Battle" button is usually placed to the right of the pet name and description. For larger sizes, this can be moved below the text so that the text has more horizontal room. This results in less wrapping/truncation. Similar logic applies to the pet image in this cell, so it is moved above the text for larger text sizes.

  * Small images that normally take up horizontal space can be placed inline with text instead, at larger text sizes. This provides more horizontal room for the text. Indent the first line and allow subsequent lines to wrap underneath. This happens automatically in standard table view cells. In custom UI, this can be achieved several ways:
  
Placing the image in an `NSTextAttachment`:
```
let stringWithImage = NSMutableAttributedString()
let imageAsAttachment = NSTextAttachment()
imageAsAttachment.image = image
stringWithImage.append(NSAttributedString(attachment: imageAsAttachment))
stringWithImage.append(NSAttributedString(string: string))
```

Using a `UITextView`:
```
let bezierPath = UIBezierPath(rect: imageRect)
textView.textContainer.exclusionPaths = [bezierPath]
```

Using a `UILabel`:

See `AchievementsCell` for an example using `firstLineHeadIndent`.
[View in Source](x-source-tag://firstLineHeadIndent)
     
**Image scaling**

The glyphs in `ScoreCardViewController` and `AchievementsViewController` use `adjustsImageSizeForAccessibilityContentSizeCategory` to scale images at the 5 largest text sizes.

  * The above glyphs as well as the tab bar glyphs use the Preserve Vector Data checkbox in the asset catalog. This allows the original PDF to be preserved and drawn smoothly at different sizes.
