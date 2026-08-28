#include <Wire.h>
#include "SparkFun_BMI270_Arduino_Library.h"

BMI270 imu;
float smoothPitch = 0;
float smoothYaw = 0; // Replaces 'Roll' to track flat left/right movement
unsigned long lastTime = 0;

uint8_t i2cAddress = BMI2_I2C_PRIM_ADDR; // 0x68

void setup() {
    Serial.begin(115200);
    Serial1.begin(9600);
    Wire.begin();
    
    while(imu.beginI2C(i2cAddress) != BMI2_OK) {
        Serial.println("Error: BMI270 not connected!");
        delay(1000);
    }
    Serial.println("BMI270 connected! Gyro Yaw Tracking Active.");
    lastTime = millis();
}

void loop() {
  imu.getSensorData();

  // 1. Calculate time passed (dt) for the Gyroscope
  unsigned long currentTime = millis();
  float dt = (currentTime - lastTime) / 1000.0;
  lastTime = currentTime;

  // 2. PITCH (Up/Down) using Accelerometer
  float ax = imu.data.accelX;
  float ay = imu.data.accelY;
  float az = imu.data.accelZ;
  float rawPitch = atan2(-ax, sqrt(ay * ay + az * az)) * 180.0 / PI;
  smoothPitch = (0.2 * rawPitch) + (0.8 * smoothPitch);

  // 3. YAW (Left/Right) using Z-Axis Gyroscope
  float gz = imu.data.gyroZ;
  if (abs(gz) > 2.0) { 
      smoothYaw += (gz * dt); // Integrate rotation into position
  } else {
      smoothYaw = smoothYaw * 0.95; // Auto-center when stopped
  }

  Serial.print("Pitch: "); Serial.print(smoothPitch, 1);
  Serial.print(" | Yaw: "); Serial.print(smoothYaw, 1);

  // --- 4-WAY EXOSKELETON LOGIC ---
  if (smoothPitch > 15.0) {
    Serial1.write('E'); 
    Serial.println(" -> EXTEND");
  } 
  else if (smoothPitch < -15.0) {
    Serial1.write('F'); 
    Serial.println(" -> FLEX");
  } 
  else if (smoothYaw > 15.0) {
    Serial1.write('A'); // Abduction (Thumb/Radial)
    Serial.println(" -> RADIAL TILT (Left)");
  }
  else if (smoothYaw < -15.0) {
    Serial1.write('D'); // Adduction (Pinky/Ulnar)
    Serial.println(" -> ULNAR TILT (Right)");
  }
  else {
    Serial1.write('C'); 
    Serial.println(" -> CENTER");
  }

  delay(50);
}