'From Cuis 5.0 [latest update: #4402] on 31 January 2021 at 2:09:42 pm'!
'Description '!
!provides: 'SystemUpdater' 1 6!
!requires: 'WebClient' 1 20 nil!
!requires: 'JSON' 1 19 nil!
SystemOrganization addCategory: 'SystemUpdater'!


!classDefinition: #SUGitHubUpdateFileEntry category: 'SystemUpdater'!
Object subclass: #SUGitHubUpdateFileEntry
	instanceVariableNames: 'name version renameMe1 contentsUrl'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SystemUpdater'!
!classDefinition: 'SUGitHubUpdateFileEntry class' category: 'SystemUpdater'!
SUGitHubUpdateFileEntry class
	instanceVariableNames: ''!

!classDefinition: #SUGitHubUpdatesDirectoryEntry category: 'SystemUpdater'!
Object subclass: #SUGitHubUpdatesDirectoryEntry
	instanceVariableNames: 'name'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SystemUpdater'!
!classDefinition: 'SUGitHubUpdatesDirectoryEntry class' category: 'SystemUpdater'!
SUGitHubUpdatesDirectoryEntry class
	instanceVariableNames: ''!

!classDefinition: #SUSystemUpdater category: 'SystemUpdater'!
Object subclass: #SUSystemUpdater
	instanceVariableNames: 'sourceUpdatesDirectory localUpdatesDirectory systemVersionToUpdate updateDialog cancelUpdate savingUpdatesProgressIncrement'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SystemUpdater'!
!classDefinition: 'SUSystemUpdater class' category: 'SystemUpdater'!
SUSystemUpdater class
	instanceVariableNames: ''!


!SUGitHubUpdateFileEntry methodsFor: 'actions-file' stamp: 'NPM 1/23/2021 21:03:46'!
copyTo: aDirectory

	(aDirectory // name) forceWriteStreamDo: [ :contents |
		contents nextPutAll: self fileContents ]! !

!SUGitHubUpdateFileEntry methodsFor: 'actions-file' stamp: 'NPM 1/23/2021 02:49:21'!
fileContents
	
	^ (WebClient httpGet: contentsUrl) content! !

!SUGitHubUpdateFileEntry methodsFor: 'initialization' stamp: 'NPM 1/23/2021 02:49:21'!
initializeNamed: aName contentsAt: anUrl 
	
	name := aName.
	contentsUrl := anUrl.
	
	self initializeVersion.! !

!SUGitHubUpdateFileEntry methodsFor: 'initialization' stamp: 'NPM 1/23/2021 03:08:28'!
initializeVersion
	
	"The version is the first token (separated by -) in update filenames.
	
	e.g. 3960-NewInstVarPreconditionForSuperclass-HernanWilkinson-2019Nov12-15h55m-HAW.1.cs.st"
	
	version := (name findTokens: $-) first asNumber! !

!SUGitHubUpdateFileEntry methodsFor: 'testing' stamp: 'NPM 1/23/2021 21:54:06'!
isInstalled: aSystemVersion 
	
	^ version <= (aSystemVersion highestUpdate)! !

!SUGitHubUpdateFileEntry class methodsFor: 'instance creation' stamp: 'NPM 1/23/2021 02:49:10'!
named: aName contentsAt: anUrl 
	
	^ self
		new
		initializeNamed:aName
		contentsAt: anUrl! !

!SUGitHubUpdatesDirectoryEntry methodsFor: 'accessing' stamp: 'NPM 1/23/2021 22:16:43'!
files
	
	| response updatesData |
	response := WebClient httpGet: 'https://api.github.com/repos/Cuis-Smalltalk/Cuis-Smalltalk-Dev/contents/', name.
	
	updatesData := Json readFrom: (ReadStream on: response content).
	
	^ updatesData collect: [ :updateData |
		SUGitHubUpdateFileEntry
			named: updateData name
			contentsAt: updateData download_url ]! !

!SUGitHubUpdatesDirectoryEntry methodsFor: 'enumeration' stamp: 'NPM 1/23/2021 20:49:56'!
filesMatches: selectionBlock

	^ self files select: selectionBlock! !

!SUGitHubUpdatesDirectoryEntry methodsFor: 'initialization' stamp: 'NPM 1/23/2021 20:48:58'!
initializeNamed: aName 
	
	name := aName.! !

!SUGitHubUpdatesDirectoryEntry class methodsFor: 'instance creation' stamp: 'NPM 1/23/2021 20:48:44'!
named: aName
	
	^ self
		new
		initializeNamed: aName! !

!SUSystemUpdater methodsFor: 'evaluating' stamp: 'NPM 1/23/2021 21:11:38'!
value

	"Run in background to avoid blocking the UI when a large amount of files have to be downloaded"
	[ self updateSystem ] fork! !

