---
title: "Fighting outdated packages with gitlab pipeline"
date: 2018-03-30T23:41:33+02:00
draft: true
tags: ['js','npm','gitlab']
---

Keeping your `npm` dependencies up to date is a never ending endeavor. With [about 500 packages deployed daily](http://www.modulecounts.com/) to [npm registry](https://npmjs.com) it's hard to stay afloat without some kind of automation. 

## Requirements

* notification on new releases 
* build & test using updated dependencies
* merge request with the update