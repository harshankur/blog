---
title: "Code on remote servers with Visual Studio Code via SSH"
date: 2023-08-01T22:59:54+02:00
draft: false
tags: ["programming", "development", "ide", "code"]
categories: ["Programming"]
---

# Introduction

Have you ever struggled with debugging your code on remote servers? There are usually two issues associated with debugging on remote hosting.

1. You are not well versed with terminal-based editors like Vim and Nano
    
2. Coding locally, uploading to GitHub, downloading on remote server, and restarting servers with updating code is tiresome
    

Well, I have the perfect way for you! **You can connect your Visual Studio Code application to your remote server directly via SSH**. It works as if the entire build/deploy environment is on your local machine. You even get command-line access inside Visual Studio Code too.

# Setup

1. Install [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension on [VS-Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
    
2. Click on the Remote Explorer icon on the sidebar of Visual Studio Code
    
3. Click on Configure (gear) icon
    
4. Select the first option
    
5. Enter your remote computer's login info as below into the config file
    
    ```
    Host <name_to_identify_this_instance>
        HostName <domain_or_ip_address_of_instance>
        User <login_user_name>
        IdentityFile <absolute_path _to_.pem_file>
    ```
    
    *An Example of how it looks like*
    
6. Save the file and you should find the newly added **Host** on the Remote Explorer sidebar
    
7. Right-click on the newly added host and click on "Connect to Host in New Window"
    
8. Go ahead with VS Code prompts on SSH connection, select your remote host OS type and open your code location using Open Folder option on the sidebar
    
9. To get access to a terminal on the remote instance, put your mouse cursor at the top of the bottom status bar in blue and pull it up. Or select Terminal &gt; New Terminal from the menu bar.
    
10. Run your code directly on the remote instance, and happy debugging! :)