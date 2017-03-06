+++
date = "2017-03-06T23:20:24+02:00"
title = "High Order Function Series"
draft = true

+++

This is a series of articles covering a subjective list of most used higher order functions.
What are those? It's a [function that does at least one of the follwing](https://en.wikipedia.org/wiki/Higher-order_function):
* take a function as an agrument
* returns a function

For example;
```
function visit<T>(array: T[], visitor: (element:T)=>void) {
  for(element of array) {
    visitor(element);
  }
}
```
or
```
function timed(func: ()=>any, label:string) {
  return (...args) => {
    console.time(label);
    try {
      return func(args);
    }finally{
      console.timeEnd(label);
    }
  }
}

const sqrt = timed(Math.sqrt, 'sqrt');
sqrt(4324324);
// => sqrt: 0.059ms
// => 2079.5009016588574
```

