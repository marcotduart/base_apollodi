#include <Wire.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

BLECharacteristic *characteristicTX; // Através desse objeto iremos enviar dados para o client

bool deviceConnected = false; // Controle de dispositivo conectado

// Definindo o pino do LED
const int LED = 2;  // LED interno do ESP32

int estadoLED = 0;

#define SERVICE_UUID   "ab0828b1-198e-4351-b779-901fa0e0371e"
#define CHARACTERISTIC_UUID_RX  "4ac8a682-9736-4e5d-932b-e9b31405049c"
#define CHARACTERISTIC_UUID_TX  "0972EF8C-7613-4075-AD52-756F33D4DA91"

// Callback para eventos das características
class CharacteristicCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *characteristic) {
        String value = characteristic->getValue();
        std::string rxValue = value.c_str();
        if (rxValue.length() > 0) {
            for (int i = 0; i < rxValue.length(); i++) {
                Serial.print(rxValue[i]);
            }
            Serial.println();
            // Controle do LED
            if (rxValue.find("L1ON") != std::string::npos) { 
                digitalWrite(LED, HIGH);
            } else if (rxValue.find("L1OFF") != std::string::npos) {
                digitalWrite(LED, LOW);
            }
        }
    }
};

// Callback para receber os eventos de conexão de dispositivos
class ServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
        pServer->startAdvertising();
    }
};

void setup() {
    Serial.begin(115200);

    // Inicializando o pino do LED como saída
    pinMode(LED, OUTPUT);

    // Create the BLE Device
    BLEDevice::init("MBFOG-IFRN-AP"); // Nome do dispositivo Bluetooth

    // Create the BLE Server
    BLEServer *server = BLEDevice::createServer(); // Cria um BLE server 

    server->setCallbacks(new ServerCallbacks()); // Seta o callback do server

    // Create the BLE Service
    BLEService *service = server->createService(SERVICE_UUID);

    // Create a BLE Characteristic para envio de dados
    characteristicTX = service->createCharacteristic(
                       CHARACTERISTIC_UUID_TX,
                       BLECharacteristic::PROPERTY_NOTIFY
                     );

    characteristicTX->addDescriptor(new BLE2902());

    // Create a BLE Characteristic para recebimento de dados
    BLECharacteristic *characteristic = service->createCharacteristic(
                                                      CHARACTERISTIC_UUID_RX,
                                                      BLECharacteristic::PROPERTY_WRITE
                                                    );

    characteristic->setCallbacks(new CharacteristicCallbacks());

    // Start the service
    service->start();

    // Start advertising (descoberta do ESP32)
    server->getAdvertising()->start();

    Serial.println("Aguardando algum dispositivo conectar...");
}

void loop() {
    // Se existe algum dispositivo conectado
    if (deviceConnected) {
        estadoLED = digitalRead(LED);

        // Conversão do estado do LED para string
        char txString[16];
        snprintf(txString, sizeof(txString), "L1:%d", estadoLED);

        characteristicTX->setValue(txString); // Seta o valor que a característica notificará (enviar)
        characteristicTX->notify(); // Envia o valor para o smartphone
    } else {
        Serial.println("Dispositivo Desconectado...");
    }

    delay(1000);
}
