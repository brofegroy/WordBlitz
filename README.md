# WordBlitz

## About 
This is a second version of a previous demo version [jaredxwos/wordblitz](https://github.com/JaredXwos/WordBlitz)

## Purpose
Provide a digital alternative for boggle players to train while on the go.

## Features
This mobile application will have a two part functionality, word finding practice and anagram finding.

### Practice mode
The user will be provided with a simulation of a boggle board, to play a 3 min boggle style word search.
After the game, the app will mark the words and provide feedback.

### Anagram Finding
The user will be given a miniature section of the boggle board with best-value triangle of letters.
These best value triangles will be calculated based off the user's dictionary of choice.
Each triangle+letter(s) may or may not contain acceptable words, and the user is to input all the words and be assessed for completeness and accuracy.

### Customisable settings
There will be a configuration page where the user can customise settings such as
- the desired lexicon,e.g. CSW22, and dice types
- custom points scoring
- other graphical settings, such as backgrounds
- and more

## Limitations
- will not support tile sets with more than 1 Q

## Language
This project uses the [flutter](https://flutter.dev/) framework, and is written in the [Dart](https://dart.dev/) Language.

## Style Guide
We should adhere to project structure guidelines and naming conventions enforced by the linter in Android Studio as much as possible.
Example: lowercase snake notation for file names.

## Structure
The project follows the Flutter framework conventions and has a specific structure to organize the code and resources effectively.
The project's source code is located in the **/lib** folder. It contains the main Dart files that comprise the application logic.
For more information, see [~README/STRUCTURE.md](https://github.com/brofegroy/WordBlitz/blob/master/~README/STRUCTURE.md#structure)

## Project ideals

### README for each screen
Ideally we should create a concise and comprehensive README for each screen.
This is to allow collaborators to use the screen, without needing to know exactly how the screen works.
The dedicated README file within each screen's folder should highlights the crucial aspects of how to use the screen such as:
1. **inputs required and how it configures what is rendered**
2. **possible outputs and their associated meanings**
3. **dependencies outside of the screen folder**.
4. **known current/long term bugs** (if applicable)

# How to get started / workflow
1. Send the owner of this repo your Github username, then accept the request to collaborate.
2. Set up flutter on your machine.
3. Clone this repo onto your machine.
4. Mark the section you will be working on in ~README/TODO.md with your username in the **TODO Branch** directly on Github.
5. Make a branch with a relevant name and edit there.
6. Upon completion commit and push into your branch
7. Merge Master into your branch.(since this is a small scale project)
8. Send a pull request to merge your branch into main.

- avoid editing files not marked by you within [~README/TODO.md](https://github.com/brofegroy/WordBlitz/blob/TODO//TODO.md#currently-editing) to reduce merge conflicts.

## If you have anymore questions, feel free to contact the owner of this repo. Happy Coding!
