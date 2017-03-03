+++
title = ""
bigimg = ""
date = "2014-07-11T10:54:24+02:00"
subtitle = ""
draft = true

+++

```
yarn add firebase
```
```
import * as firebase from 'firebase';

firebase.initializeApp({
  apiKey: YOUR_API_KEY,
  authDomain: "myapp-38151.firebaseapp.com",
  databaseURL: "https://myapp-38151.firebaseio.com",
  storageBucket: "myapp-38151.appspot.com",
  messagingSenderId: "393438054532"
});

```

## Authorization 
```
const provider = new firebase.auth.GoogleAuthProvider();
firebase.auth().onAuthStateChanged((user) => {
  if (user) {
    //Logged in: save user info
    this.user = user;
    // user.uid
  } else {
    firebase.auth().signInWithRedirect(provider);
  }
});
```

## DB

```
firebase.database().ref(`date/${this.user.uid}`).set(dataObject);
```

Online update notifications:
```
firebase.database().ref(`date/${this.user.uid}`).on('value', snapshot => {
  const dataObject = snapshot.val();
  //....
})
```



