#define UDStepPin 2
#define UDDirPin 3
#define UDEnablePin 4
#define LRStepPin 9
#define LRDirPin 10
#define LREnablePin 11
#define speed 22 //higher speed means a lower ACTUAL speed of the motor default 20
// LR is ROYB color jumpers, UD is GBVG

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
    direction = Serial.read(); // Read the incoming byte
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
        Serial.println("Target reached");
        Serial.flush();
      default:
        digitalWrite(UDEnablePin, HIGH);
        digitalWrite(LREnablePin, HIGH);
        break;
    }
    digitalWrite(UDStepPin, HIGH);
    digitalWrite(LRStepPin, HIGH);
    delay(speed); //speed of a single step.  
    digitalWrite(UDStepPin, LOW);
    digitalWrite(LRStepPin, LOW);
    delay(speed); 
  } 
}
    
