---
title: "The Curious Case of Undeclared Global Variables in Javascript"
date: 2023-08-02T16:43:58+02:00
draft: false
tags: ["programming", "development", "javascript"]
categories: ["Programming"]
---

How does your usual variable declaration look like?
<br>
<br>
Like this, right?

```js
const INTEREST_RATE = 20;           // global const declaration and initialization
var principleAmount;                // global var declaration

function calculateInterest() {
    principleAmount = 10000;        // global var value assignment
    var timePeriod = 1;             // local function scoped var declaration and initialization
    return principleAmount*INTEREST_RATE*timePeriod/100;
}
```

Do you know the difference between the above and below code snippet?

```js
const INTEREST_RATE = 20;           // global const declaration and initialization
var principleAmount;                // global var declaration

function calculateInterest() {
    principleAmount = 10000;        // global var value assignment
    timePeriod = 1;                 // <-- GLOBAL variable initialization without declaration
    return principleAmount*INTEREST_RATE*timePeriod/100;
}
```
> Did you notice that **var** is missing behind timePeriod?

It shouldn't work but it does. It feels like a bug since the variable *timePeriod* was never declared and hence a value assignment should not technically work. But it does! 
<br>
This is called the ***Implicit Global*** phenomenon. 

# Global Object

Did you notice the other global variable declarations? Well, technically there are no global variables in Javascipt. There is only one global object (think of it as a global JSON) that contains every variable used in your code. 

> Let's look at this example

```js
// Declaring an object "person" with properties 'name' and 'age'
var person = {
  name: "Adam Driver",
  age: 37
}
``` 

It makes sense that we can alter the *age* property of object **person** like below

```js
// modifying 'age' to 38
person.age = 38
``` 

It also makes sense that we can similarly add new properties to object **person** 


```js
// adding property 'occupation' to object "person"
person.occupation = "Actor"
``` 


In a similar manner, Javascript stores all variables as properties to its global object. Of course, it sets scopes for each of them to filter out local variables scoped only to their respective functions from similarly named global variables. It also sets types to variables like const, var, etc. But overall, variables in javascript are properties. 
<br>
<br>
Hence, a variable initialized without declaration is like adding a new property to the global object. It uses all the default parameters (global, var) for it. And hence, it is also accessible from everywhere else as it lacks the scope data and therefore is available globally. 

> This global object in Javascript in browsers is **window**

# Drawbacks

It does not save you when you misspell a variable name.
<br>
<br>
Say, if in our first example, we misspell the variable ***principleAmount*** as ***prncipleAmount***. What happens then? 

```js
const INTEREST_RATE= 20; 
var principleAmount;  // original global variable to hold principle amount

function calculateInterest() {
    prncipleAmount= 10000; // wrong spelling
    var timePeriod = 1;
    return principleAmount*INTEREST_RATE*timePeriod/100 // principleAmount remains uninitialized at undefined
}
```

Well, Javascript simply creates a new global variable by the new name ***prncipleAmount*** and assigns value to it while our originally intended variable ***principleAmount*** remains uninitialized at **undefined**.

# How to escape this Horror of Implicit Globals?

This is where ECMAScript 5th edition came to the rescue. The above behavior of Javascript is referred to as the **loose** mode. To avoid implicit global variables, you can simply use **use strict;** at the top of your JS file and that's it. It will automatically be taken care of!

```js
"use strict";
prncipleAmount = 10000;  // This will cause an error because prncipleAmount was never declared
``` 

> Every modern browser supports ***strict mode*** and I encourage you to use it if your text editor does not have helper tools like Intellisense in Visual Studio Code. 
