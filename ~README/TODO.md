# TODO title
Welcome to the TODO file instructions!
The file serves as a guide to track the progress of the project and assign tasks to collaborators.
Here is where you can get started and contribute to the project.

If you are looking for the actual [active TODO.md](https://github.com/brofegroy/WordBlitz/blob/TODO/TODO.md#currently-editing),
it is in the TODO branch of this repo, master branch's TODO.md only serves as instructions on how to use that TODO.
This is to reduce the number of commits that is just dedicated to updating file usage states.

## How to declare files
1. Put your github username/ IRL alias(that other contributors know) next to the folder you want to edit.
2. Demarcate it with a "<- github_username is working on this". this will let other know you are still working on the folder.
3. If you feel that a certain folder really should not be edited in the meantime while you edit it, you may demarcate it with a "\*<-\*", this will emphasise to others that it should not be edited in the meantime.
4. Also remember to mark what you are doing inside the **TODO Overview** section below

This is just a way to keep track of who is working on what so that there is less merge conflicts overall.
**You may still edit unmarked files if you need to.**
add in the list if the file or folder you wish to edit is not already in the list 

### Currently Editing example
#### Example_Folder1 In /lib
- example_screen <- ExampleBotUsername is working on this //they are working on this file,editing this file may cause merge conflicts
- example_screen_controller <- ExampleBotUsername is working on this //they are currently only working on the screen and controller, meaning you may still edit the controller if you wish to.
- example_screen2/ <- ExampleBotUsername2 is working on this //they are editing the entire folder. editing items within this folder may result in merge conflicts.
- example_screen3/ *<-* ExampleBotUsername is working on this //they don't want you to edit this
- 
#### Example_Folder2
- example_tool3 <- ExampleBotUsername and ExampleBotUsername2 is working on this //two people are working on this file at the same time,and they discussed which parts of the folder they will edit with each other, to minimise merge conflicts.
- //if the folder ExampleBotUsername2 want to edit is not referenced in this list yet, meaning nobody is editing it at the moment. they should add onto this empty bulletpoint the folder or file name they wish to edit.
-