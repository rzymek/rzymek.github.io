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

## Solution

https://docs.gitlab.com/ce/user/project/pipelines/schedules.html

![Sample pipeline schedule](/img/pipeline_schedules.png)

![Pipeline execution](/img/pipeline_schedules_run.png)


```yaml
image: node:8.11.0

cache:
  paths:
    - node_modules/

stages:
  - upgrade-check
  - upgrade-build
  # standard build and deploy jobs 
  - build
  - deploy

upgrade-check:
  stage: upgrade-check
  only: [schedules]
  script:
    - yarn outdated
upgrade-build:
  stage: upgrade-build
  only: [schedules]
  script:
    - yarn upgrade --latest
    - yarn test
    - yarn build
  # run this job only if the are updates (upgrade-check failed)
  when: on_failure 


# standard build and deploy jobs definitions
build:
  stage: build
  script:
    - yarn
    - yarn build
  artifacts:
    paths:
      - dist
  except: [schedules]
deploy:
  stage: deploy
  script:
    - ./deploy.sh
  except: [schedules]
```