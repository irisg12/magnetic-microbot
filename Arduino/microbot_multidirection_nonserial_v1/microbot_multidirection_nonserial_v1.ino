// Arduino only looping test of all 8 directions 
// Commands sent directly to drivers, no MATLAB serial comm
// Tests 10 steps in each direction with slight pauses in between 

// Vertical and horizontal movement represented by the four cardinal directions NSEW
// diagonal movements: A is northwest, B is northeast, C is southeast, D is southwest
// X represents default case (no movement) 
// F represents command set completion (relevant for MATLAB serial comm)

/* Setup */
// 1x8 header pins should be at the top right of the PCB board
// see Github schematic: pins 1-4 control U/D movement, pins 5-8 control L/R movement

#define UDStepPin 2     // pin to control up/down step timing
#define UDDirPin 3      // direction indicator: N = LOW, S = HIGH
#define UDEnablePin 4   // active low enable

#define LRStepPin 9     // pin to control left/right step timing
#define LRDirPin 10     // direction indicator: E = LOW, W = HIGH
#define LREnablePin 11  // active low enable
#define speed 30        // milliseconds between each L-H or H-L transition

void setup() {
  pinMode(UDStepPin, OUTPUT);
  pinMode(UDDirPin, OUTPUT);
  pinMode(LRStepPin, OUTPUT);
  pinMode(LRDirPin, OUTPUT);
  pinMode(UDEnablePin, OUTPUT);
  pinMode(LREnablePin, OUTPUT);

}

void loop() 
{
  char direction; // current direction
  int length = 130; // total size of char array dir
  char dir[length] = {'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'X', 'X', 
                  'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'X', 'X', 
                  'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'X', 'X', 
                  'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'X', 'X', 
                  'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'X', 'X', 
                  'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'X', 'X',
                  'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'X', 'X', 
                  'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'X', 'X',
                  'F'}; 
  for (int i = 0; i < length; i++) {
    int repeat = 1; 
    for(int j = 0; j < repeat; j++) { // adjust number of times each command is repeated
      direction = dir[i];
      digitalWrite(UDEnablePin, LOW);
      digitalWrite(LREnablePin, LOW);
      switch(direction) {
        case 'N':
          digitalWrite(UDDirPin, LOW);
          digitalWrite(LREnablePin, HIGH);
          break;
        case 'S':
          digitalWrite(UDDirPin, HIGH);
          digitalWrite(LREnablePin, HIGH);
          break;
        case 'W':
          digitalWrite(LRDirPin, HIGH);
          digitalWrite(UDEnablePin, HIGH);
          break;
        case 'E':
          digitalWrite(LRDirPin, LOW);
          digitalWrite(UDEnablePin, HIGH);
          break;
        case 'A':
          digitalWrite(UDDirPin, LOW);
          digitalWrite(LRDirPin, HIGH);
          break;
        case 'B':
          digitalWrite(UDDirPin, LOW);
          digitalWrite(LRDirPin, LOW);
          break;
        case 'C':
          digitalWrite(UDDirPin, HIGH);
          digitalWrite(LRDirPin, LOW);
          break;
        case 'D':
          digitalWrite(UDDirPin, HIGH);
          digitalWrite(LRDirPin, HIGH);
          break;
        case 'F':
          Serial.println("Target reached");
          //Serial.flush();
        default:
          digitalWrite(UDEnablePin, HIGH);
          digitalWrite(LREnablePin, HIGH);
          break;
      }
      digitalWrite(UDStepPin, HIGH);
      digitalWrite(LRStepPin, HIGH);
      delay(speed); 
      digitalWrite(UDStepPin, LOW);
      digitalWrite(LRStepPin, LOW);
      delay(speed); 
    }
  }
  delay(4000); // delay for 4 seconds between loops
}
    
