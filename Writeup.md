Name: Alice Harada  
Due Date: Aug 24, 2022  
Course: Foundations of Databases & SQL Programming  
GitHubURL: https://github.com/aharada12/DBFoundations-Module07  

# Assignment 07: Functions
## Introduction
This will summarize when to use a SQL UDF (User-Defined Function) and explain the differences between scalar, inline, and multi-statement functions.

### When would you use a SQL UDF?
A SQL UDF (User-Defined Function) would be used when one of the built-in SQL functions would not accomplish your goal. A UDF is a custom function that can return either a single value or a table of values.

### Explain the differences between Scalar, Inline, and Multi-Statement Functions
A Scalar function is a function that returns a single value. Parameters are very useful when working with scalar functions as they can manipulate the value returned. An Inline function returns a single set of rows that satisfy the function input. A Multi-Statement function returns a table of data but requires some additional processing as well as a Begin and End statement. The data types of the returned columns and parameters are defined in the function rather than just the parameters (as with the Inline function).

## Summary
In summary, a SQL UDF is used to build a custom function. UDF’s can be scalar (returning one value), Inline (returning a simple table), or Multi-Statement (returning a table with additional processing).
