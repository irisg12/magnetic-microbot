// Arduino only looping test of all 8 directions 
// Commands sent directly to drivers, no MATLAB serial comm
// v2 allows for easy changes to command order and counts for each direction
// pauses in between direction changes are automatically added

// Vertical and horizontal movement represented by the four cardinal directions NSEW
// diagonal movements: A is northwest, B is northeast, C is southeast, D is southwest
// X represents default case (no movement) 
// F represents full command set completion (relevant for MATLAB serial comm)

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
  int mult = 2; // # of sets of 10 steps each direction repeats for
  int num = 9;  // number of commands, length of char array commands
  
  int n = 10 * mult;
  int s = 10 * mult;
  int e = 10 * mult;
  int w = 10 * mult;
  int a = 10 * mult; 
  int b = 10 * mult; 
  int c = 10 * mult; 
  int d = 10 * mult; 
  int x = 3 * mult;  // 3 step pause between direction changes
  int f = 1;         // terminating character
  int length = n+s+e+w+a+b+c+d+f+x*num; // total command set length

  // directions to execute in order
  char commands[num] =   {'N', 'E', 'S', 'W', 'A', 'B', 'C', 'D', 'F'}; 
  // number of repetitions per character
  int commandcounts[num] = {n, e, s, w, a, b, c, d, f};
  char dir[length];

  int totalchars = 0;
  // populating the char array dir with all commands separated by pauses
  for (int i = 0; i < num; i++) {
    for (int j = 0; j < commandcounts[i]; j++) {
      dir[totalchars++] = commands[i];
    } 
    for (int jx = 0; jx < x; jx++) {
      dir[totalchars++] = 'X';
    }
  }
  
  char direction; // current direction
  for (int i = 0; i < length; i++) {
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
  delay(4000); // delay for 4 seconds between loops
}
