/*

  MAX7219_U8g2.ino
  
  A special example for the MAX7219 based LED display matrix

  Universal 8bit Graphics Library (https://github.com/olikraus/u8g2/)

  Copyright (c) 2016, olikraus@gmail.com
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, 
  are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list 
    of conditions and the following disclaimer.
    
  * Redistributions in binary form must reproduce the above copyright notice, this 
    list of conditions and the following disclaimer in the documentation and/or other 
    materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
  CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  

*/

#include <Arduino.h>
#include <U8g2lib.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <NTPClient.h>
#include <Timezone.h>    // https://github.com/JChristensen/Timezone

#define DEBUG_NTPClient 1

// WiFi Configuration - use build flags or default values
#ifndef WIFI_SSID
#define WIFI_SSID "YOUR_WIFI_SSID"
#endif

#ifndef WIFI_PASSWORD  
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"
#endif

#ifndef NTP_SERVER
#define NTP_SERVER "europe.pool.ntp.org"
#endif

#ifndef GMT_OFFSET_SEC
#define GMT_OFFSET_SEC 3600
#endif

#ifndef BRIGHTNESS
#define BRIGHTNESS 20 // Range for 'value': 0 (no contrast) to 255 (maximum contrast or brightness).
#endif

#ifdef U8X8_HAVE_HW_SPI
#include <SPI.h>
#endif
#ifdef U8X8_HAVE_HW_I2C
#include <Wire.h>
#endif

#define PIN_CLOCK 14
#define PIN_DATA  13
#define PIN_CS    12

#define DISPLAY_HEIGHT   8
#define DISPLAY_WIDTH    8 * 4

#define DISPLAY_SECONDS_OFFSET (DISPLAY_WIDTH - 30) / 2

U8G2_MAX7219_32X8_F_4W_SW_SPI u8g2(U8G2_R0, /* clock=*/ PIN_CLOCK, /* data=*/ PIN_DATA, /* cs=*/ PIN_CS, /* dc=*/ U8X8_PIN_NONE, /* reset=*/ U8X8_PIN_NONE);

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, NTP_SERVER, GMT_OFFSET_SEC, 60000);

// Central European Time (Frankfurt, Paris)
TimeChangeRule CEST = {"CEST", Last, Sun, Mar, 2, 120};     // Central European Summer Time
TimeChangeRule CET = {"CET ", Last, Sun, Oct, 3, 60};       // Central European Standard Time
Timezone CE(CEST, CET);

void wifiInit() {
  Serial.println();
  Serial.print("Looking for Wifi : ");
  Serial.print(WIFI_SSID);
  Serial.println();
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  uint8_t cpt = 1;
  while ( WiFi.status() != WL_CONNECTED ) {
    delay ( 500 );
    Serial.print ( "." );
    if(++cpt % 10 == 0){
      Serial.print(WiFi.status());
      if(cpt % 100 == 0){
        Serial.println();
        Serial.print("Failed Wifi status : ");
        Serial.print(WiFi.status());
        Serial.println();
        ESP.restart();
      }
    }
  }
}

void checkDisplay(uint16 pause) {
  Serial.println("checkDisplay");

  for(int16_t bar_pos_x = 0; bar_pos_x <= DISPLAY_WIDTH; bar_pos_x++) {
    u8g2.clearBuffer();					// clear the internal memory
    u8g2.drawVLine(bar_pos_x, 0, DISPLAY_HEIGHT); // Vertical line
    u8g2.sendBuffer();					// transfer internal memory to the display

    bar_pos_x++;
    delay(pause); 
  }
}

void setup(void) {
  Serial.begin(115200);

  Serial.println("");
  Serial.print("Init on pin:");
  Serial.print(" Clock = ");
  Serial.print(PIN_CLOCK);
  Serial.print(" CS = ");
  Serial.print(PIN_CS);
  Serial.print(" Data = ");
  Serial.print(PIN_DATA);
  Serial.println("");

  u8g2.begin();
  u8g2.setContrast(1); //Range for 'value': 0 (no contrast) to 255 (maximum contrast or brightness).
  u8g2.setFont(u8g2_font_victoriabold8_8r);	// choose a suitable font
  
  Serial.println("Test display");
  checkDisplay(100);

  Serial.println("activating wifi");
  u8g2.clearBuffer();
  u8g2.drawStr(0,7,"WIFI");			// write something to the internal memory
  u8g2.sendBuffer();
  wifiInit();

  Serial.println("activating time client");
  timeClient.begin();
  timeClient.update();

  u8g2.setContrast(BRIGHTNESS); //Range for 'value': 0 (no contrast) to 255 (maximum contrast or brightness).

  Serial.println("setup done");
 }

String buildTimeDisplay(unsigned long rawTime) {
  unsigned long hours = (rawTime % 86400L) / 3600;
  String hoursStr = hours < 10 ? "0" + String(hours) : String(hours);

  unsigned long minutes = (rawTime % 3600) / 60;
  String minuteStr = minutes < 10 ? "0" + String(minutes) : String(minutes);

  return hoursStr + minuteStr;
}

void loop(void) {
  if(WiFi.status() != WL_CONNECTED) {
    wifiInit();
  }
  
  timeClient.update();
  setTime(timeClient.getEpochTime());
  Serial.print(timeClient.getFormattedTime());
  Serial.println();
  
  String timeToDisplay = buildTimeDisplay(CE.toLocal(now()));
  
  int16_t bar_pos;
  int16_t seconds = timeClient.getSeconds();
  if(seconds>30){
    bar_pos = DISPLAY_WIDTH - DISPLAY_SECONDS_OFFSET - (seconds-30);
  }else{
    bar_pos = DISPLAY_SECONDS_OFFSET + seconds;
  }
 
  u8g2.clearBuffer();					// clear the internal memory
  u8g2.drawStr(0,7,timeToDisplay.c_str());			// write something to the internal memory
  u8g2.drawPixel(bar_pos, DISPLAY_HEIGHT - 1);
  u8g2.sendBuffer();					// transfer internal memory to the display

  delay(200);  
}

