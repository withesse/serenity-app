package com.serenity.serenity_app

import com.ryanheise.audioservice.AudioServiceFragmentActivity

// AudioServiceFragmentActivity (not AudioServiceActivity): the FlutterActivity
// variant doesn't satisfy the androidx.activity.ComponentActivity cast the
// `health` plugin performs in onAttachedToActivity — manifests at runtime as
// a ClassCastException on Android boot. The Fragment variant provides both
// the lock-screen audio controls and the ComponentActivity contract.
class MainActivity : AudioServiceFragmentActivity()
