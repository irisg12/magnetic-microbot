// Looping test of all directions
// Commands sent directly to stepper drivers

#define UDStepPin 2     // orange
#define UDDirPin 3      // yellow
#define UDEnablePin 4   // white
#define LRStepPin 9     // orange
#define LRDirPin 10     // yellow
#define LREnablePin 11  // white
#define speed 30 //higher speed means a lower ACTUAL speed of the motor default 20000
// LR is ROYB color jumpers, UD is BWGP

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
  int mult = 2;
  int num = 9;
  
  int n = 10 * mult;
  int s = 10 * mult;
  int e = 10 * mult;
  int w = 10 * mult;
  int a = 10 * mult; // A is northwest
  int b = 10 * mult; // B is northeast
  int c = 10 * mult; // C is southeast
  int d = 10 * mult; // D is southwest
  int x = 3 * mult;  // X is a pause/no movement
  int f = 1;         // F is terminating character for serial com
  int length = n+s+e+w+a+b+c+d+f+x*9;
  char commands[num] =   {'N', 'E', 'S', 'W', 'A', 'B', 'C', 'D', 'F'};
  int commandcounts[num] = {n, e, s, w, a, b, c, d, f};
  char dir[length];

  int totalchars = 0;
  // populating the char array dir
  for (int i = 0; i < num; i++) {
    for (int j = 0; j < commandcounts[i]; j++) {
      dir[totalchars++] = commands[i];
    } 
    for (int jx = 0; jx < x; jx++) {
      dir[totalchars++] = 'X';
    }
  }
  
  char direction;
  for (int i = 0; i < length; i++) {
    for(int j = 0; j < 1; j++) {
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
    delay(speed); //speed of a single step.  At high speeds the motion can get very rough.  Consider making speed slower
    digitalWrite(UDStepPin, LOW);
    digitalWrite(LRStepPin, LOW);
    delay(speed); 
    }
  }
  delay(4000); // delay for 4 seconds between loops
}
