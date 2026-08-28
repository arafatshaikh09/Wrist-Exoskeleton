#include <DynamixelShield.h>

const uint8_t MOTOR_1 = 1; // Top Extensor
const uint8_t MOTOR_2 = 2; // Middle (Right/Pinky side) -> INVERTED SPOOL
const uint8_t MOTOR_3 = 3; // Furthest (Left/Thumb side) -> STANDARD SPOOL

const float DXL_PROTOCOL_VERSION = 2.0;
DynamixelShield dxl;

const int CENTER_1 = 2300; 
const int CENTER_2 = 2048;
const int CENTER_3 = 2048;

void setup() {
  Serial.begin(115200); 
  Serial1.begin(9600);  

  dxl.begin(57600);
  dxl.setPortProtocolVersion(DXL_PROTOCOL_VERSION);

  uint8_t motor_ids[] = {MOTOR_1, MOTOR_2, MOTOR_3};
  for(int i = 0; i < 3; i++) {
    if(dxl.ping(motor_ids[i])) {
      dxl.torqueOff(motor_ids[i]);
      dxl.setOperatingMode(motor_ids[i], OP_POSITION);
      dxl.torqueOn(motor_ids[i]);
    }
  }
  
  dxl.setGoalPosition(MOTOR_1, CENTER_1);
  dxl.setGoalPosition(MOTOR_2, CENTER_2);
  dxl.setGoalPosition(MOTOR_3, CENTER_3);
  Serial.println("Mega Ready. Max Limits & Corrected Thumb/Pinky Logic Active.");
}

void loop() {
  if (Serial1.available() > 0) {
    char command = Serial1.read();

    if (command == 'E') {
      // EXTENSION: Max pull on top motor, max loosen on bottom motors
      dxl.setGoalPosition(MOTOR_1, 4000); // M1 Max Pull (Standard)
      dxl.setGoalPosition(MOTOR_2, 4000); // M2 Max Loosen (Inverted)
      dxl.setGoalPosition(MOTOR_3, 100);  // M3 Max Loosen (Standard)
    } 
    else if (command == 'F') {
      // FLEXION: Loosen top motor, max pull on bottom motors
      dxl.setGoalPosition(MOTOR_1, 100);  // M1 Max Loosen 
      dxl.setGoalPosition(MOTOR_2, 100);  // M2 Max Pull (Inverted)
      dxl.setGoalPosition(MOTOR_3, 4000); // M3 Max Pull (Standard)
    } 
    else if (command == 'A') {
      // THUMB SIDE (Radial Deviation): Pull M3, Loosen M2
      dxl.setGoalPosition(MOTOR_1, CENTER_1); 
      dxl.setGoalPosition(MOTOR_2, 4000); // M2 Loosens (Inverted High)
      dxl.setGoalPosition(MOTOR_3, 4000); // M3 Pulls (Standard High)
    }
    else if (command == 'D') {
      // PINKY SIDE (Ulnar Deviation): Pull M2, Loosen M3
      dxl.setGoalPosition(MOTOR_1, CENTER_1); 
      dxl.setGoalPosition(MOTOR_2, 100);  // M2 Pulls (Inverted Low)
      dxl.setGoalPosition(MOTOR_3, 100);  // M3 Loosens (Standard Low)
    }
    else if (command == 'C') {
      // CENTER
      dxl.setGoalPosition(MOTOR_1, CENTER_1);
      dxl.setGoalPosition(MOTOR_2, CENTER_2);
      dxl.setGoalPosition(MOTOR_3, CENTER_3);
    }
  }
}