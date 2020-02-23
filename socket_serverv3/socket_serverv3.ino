#include <ESP8266WiFi.h>
#include <Wire.h>

int incomingByte = 0; // for incoming serial data
int bufflen = 0;// count of serial inputs
int maxbytes=4;
String rxbuff;
int rxcount=0;
byte txbuff[32000];
byte xbuff[4];
int txcount=0;
int curpos=0;
int first=0;
const char* ssid = "VM4705704";
const char* password =  "xdTcwwgW3gbg";
char mysend;
String sendstring;
WiFiServer wifiServer(80);

void setup() {
  Wire.begin(4);                // join i2c bus with address #4
  Wire.onReceive(receiveEvent); // register events
  Wire.onRequest(requestEvent);
  Serial.begin(9600);
 
  delay(1000);
  
  WiFi.begin(ssid, password);
 
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }
 
  Serial.println("Connected to the WiFi network");
  Serial.println(WiFi.localIP());
  Wire.write("Network Connected");
  wifiServer.begin();
}
 
void loop() {
 
  WiFiClient client = wifiServer.available();
 
  if (client) {
        Serial.println("Client Connected \r\n");
        while (client.connected()) 
        {
          if (Serial.available()>0) 
              {
                incomingByte=Serial.read();
                client.write(incomingByte);
                //for (int i=0;i<32;i++)
                //{
               // Serial.printf("%d,",txbuff[i]);
               // }
              }
  
         while (client.available()>0) 
              {
                byte s=client.read();
                txbuff[txcount] = s;
                
                txcount++;
              }
          

        if (rxcount!=0)
        {
              //Serial.write(rxbuff);
             client.write(rxbuff.c_str());
            rxbuff="";
            rxcount=0;
        } 
        
       delay(10);
  }
    client.stop();
    Serial.println("Client disconnected");
    curpos=0;
    txcount=0;
    rxcount=0;
    first=0;
    rxbuff="";
    Wire.flush();
  }
}

void receiveEvent(int howMany)
{
  for (int i=0;i<howMany;i++)
  {
  char rx=Wire.read();
  rxbuff=rxbuff+rx;
  rxcount++;
  }
}

void requestEvent()
{ 
     if(txcount>0)
     {
            if(txcount<=maxbytes)
      {
           
           memmove(xbuff,txbuff+curpos,maxbytes);
           Wire.write(xbuff,maxbytes);
           Wire.flush();
           txcount=0;
           curpos=0;
      }
      else
      {
           memmove(xbuff,txbuff+curpos,maxbytes);
           Wire.write(xbuff,maxbytes);
           Wire.flush();
           //Serial.write(xbuff,maxbytes);
        txcount=txcount-maxbytes;
        curpos=curpos+maxbytes;
       }
     }
     else
     {
     txcount=0;
     curpos=0;
     }

     
  
}
