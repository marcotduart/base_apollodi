/*
  Rui Santos
  Complete project details at https://RandomNerdTutorials.com/esp-now-esp32-arduino-ide/
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files.
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
*/

#include <esp_now.h>
#include <WiFi.h>

// REPLACE WITH YOUR RECEIVER MAC Address
//uint8_t broadcastAddress[] = {0x80, 0x7D, 0x3A, 0xBA, 0x3B, 0x04};
uint8_t broadcastAddress[] = {0x4C, 0xEB, 0xD6, 0x7B, 0x33, 0xA0};


// Structure example to send data
// Must match the receiver structure

typedef struct mensagem1 {   
  int releEstagio1;
  int releEstagio2;
  int releEstagio3;
  int releEstagio4;
  int releEstagio5;
  int releAbortar;
} mensagem1;

typedef struct mensagem2 {
  float pressao;
  int switch0;
} mensagem2;


const int sensorPressaoPin = 35; // (INPUT_PRESS)
const int rele1Pin = 33; // COIL_0
const int rele2Pin = 26; // COIL_1
const int rele3Pin = 12; // COIL_2
const int rele4Pin = 27; // COIL_3
const int rele5Pin = 14; // COIL_4
const int rele6Pin = 13; // COIL_5
const int switch0Pin = 15; // 


unsigned long tempoAnterior = 0;
float sensorVal;
float voltageSensor;


// Create a struct_message called myData
mensagem1 reles;
mensagem2 sensores;

esp_now_peer_info_t peerInfo;

// callback when data is sent
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
 // Serial.print("\r\nStatus de envio do último pacote:\t");
 // Serial.println(status == ESP_NOW_SEND_SUCCESS ? "Envio com sucesso" : "Falha no envio");
}

void OnDataRecv(const uint8_t * mac, const uint8_t *incomingData, int len) {
  memcpy(&reles, incomingData, sizeof(reles));
//  Serial.print("Bytes received: ");
//  Serial.println(len);
//  Serial.print("Status Estagio1: ");
//  Serial.println(reles.releEstagio1);
//  Serial.print("Status Estagio2: ");
//  Serial.println(reles.releEstagio2);
//  Serial.print("Status Estagio3: ");
//  Serial.println(reles.releEstagio3);
//  Serial.print("Status ReleBuzina: ");
//  Serial.println(reles.releEstagio4);
//  Serial.print("Status EstagioLancamento: ");
//  Serial.println(reles.releEstagio5);
//  Serial.print("Status ReleAbortar: ");
//  Serial.println(reles.releAbortar);
}
 
 
void setup() {
  // Init Serial Monitor
  Serial.begin(115200);


  pinMode(sensorPressaoPin, INPUT);
  pinMode(switch0Pin, INPUT_PULLUP);
  pinMode(rele1Pin, OUTPUT);     
  pinMode(rele1Pin, OUTPUT);     
  pinMode(rele2Pin, OUTPUT);     
  pinMode(rele3Pin, OUTPUT);     
  pinMode(rele4Pin, OUTPUT);    
  pinMode(rele5Pin, OUTPUT);    
  pinMode(rele6Pin, OUTPUT);


  digitalWrite(rele1Pin, HIGH);  
  digitalWrite(rele2Pin, HIGH);  
  digitalWrite(rele3Pin, HIGH);  
  digitalWrite(rele4Pin, HIGH);  
  digitalWrite(rele5Pin, HIGH);  
  digitalWrite(rele6Pin, HIGH);  
 

 
  // Set device as a Wi-Fi Station
  WiFi.mode(WIFI_STA);

  // Init ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  // Once ESPNow is successfully Init, we will register for Send CB to
  // get the status of Trasnmitted packet
  esp_now_register_send_cb(OnDataSent);
  esp_now_register_recv_cb(OnDataRecv);

  
  // Register peer
  memcpy(peerInfo.peer_addr, broadcastAddress, 6);
  peerInfo.channel = 0;  
  peerInfo.encrypt = false;
  
  // Add peer        
  if (esp_now_add_peer(&peerInfo) != ESP_OK){
    Serial.println("Failed to add peer");
    return;
  }
}
 

void loop() {




if (millis() - tempoAnterior < 2000){

  // Set values to send
    sensores.switch0 = analogRead(switch0Pin);
    
    sensorVal = analogRead(sensorPressaoPin);
    voltageSensor = sensorVal * 3.3 / 4095.0;

    if(voltageSensor < 0.5){
      sensores.pressao = 0; 
    }else{
      sensores.pressao = (voltageSensor - 0.5) / 0.01131;
    }
    
    //sensores.pressao = ((float)voltageSensor - 0.51) * 40.900;

    
//IGNITAR
    if (reles.releEstagio1 == 1){
        digitalWrite(rele1Pin, LOW);
    }else{
      digitalWrite(rele1Pin, HIGH);
    }


//AGITAR
    if (reles.releEstagio2 == 1){
          digitalWrite(rele2Pin, LOW);
    }
    else{
        digitalWrite(rele2Pin, HIGH);
    }
    

//INCLINAR
    if (reles.releEstagio3 == 1 && sensores.switch0 == 0) {
          digitalWrite(rele3Pin, LOW);
      }
        else{
          digitalWrite(rele3Pin, HIGH);
     }
    

//ALERTAR
    if (reles.releEstagio4 == 1){
         digitalWrite(rele4Pin, LOW);
    }else{
          digitalWrite(rele4Pin, HIGH);
    }



//DISPARAR
    if (reles.releEstagio5 == 1){
          digitalWrite(rele5Pin, LOW);
    } else {
          digitalWrite(rele5Pin, HIGH);
    }


//ABORTAR
    if (reles.releAbortar == 1){
        digitalWrite(rele6Pin, LOW);
    }
    else {
        digitalWrite(rele6Pin, HIGH);

    }


}else{


  // Send message via ESP-NOW
  esp_err_t result = esp_now_send(broadcastAddress, (uint8_t *) &sensores, sizeof(sensores));
   
  if (result == ESP_OK) {
    Serial.println("Enviado com sucesso");
  }
  else {
    Serial.println("Erro ao enviar dados");
  }
//    Serial.print("STATUS RELE ESTAGIO1: ");
//    Serial.println(reles.releEstagio1);
  tempoAnterior = millis();


}
//  delay(2000);
}
