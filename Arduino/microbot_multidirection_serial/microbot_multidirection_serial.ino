// Interprets serial communication messages from MATLAB to send
// commands to motor drivers

/* Command interpretation */
// each step in one of 8 directions is encoded as a char:
// Vertical and horizontal movement represented by the four cardinal directions NSEW
// diagonal movements: A is northwest, B is northeast, C is southeast, D is southwest
// X (or other letters) represent default case (no movement) 
// F represents full command set completion (used to terminate MATLAB program and 
// safely disconnect Arduino)
// Arduino uses Serial.read() to pop incoming letters

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
  pinMode(UDEnablePin, OUTPUT);
  pinMode(LRStepPin, OUTPUT);
  pinMode(LRDirPin, OUTPUT);
  pinMode(LREnablePin, OUTPUT);
  Serial.begin(9600);
  digitalWrite(UDEnablePin, HIGH);
  digitalWrite(LREnablePin, HIGH);
}

void loop() 
{
  char direction;
  if (Serial.available() > 0) {
    direction = Serial.read(); // Read the incoming byte into 'direction'

    // code always steps for both motors; 
    //however, if the enable pin is on, current will not be sent to the PCB, turning that direction off
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
        // serial comm with Matlab to indicate Arduino can be disconnected
        Serial.println("Target reached");
        Serial.flush(); 
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
    
