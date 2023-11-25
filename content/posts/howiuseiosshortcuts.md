---
title: "How I use iOS Shortcuts"
date: 2023-11-25T23:36:34+01:00
draft: false
tags: ["scripting", "technology", "development", "iOS", "shortcuts", "automation"]
categories: ["Technology", "Automation"]
---

### What are iOS Shortcuts
Shortcuts is a visual-scripting tool available on the Apple ecosystem which allows users to create macros for executing specific tasks on their device(s). These task sequences can be created by the user and shared online through iCloud.
iOS Shortcuts can be a really powerful tool if it is used properly. It has some very advanced automation and scripting possibilities built into it and its best part is that it is available on a mobile device.\
I use them in the following ways.


### Application
**Background**: I wrote about my setup for View Counter on my RaspberryPi Zero W on this [blog post](https://blog.harshankur.com/posts/howisetupmyviewcounter).

TLDR: I have a MySQL database running on a RaspberryPi Zero W device in my home that is connected to my router. This database is used to keep track of views registered on my online projects.
I am also running a nodejs server on my RaspberryPi that exposes api handlers to accept register view requests on a specific port. All of these servers are behind an nginx reverse proxy.
I have automated all my servers on the device to automatically start after a few seconds of the device's startup.
To allow access to these servers from public internet, I have routed port accesses via my router.

**Challenges**:
1. My router's public ip address tends to change on every restart which it sometimes does when it heats up or there is a problem on my ISP side. This leads to register requests failing from the client side as the ip has changed.
2. My raspberry pi's server might sometimes fail in reboot even though its likelihood is severely low but that has the potential of preventing my views from getting registered.
3. For better security, I have kept my database on the device restricted from direct access from outside. Therefore, it requires me to login to the device and then use sql commands to fetch all the current views which maybe cumbersome sometimes.

**Solution**:
1. I have an iOS shortcut that runs every night at 3am to check if the current ip address of my phone matches a specific address that I have input which was the last public ip address of my router.\
_**This requires following steps**_:
    1. Get's the current wifi address for the phone
    2. Checks if the phone is indeed connected to home wifi.
    3. If the phone is not connected to home wifi, it leaves a notification that the phone was not connected to home wifi.
    4. If the phone was connected to home wifi, it then gets the current ip address. Then, it checks if this ip address matches the last known public ip address of my router.
    5. If the ip matches, it does nothing.
    6. If the ip does not match, it notifies that the ip address has changed to the new one.

Now, if any morning I wake up and find a notification that my ip address has changed, I can immediately login to my domain registrar and update my wifi public address.

![Check Home Ip Address](/checkhomeipaddress.jpeg "Check Home Ip Address")

2. I have an iOS shortcut that runs every night at 3am to get the response of a dummy api request that I have built on my raspberry pi to check if it is reachable.
If it is not, it notifies me that the view counter server was not reachable.\
_**This requires following steps**_:
    1. I have a dummy api handler on my view counter server which returns the client ip address.
    2. The shortcut attempts to get a response of this request.
    3. If it succeeds, it does nothing.
    4. If it fails, it notifies that the view counter backend is not reachable.

Now, if any morning I wake up and find a notification that my view counter backend is not reachable, I can immediately login to my raspberry pi device and diagnose the problem.

![Check ViewCounterBackend](/checkViewCounterBackend.jpeg "Check ViewCounterBackend")

3. I have an iOS shortcut that runs every Saturday at 11am to get the response of a script that I have on my raspberry pi to accumulate db data and show it on my notification.\
_**This requires following steps**_:
    1. I have written a script on my raspberry pi that logins to my database and accumulates the view count for all the tables that I have.
    2. The shortcut attempts to ssh onto the device and runs this script.
    3. If it succeeds, it notifies the current views registered on all my projects.

This helps me keep track of views every week.

![Get View Count](/getViewCount.jpeg "Get View Count")

### Bonus Application

I use the native Make QR Code shortcut to generate QR code of my wifi for friends who visit me.
The text string for such wifi based qr is
```WIFI:S:{SSID};T:WPA;P:{Password};;```

Therefore, one tap of the shortcut and I can easily share my wifi details.

Share how you are using iOS Shortcuts.