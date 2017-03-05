+++
date = "2014-07-11T10:54:24+02:00"
title = "map (High Order Function of the day)"
draft = true

+++

# `map(fn)` 

Convert every element of the array using the supplied function.

```
[1,2,3].map(v => v*10)
// => [10,20,30]
```

```
function imperating(input:any[]) {
  const result = [];
  for(let i=0;i<input.lengh; i++) {
    const v = input[i];
    result.push(v * 10);
  }
  return result;
}
```

```
function functional(input:any[]) {
  return input.map(v => v * 10);
}

words = 'The quick brown fox jumps over the lazy dog'.split(/ +/);

maxLength = Math.max(...words.map(word => word.length))
wordColors = words
  .map(word => word.length)
  .map(len => len/maxLength)
  .map(percent => 180*percent)
  .map(part => part.toString(16))
  .map(part => `#${part}${part}${part}`);

words.forEach((word,idx) => {
  console.log(`%c${word}`, `background: ${wordColors[idx]}`);
})
  