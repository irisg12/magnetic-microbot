// looping test of all directions 

#define UDStepPin 2 // orange
#define UDDirPin 3 //yellow
#define UDEnablePin 4
#define LRStepPin 9
#define LRDirPin 10
#define LREnablePin 11
#define speed 30 //higher speed means a lower ACTUAL speed of the motor default 20000
// LR is ROYB color jumpers, UD is BWGP

void setup() {
  pinMode(UDStepPin, OUTPUT);
  pinMode(UDDirPin, OUTPUT);
  pinMode(LRStepPin, OUTPUT);
  pinMode(LRDirPin, OUTPUT);
  pinMode(UDEnablePin, OUTPUT);
  pinMode(LREnablePin, OUTPUT);
  //Serial.begin(9600);
}

void loop() 
{
  char direction;
  //char dir[33] = {'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A',  'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A',  'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'X', 'X', 'F'};
  char dir[130] = {'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'X', 'X', 
                  'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'X', 'X', 
                  'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'X', 'X', 
                  'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'X', 'X', 
                  'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'X', 'X', 
                  'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'X', 'X',
                  'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'X', 'X', 
                  'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'X', 'X',
                  'F'}; 
  for (int i = 0; i < 130; i++) {
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
    
