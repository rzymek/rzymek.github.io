+++
title= "Perfect Stack.md"
date= 2018-06-09T14:40:17+02:00
draft = true
+++

# The Perfect Stack

* gitlab - git repo, CI/CD (pipelines), issues
* firebase
  * hosting of static assets
  * firestore + cloud functions - no maintanance backend. security rules somewhat tricky. functions harder to debug. Other than that great.
* React
* material-ui - UI component library
* typescript - it's like a unit test. used from ground up, from the start. ensures code consistency. makes deep refactoring possible.
* webpack
* npm packages
* jest - unit tests
* gemini - integration tests. Screenshot testing to catch serious mishaps - like page not showing at all.

Some might notice that that some industry standards are missing:
* no docker - firestore + cloud functions take a step further
* no redux - firestore real-time synced database is the single source of truth. Some state in `<App>` main component React state (`this.state`). https://medium.com/@dan_abramov/you-might-not-need-redux-be46360cf367
