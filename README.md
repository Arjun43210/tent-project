# Duke Basketball Tenting Test Analyzer

A major tradition at Duke University is tenting for basketball games. Every year, students camp out in K-Ville for weeks to earn spots at the Duke-UNC basketball game. To decide who gets to claim each of the 80 tents in K-Ville, students have to take a tenting test that tests their knowledge of Duke basketball.

This project analyzes scores from tenting tests and ranks groups by their performance (average score per member). Sample test scores and expected outputs are found in the `tests` folder. The code is written in both C and MIPS Assembly.

## C Version
`tent.c` reads an input file of tenting group data, calculates each group’s average score per member, sorts the results, and outputs:
- A ranked list of groups by average score (ties broken alphabetically)
- Total number of people tenting

Implementation
- Reads input with standard C file I/O (`fgets`)
- Dynamic allocation/deallocation of memory
- Stores data in an implemented LinkedList of structs
- Uses a custom function to sort the LinkedList and rank groups
- Always exits with status 0
- Assumes valid input format

## Assembly Version
`tent.s` reads an input of tenting group data directly from the console, calculates each group’s average score per member, sorts the results, and outputs:
- A ranked list of groups by average score (ties broken alphabetically)
- Total number of people tenting

Implementation
- Reads input from the console using `syscall`
- Dynamic allocation/deallocation of memory in the heap
- Follows MIPS calling conventions
- Stores data in an implemented LinkedList
- Uses a custom function to sort the LinkedList and rank groups
- Assumes valid input format

## Conclusion
This assignment combines file processing, struct-based data management, dynamic memory allocation, calling conventions, and custom sorting — a simple but fun way to bring Duke’s tenting spirit into low-level programming. This project was completed as part of Duke University's Computer Architecture (ECE 250) class taught by Rabih Younes.
