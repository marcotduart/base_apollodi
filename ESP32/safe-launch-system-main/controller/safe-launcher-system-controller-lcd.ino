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
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);


#define BotaoEstagio1 12 // GPIO18 pin connected to button
#define BotaoEstagio2 13 // GPIO19 pin connected to button
#define BotaoEstagio3 14 // GPIO21 pin connected to button
#define BotaoEstagio4 18 // GPIO22 pin connected to button
#define BotaoEstagio5 19 // GPIO23 pin connected to button
#define BotaoAbortar 23 // GPIO13 pin connected to button


// REPLACE WITH YOUR RECEIVER MAC Address
//uint8_t broadcastAddress[] = {0x30, 0xAE, 0xA4, 0x8F, 0x78, 0xD8};
//uint8_t broadcastAddress[] = {0x4C, 0xEB, 0xD6, 0x7B, 0x35, 0x6C};
uint8_t broadcastAddress[] = {0x4C, 0xEB, 0xD6, 0x7C, 0x0A, 0x40};


// Structure example to receive data
// Must match the sender structure
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
  bool switch0;
} mensagem2;


esp_now_peer_info_t peerInfo;

// Create a struct_message called myData
mensagem1 reles;
mensagem2 sensores;

int currentState1;     // the current reading from the input pin
int currentState2;     // the current reading from the input pin
int currentState3;     // the current reading from the input pin
int currentState4;     // the current reading from the input pin
int currentState5;     // the current reading from the input pin
int currentState6;     // the current reading from the input pin


//bool estagio1ativado = false;
//bool estagio2ativado = false;
//bool estagio3ativado = false;
//bool estagio4ativado = false;
//bool estagio5ativado = false;

bool botao1pressionado = false;
bool botao2pressionado = false;
bool botao3pressionado = false;
bool botao4pressionado = false;
bool botao5pressionado = false;
bool botao6pressionado = false;



float pressaoAnterior = 0;

//unsigned long tempoAnterior1 = 0;
//unsigned long tempoAnterior2 = 0;
//unsigned long tempoAnterior4 = 0;
//unsigned long tempoAnterior5 = 0;
unsigned long tempoAnterior = millis();





// callback when data is sent
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
  Serial.print("\r\nStatus de envio do último pacote:\t");
  Serial.println(status == ESP_NOW_SEND_SUCCESS ? "Envio com sucesso" : "Falha no envio");
}

// callback function that will be executed when data is received
void OnDataRecv(const uint8_t * mac, const uint8_t *incomingData, int len) {
  memcpy(&sensores, incomingData, sizeof(sensores));
 // Serial.print("Bytes received: ");
  //Serial.println(len);
  //Serial.print("Pressão: ");
  //Serial.println(sensores.pressao);
  //Serial.println();
}
 





void setup() {
  // Initialize Serial Monitor
  Serial.begin(115200);


  lcd.init();
  lcd.backlight();


  pinMode(BotaoEstagio1, INPUT_PULLUP);
  pinMode(BotaoEstagio2, INPUT_PULLUP);
  pinMode(BotaoEstagio3, INPUT_PULLUP);
  pinMode(BotaoEstagio4, INPUT_PULLUP);
  pinMode(BotaoEstagio5, INPUT_PULLUP);
  pinMode(BotaoAbortar, INPUT_PULLUP);


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

    // Once ESPNow is successfully Init, we will register for recv CB to
  // get recv packer info
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

//  lcd.print("Safe Launcher System");
//  lcd.setCursor(0, 1);
//  lcd.print("Sistema Pronto!");

}
 
void loop() {

  if (millis() - tempoAnterior < 2000){

      lcd.setCursor(0, 0);
      lcd.print("Pressao: ");
      lcd.setCursor(9, 0);
      lcd.print(sensores.pressao);

  /*
  Serial.println(millis());
  Serial.println(tempoAnterior);


  Serial.println("Botao 1: ");
  Serial.println(currentState1);

  Serial.println("Botao 2: ");
  Serial.println(currentState2);

    Serial.println("Botao 3: ");
  Serial.println(currentState3);

    Serial.println("Botao 4: ");
  Serial.println(currentState4);

  Serial.println("Botao 5: ");
  Serial.println(currentState5);

*/

 //Acionamento botão 1 - 1º estágio - IGNITAR
  currentState1 = digitalRead(BotaoEstagio1);
  if (currentState1 == 0){
      botao1pressionado = true;
      reles.releEstagio1 = 1;
  }else{
      reles.releEstagio1 = 0;
  }


  if (botao1pressionado == true){
      lcd.setCursor(0, 1);
      lcd.print("1> ");
  }

    

//Acionamento botão 2 - 2º estágio - AGITAR
  currentState2 = digitalRead(BotaoEstagio2);
  if (currentState2 == 0){
     botao2pressionado = true;
     reles.releEstagio2 = 1;
  }else{
      reles.releEstagio2 = 0;
  }


   if (botao2pressionado == true){
      lcd.setCursor(3, 1);
      lcd.print("2> ");
  }


//Acionamento botão 3 - 3º estágio - INCLINAR
  currentState3 = digitalRead(BotaoEstagio3);
  if (currentState3 == 0){
      botao3pressionado = true;
      reles.releEstagio3 = 1;
  }else{
      reles.releEstagio3 = 0;
  }


   if (botao3pressionado == true){
      lcd.setCursor(6, 1);
      lcd.print("3> ");
  }
  
//Acionamento botão 4 - 4º estágio - ALERTAR

currentState4 = digitalRead(BotaoEstagio4);
if (currentState4 == 0){
      botao4pressionado = true;
      reles.releEstagio4 = 1;
  }else{
      reles.releEstagio4 = 0;
  }


if (botao4pressionado == true){
      lcd.setCursor(9, 1);
      lcd.print("4> ");
  }
  

//Acionamento botão 5 - 5º estágio - LANÇAR
  currentState5 = digitalRead(BotaoEstagio5);
  if (currentState5 == 0){
      botao5pressionado = true;
      reles.releEstagio5 = 1;
  }else{
      reles.releEstagio5 = 0;
  }


if (botao5pressionado == true){
      lcd.setCursor(12, 1);
      lcd.print("5> ");
  }
  

//Acionamento botão 6 - ABORTAR
  currentState6 = digitalRead(BotaoAbortar);
  if (currentState6 == 0){
      botao6pressionado = true;
      reles.releAbortar = 1;      
  }else{
      reles.releAbortar = 0;
  }

  if (botao6pressionado == true){
      lcd.setCursor(15, 1);
      lcd.print("A");
  }

// Send message via ESP-NOW
  esp_err_t result = esp_now_send(broadcastAddress, (uint8_t *) &reles, sizeof(reles));
   
 if (result == ESP_OK) {
    Serial.println("Enviado com sucesso");
  }
  else {
    Serial.println("Erro ao enviar dados");
  }
  
    tempoAnterior = millis();


}
 // delay(2000);


}
