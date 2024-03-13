#include <ArduinoJson.h>
#include <ESP8266WiFi.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <FirebaseArduino.h>

#define WIFI_SSID "Chamith"
#define WIFI_PASSWORD "123456789"
#define FIREBASE_HOST "water-level-751b7-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "sUsUSFPcSDPFlXFzGJAroEmsqdkQ6J7KNU2CLBWW"

#define POWER_PIN  D7
#define SIGNAL_PIN A0
#define red 5
#define blue 4
#define green 0
#define yellow 2

int value = 0;
int water_level;

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");
String epochTime;
String tt;
unsigned long lastTime = 0;
unsigned long timerDelay = 60000;

unsigned long lastTime2 = 0;
unsigned long timerDelay2 = 10000;

void setup() {

  Serial.begin(9600);
  pinMode(POWER_PIN, OUTPUT);
  pinMode(red, OUTPUT);
  pinMode(blue, OUTPUT);
  pinMode(green, OUTPUT);
  pinMode(yellow, OUTPUT);
  digitalWrite(POWER_PIN, LOW);

  digitalWrite(red, HIGH);
  digitalWrite(blue, HIGH);
  digitalWrite(green, HIGH);
  digitalWrite(yellow, HIGH);
  delay(2000);
  digitalWrite(red, LOW);
  digitalWrite(blue, LOW);
  digitalWrite(green, LOW);
  digitalWrite(yellow, LOW);
  delay(2000);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
  timeClient.begin();
  timeClient.setTimeOffset(0);
  timeClient.update();
  epochTime = timeClient.getEpochTime();
  Serial.println(epochTime);
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.setString("/notification/message", "hi");
  Firebase.setBool("/notification/istrue", false);
}

void loop() {

  epochTime = timeClient.getEpochTime();
  tt = epochTime + "000";

  if ((millis() - lastTime) > timerDelay) {
    pushData();
    lastTime = millis();
  }
  if ((millis() - lastTime2) > timerDelay2) {
    Firebase.setInt("/live_data/value", water_level);
    lastTime2 = millis();
  }

  digitalWrite(POWER_PIN, HIGH);
  delay(10);
  value = analogRead(SIGNAL_PIN);
  digitalWrite(POWER_PIN, LOW);
  Serial.print("Sensor value: ");
  Serial.println(value);
  delay(1000);

  water_level = map(value, 9, 440, 0, 100);
  Serial.print("Water Level % : ");
  Serial.println(water_level);

  if (water_level < 10) {
    digitalWrite(red, HIGH);
    digitalWrite(yellow, LOW);
    digitalWrite(green, LOW);
    digitalWrite(blue, LOW);
    Serial.println(" 10%");
  } else if (water_level < 25) {
    digitalWrite(blue, HIGH);
    digitalWrite(red, LOW);
    digitalWrite(yellow, LOW);
    digitalWrite(green, LOW);
    Serial.println(" 25%");
  } else if (water_level < 50) {
    digitalWrite(green, HIGH);
    digitalWrite(blue, LOW);
    digitalWrite(red, LOW);
    digitalWrite(yellow, LOW);
    Serial.println(" 50%");
  } else if (water_level > 75) {
    digitalWrite(yellow, HIGH);
    digitalWrite(green, LOW);
    digitalWrite(blue, LOW);
    digitalWrite(red, LOW);
    Serial.println(" 75%");
  }

}
void pushData() {
  StaticJsonBuffer<200> jsonBuffer2;
  JsonObject& obj2 = jsonBuffer2.createObject();
  obj2["timestamp"] = tt;
  obj2["value"] = water_level;
  Firebase.set("/history/" + tt + "", obj2);
}
