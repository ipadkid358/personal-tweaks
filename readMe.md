## Personal Tweaks

This repo contains a set of tweaks that are parts of other tweaks, and generally not mine to release. Some of the tweaks are from public git repos, that have had their preferences stripped out, or are otherwise optimized. Others have been reversed engineered out of binaries.

Generally these tweaks should not be used on your own device, unless you're sure you know what it does. Many of these projects include hardcoded numbers for Plus sized device

None of this code is licensed by ipad_kid, however no code from this repository should be used without consent from the original author (if applicable), and myself- this goes for original authors as well. Forked repos have their original owner's licensed

The line "Tag: ipadkid::true" has been added to all control files in this repo. This is for my personal tools, and does not impact the package in anyway, nor should it be used on your device or packages

All packages are compiled with the following global Theos variables:

```
TARGET = iphone:10.2:10.2 # personally patched SDK with private framework binaries
ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN # see https://github.com/theos/theos/releases/tag/2.4
```

When compiling, I also pass `FINALPACKAGE=1` for final builds


### Why does this repo exist?

There are two parts to this. The first is that I'm a strong believer in open source. I do my best to open source all of my projects in an effort to share any knowledge I've gained from testing, or other undocumented resources (eg. reverse engineering, runtime analysis)

The second is that I believe iOS is a top-tier OS, and I want it to run like one. Tweaks are different than apps, in that they can inject into Apple processes. If an app has a memory leak, or is generally slow, I'll kill it and move on. If a tweak is loading into all processes linked against UIKit, and causing even a little bit of lag, that's unacceptable to me, because it would be unacceptable to Apple.
