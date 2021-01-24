# System Updater for Cuis Smalltalk

## Description
`System Updater` is a tool for [Cuis Smalltalk](https://github.com/Cuis-Smalltalk/Cuis-Smalltalk-Dev) to automatically 
install and download [updates from GitHub] (https://github.com/Cuis-Smalltalk/Cuis-Smalltalk-Dev/tree/master/CoreUpdates).

It uses the [GitHub Contents API](https://docs.github.com/en/rest/reference/repos#get-repository-content) to download
updates and relies on `ChangeSet installNewUpdates` to install updates.

## Installing
Install the `SystemUpdater.pck.st` package in this repository by dragging and dropping it into your Cuis image, and you'll be good to go.

## Usage Instructions
Click on the `Install New Updates from GitHub` menu item under `World > Open`.

## Feedback 
Feel free to [submit an issue](https://github.com/npapagna/cuis-system-updater/issues) to report bugs, improvements, etc.

Make sure to get in touch if you have any questions about the design, how to make changes, or if you have feature requests.
