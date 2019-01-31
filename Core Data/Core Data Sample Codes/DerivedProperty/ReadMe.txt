
DerivedProperty
===============

This example illustrates two concepts:

1) Using a Derived Property in Core Data

    The 'LogEntry' entity in the sample model contains two fields; 'regularText' is the text as it was entered by the user. 'normalizedText' is a normalized representation of the text stored as a derived property.
    
2) Using a Value Transformer to override a predicate in a search field

    The search field is bound to create the predicate 'normalizedText contains $value' 
    But value is unnormalized, so we  use a value transformer to recreate the predicate with a normalized version of value.


Running the Sample:

- Create log entries using strings that contain different cases and accents
- Type in a search string without worrying about matching the exact accents of the original text and it should still succeed.

Additional Note:

This solution of maintaining a derived property and searching is much more efficient than using a predicate like the following in the search field

 'regularText contains[dc] $value'
 
for large data sets, each row in the regularText table will be transformed at search time. With the example solution we normalize the string once when it's created and then use it to perform a much more efficient search.

===========================================================================
Copyright (C) 2008-2013 Apple Inc. All rights reserved.
