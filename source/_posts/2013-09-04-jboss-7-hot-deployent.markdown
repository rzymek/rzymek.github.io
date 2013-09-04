---
layout: post
title: "JBoss 7 hot deployent"
date: 2013-09-04 14:29
comments: true
categories: 
---

JBoss 7 offers very fast redeployment. There are a few ways to trigger it.
Let's say you want to redeploy `my.war`

### Redeploying using the filesystem

    cp my.war $JBOSS7/standalone/deployments/
    touch $JBOSS7/standalone/deployments/my.war.dodeploy

### 
