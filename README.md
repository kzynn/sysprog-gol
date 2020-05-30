# sysprog-gol

## Input
Port 0

Init value is 1111 111
Port 0.0 -> 0 = start | 1 = wait
Port 0.1 & 0.2 -> binary digit for state numer (00, 01, 10, 11)
Port 0.3 -> 1 = random | 0 = looking for state

Examples: 
1111 0000 -> start with state 0
1111 0010 -> start with state 1
1111 0100 -> start with state 2
1111 0110 -> start with state 3
1111 1000 -> start with random state (overwrite state 0)
1111 1100 -> start with random state (overwrite state 3)
1111 XXX1 -> waiting until last bit is 0, checking each seconde

## Output
Port 1 
Port 2

## Field
inti field: x028h - x2Fh
actual: x010
new: x018

## DB
x300h

## Team
- Init + Input: Jan
- Random: Sebastian
- Calculate states: Nicole
- Multiplex display: Jonathan

## Deadline
**24.06.2020**
