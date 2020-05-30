# sysprog-gol

## Input
Port 0

Init value is 1111 111 <br>
Port 0.0 -> 0 = start | 1 = wait<br>
Port 0.1 & 0.2 -> binary digit for state number (00, 01, 10, 11)<br>
Port 0.3 -> 1 = random | 0 = looking for state<br>

Examples: 
1111 0000 -> start with state 0<br>
1111 0010 -> start with state 1<br>
1111 0100 -> start with state 2<br>
1111 0110 -> start with state 3<br>
1111 1000 -> start with random state (overwrite state 0)<br>
1111 1100 -> start with random state (overwrite state 3)<br>
1111 XXX1 -> waiting until last bit is 0, checking each seconde<br>

## Output
Port 1 
Port 2

## Field
inti field: x028h - x2Fh
actual: x010
new: x018

## DB
in RAM

## Team
- Init + Input: Jan
- Random: Sebastian
- Calculate states: Nicole
- Multiplex display: Jonathan

## Deadline
**24.06.2020**
