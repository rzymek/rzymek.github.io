+++
bigimg = ""
date = "2014-07-11T10:54:24+02:00"
subtitle = ""
title = ""
draft = true

+++

# Why go functional?

## Imperative 
```typescript
function sumOfPositiveSquares(nums : number[]) {
  let sum = 0;
  for (let i = 0; i < nums.length; i++) {
    if(nums[i] < 0) {
      continue;
    }
    sum += nums[i] * nums[i];
  }
  return sum;
}
```

## Functional
```typescript
function sumOfPositiveSquares(nums : number[]) {
  return nums
    .filter( n => n >= 0 )
    .map   ( n => n*n )
    .reduce((start,num) => start + num, 0)
}
```

The basic building blocks:

* `map` - convert every element
* `filter` - skip some elements
* `reduce` - reduce array to a single value

## `reduce` usages

```typescript
[1, 2, 3].reduce((result, item) => result * item, 1) 
// => 6

[{id:1}, {id:2}, {id:3}].reduce(
  (result, item) => result.concat([item.id]), [] 
)
// => [1, 2, 3]

[{id:1}, {name: 'foo'}, {label: 'bar'}].reduce(
  (result, item) => Object.assign(result, item), {} 
)
// => {id: 1, name: "foo", label: "bar"}
```