!SUSystemUpdater methodsFor: 'initialization' stamp: 'NPM 1/23/2021 21:52:43'!
initializeUpdatingFrom: aSourceUpdatesDirectory savingUpdatesTo: aLocalUpdatesDirectory toUpdate: aSystemVersion 
	
	sourceUpdatesDirectory _ aSourceUpdatesDirectory.
	localUpdatesDirectory _ aLocalUpdatesDirectory.
	systemVersionToUpdate _ aSystemVersion.
	
	self initializeDialog.
	! !

!SUSystemUpdater methodsFor: 'system update' stamp: 'NPM 1/23/2021 02:58:03'!
cancelUpdate
	
	cancelUpdate := true! !

!SUSystemUpdater methodsFor: 'system update' stamp: 'NPM 1/23/2021 21:52:26'!
checkForUpdates
	
	self displayCheckingForUpdatesMessage.

	^ (sourceUpdatesDirectory filesMatches: [ :updateFile | (updateFile isInstalled: systemVersionToUpdate) not ])! !

!SUSystemUpdater methodsFor: 'system update' stamp: 'NPM 1/31/2021 14:08:54'!
installNewUpdates

	cancelUpdate ifFalse: [	
		UISupervisor whenUIinSafeState: [ ChangeSet installNewUpdates ] ]! !

!SUSystemUpdater methodsFor: 'system update' stamp: 'NPM 1/23/2021 21:55:59'!
saveNewUpdates
	
	self checkForUpdates
		ifNotEmpty: [ :newUpdates | self saveUpdates: newUpdates ]! !

!SUSystemUpdater methodsFor: 'system update' stamp: 'NPM 1/23/2021 21:50:56'!
saveUpdates: updateFiles 
	
	self displaySavingUpdatesProgressBar: updateFiles size.

	updateFiles
		do: [ :updateFile |
			updateFile copyTo: localUpdatesDirectory.
			self advanceSavingUpdatesProgressBar ]
		separatedBy: [
			cancelUpdate ifTrue: [ ^ self ] ]! !

!SUSystemUpdater methodsFor: 'system update' stamp: 'NPM 1/23/2021 21:47:45'!
updateSystem

	[
		self
			saveNewUpdates;
			installNewUpdates
	] ensure: [
		self close
	]! !

!SUSystemUpdater methodsFor: 'ui' stamp: 'NPM 1/23/2021 21:51:23'!
advanceSavingUpdatesProgressBar
	
	updateDialog incrDone: savingUpdatesProgressIncrement ! !

!SUSystemUpdater methodsFor: 'ui' stamp: 'NPM 1/23/2021 02:33:08'!
close
	
	UISupervisor whenUIinSafeState: [ updateDialog dismissMorph ]! !

!SUSystemUpdater methodsFor: 'ui' stamp: 'NPM 1/23/2021 21:50:00'!
displayCheckingForUpdatesMessage
	
	updateDialog
		subLabel: 'Checking for updates...';
		openInWorld ! !

!SUSystemUpdater methodsFor: 'ui' stamp: 'NPM 1/23/2021 21:51:33'!
displaySavingUpdatesProgressBar: numberOfUpdatesToDownload
	
	updateDialog subLabel: ('Saving {1} updates...' format: { numberOfUpdatesToDownload }).
	savingUpdatesProgressIncrement := 1 / numberOfUpdatesToDownload.! !

!SUSystemUpdater methodsFor: 'ui' stamp: 'NPM 1/23/2021 21:58:36'!
initializeDialog

	| cancelButton |
	cancelUpdate _ false.
	updateDialog  _ ProgressMorph label: 'System Updater'.
	
	cancelButton := PluggableButtonMorph
			model: self
			action: #cancelUpdate
			label: 'Cancel'.
	
	updateDialog addMorph: cancelButton.! !

!SUSystemUpdater class methodsFor: 'evaluating' stamp: 'NPM 1/23/2021 02:53:24'!
value

	self
		toUpdateCurrentVersion
		value! !

!SUSystemUpdater class methodsFor: 'instance creation' stamp: 'NPM 1/23/2021 22:16:50'!
toUpdateCurrentVersion
	
	^ self
		new
		initializeUpdatingFrom: (SUGitHubUpdatesDirectoryEntry named: 'CoreUpdates')
		savingUpdatesTo: (DirectoryEntry smalltalkImageDirectory / 'CoreUpdates')
		toUpdate: SystemVersion current! !

!SUSystemUpdater class methodsFor: 'menu-world' stamp: 'NPM 1/23/2021 22:05:49'!
worldMenuForOpenGroup

	^ `{{
			#itemGroup    -> 20.
			#itemOrder    -> 21.
			#label 			-> 'Install New Updates from GitHub'.
			#object 			-> SUSystemUpdater .
			#selector 		     -> #value.
			#icon 			-> #updateIcon.
			#balloonText 	-> 	'Downloads and installs new updates from GitHub'.
		} asDictionary}`! !
