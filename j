#define USE_ARDUINO_INTERRUPTS true
#include <SoftwareSerial.h>
#include <Wire.h>
#include <hd44780.h>
#include <hd44780ioClass/hd44780_I2Cexp.h>
#include <Adafruit_MLX90614.h>
#include <PulseSensorPlayground.h>

#define EA 3  //pwm 속도조절
#define EB 11  
#define IN1 4  //방향조절
#define IN2 5  
#define IN3 13  
#define IN4 12  
#define Rsen 8  // 적외선센서
#define Lsen 9  
#define plus 6
#define ok 7

hd44780_I2Cexp lcd;
PulseSensorPlayground pulseSensor;
Adafruit_MLX90614 mlx = Adafruit_MLX90614();

int i=0;
int k=0;
int j=0;
int m=0;
int line=0;
int room;
int menu;

const int PulseWire = analogRead(A0);
const int LED13 = 13; 
int Threshold = 550; 
int period = 500;
int x = 0;
int y = 0;

//심박 하트
byte heart[8]={
0b00000,
0b01010,
0b11111,
0b11111,
0b11111,
0b01110,
0b00100,
0b00000
};//큰하트
byte heart2[8] ={
0b00000,
0b00000,
0b01010,
0b11111,
0b01110,
0b00100,
0b00000,
0b00000
};//작은하트

void setup(){
 Serial.begin(9600);
 
 pinMode(plus, OUTPUT); //+ 하얀색 버튼
 pinMode(ok, OUTPUT); //확인 빨간색 버튼

 pinMode(EA, OUTPUT);  
 pinMode(EB, OUTPUT);  
 pinMode(IN1, OUTPUT); 
 pinMode(IN2, OUTPUT);  
 pinMode(IN3, OUTPUT);  
 pinMode(IN4, OUTPUT);  
 pinMode(Rsen, INPUT);  
 pinMode(Lsen, INPUT);  
 delay(3000);  // 갑작스러운 움직임을 막기위한 3초간 지연

 mlx.begin();
 lcd.init();
 lcd.backlight();
 lcd.setCursor(0,0);
 lcd.print("CONNECTED");
 pinMode(A0,INPUT);

  pulseSensor.analogInput(PulseWire);   
  pulseSensor.blinkOnPulse(LED13);       //auto-magically blink Arduino's LED with heartmyBPM.
  pulseSensor.setThreshold(Threshold);   

  if (pulseSensor.begin()) {
    Serial.println("We created a pulseSensor Object !");  //This prints one time at Arduino power-up,  or on Arduino reset.  
  }
  
}

//무빙 함수
void forward(){
  digitalWrite (IN1, HIGH);
  digitalWrite (IN2, LOW);
  digitalWrite (IN3, LOW);
  digitalWrite (IN4, HIGH);
  analogWrite(EA, 100);
  analogWrite(EB, 100);
}

void back(){
  digitalWrite (IN1, LOW);
  digitalWrite (IN2, HIGH);
  digitalWrite (IN3, HIGH);
  digitalWrite (IN4, LOW);
  analogWrite(EA, 100);
  analogWrite(EB, 130);
}

void left(){
  digitalWrite (IN1, LOW);
  digitalWrite (IN2, LOW);
  digitalWrite (IN3, LOW);
  digitalWrite (IN4, HIGH);
  analogWrite(EA, 100);
  analogWrite(EB, 180);
}


void spin_left(){
  digitalWrite (IN1, LOW);
  digitalWrite (IN2, HIGH);
  digitalWrite (IN3, LOW);
  digitalWrite (IN4, HIGH);
  analogWrite(EA, 40);
  analogWrite(EB, 255);
}

void right(){
  digitalWrite (IN1, HIGH);
  digitalWrite (IN2, LOW);
  digitalWrite (IN3, HIGH);
  digitalWrite (IN4, LOW);
  analogWrite(EA, 150);
  analogWrite(EB, 100);
}

void spin_right(){
  digitalWrite (IN1, HIGH);
  digitalWrite (IN2, LOW);
  digitalWrite (IN3, HIGH);
  digitalWrite (IN4, LOW);
  analogWrite(EA, 200);
  analogWrite(EB, 50);
}

void Stop(){
  digitalWrite (IN1, LOW);
  digitalWrite (IN2, LOW);
  digitalWrite (IN3, LOW);
  digitalWrite (IN4, LOW);
}



void loop(){
  if(m==0){ //움직이기 전 환자 정보 받기
    if(k==0){ //방 번호 고르기
      if(digitalRead(plus)==HIGH){ //하얀색 버튼을 누른다면
        if(i<4){
          i++;
          Serial.print(i);
          Serial.write("\n");
          lcd.home();
          lcd.print(i);
          lcd.print("              ");
          delay(500);
          digitalWrite(plus, LOW);
        }
        else if(i==4){
          i=1;
          Serial.print(i);
          Serial.write("\n");
          lcd.home();
          lcd.print(i);
          lcd.print("              ");
          lcd.home();
          delay(500);
          digitalWrite(plus, LOW);
        }
      }
      if(digitalRead(오케이)==1){ //확인 버튼을 누른다면
        room = i;
        Serial.write("ROOM NUMBER ");
        Serial.print(room);
        Serial.write("\n");
        lcd.home();
        lcd.print("ROOM NUMBER: ");
        lcd.print(i);
        i=0;
        k=1;
        delay(500);
        delay(1000);
        lcd.home();
        lcd.print("SELECT MENU      ");
        digitalWrite(ok, LOW);
      }
    }
    if(k==1){ //메뉴 받기
      if(j==0){
        Serial.write("a. pills only\nb. vital check only\nc. both\nd. none\n");
        j=1;
      }
      if(j==1){
        if(digitalRead(plus)==HIGH){
          if(i<4){
            i++;
            Serial.print(i);
            Serial.write("\n");
            lcd.home();
            lcd.print(i);
            lcd.print("               ");
            delay(1000);
            digitalWrite(plus, LOW);
           }
          else if(i==4){
            i=1;
            Serial.print(i);
            Serial.write("\n");
            lcd.home();
            lcd.print(i);
            lcd.print("               ");
            lcd.home();
            delay(500);
            digitalWrite(plus, LOW);
          }
        }
      if(digitalRead(오케이)==1){ //확인 버튼을 누른다면
        menu = i;
        delay(500);
        digitalWrite(ok, LOW);
        if(i==1){
          Serial.write("a. pills only\n");
          lcd.home();
          lcd.print("PILLS");
        }
        else if(i==2){
          Serial.write("b. vital check only\n");
          lcd.home();
          lcd.print("VITAL CHECK");
        }
        else if(i==3){
          Serial.write("c. both\n");
          lcd.home();
          lcd.print("BOTH");
        }
        else if(i==4){
          Serial.write("d. none\n");
          lcd.home();
          lcd.print("NONE");
        }
        i=0;
        m=1;
      }
    }
  }
 }

 
  if(m==1){ //방까지 움직이기
    if(room==1){ //1번 방 출발
      if(digitalRead(Lsen) == 0 && digitalRead(Rsen) == 0) { //양쪽 흰색
        forward();
       }
    else if(digitalRead(Lsen) == 1 && digitalRead(Rsen) ==1) { //양쪽 검은색
      if(line==0){ //첫 번째 교차로를 만났을 때
        spin_left();
        delay(1500);
        line=1;
      }
      else if(line==1){ //두 번째 교차로를 만났을 때
         Stop();
         lcd.home();
         lcd.print("ARRIVED             ");
         Serial.write("\nARRIVED\n");
         delay(1000);
         m=2;
     }
    }
    else if (digitalRead(Lsen) == 1 && digitalRead(Rsen) ==0) { //보정
      left();
      }
    else if (digitalRead(Lsen) == 0 && digitalRead(Rsen) ==1) { //보정
      right();
      }
    }

    else if(room==2){ //2번 방 출발
      if(digitalRead(Lsen) == 0 && digitalRead(Rsen) == 0) { //양쪽 흰색
        forward();
       }
    else if(digitalRead(Lsen) == 1 && digitalRead(Rsen) ==1) { //양쪽 검은색
      if(line==0){ //첫 번째 교차로를 만났을 때
        spin_right();
        delay(1000);
        line++;
      }
      else if(line==1){ //두 번째 교차로를 만났을 때
        Stop();
        lcd.home();
        lcd.print("ARRIVED             ");
        delay(1000);
        m=2;
      }
    }
    else if (digitalRead(Lsen) == 1 && digitalRead(Rsen) ==0) { //보정
      left();
      }
    else if (digitalRead(Lsen) == 0 && digitalRead(Rsen) ==1) { //보정
      right();
      }
    }
    
    else if(room==3){ //3번 방 출발
      if(digitalRead(Lsen) == 0 && digitalRead(Rsen) == 0) { //양쪽 흰색
        forward();
       }
    else if(digitalRead(Lsen) == 1 && digitalRead(Rsen) ==1) { //양쪽 검은색
      if(line==0){ //첫 번째 교차로를 만났을 때
        forward();
        delay(500);
        line++;
      }
      else if(line==1){ //두 번째 교차로를 만났을 때
        forward();
        delay(90);
        spin_left();
        delay(1000);
        line++;
      }
      else if(line==2){ //세 번째 교차로를 만났을 때
        Stop();
        lcd.home();
        lcd.print("ARRIVED             ");
        delay(1000);
        m=2;
      }
    }
    else if (digitalRead(Lsen) == 1 && digitalRead(Rsen) ==0) { //보정
      left();
      }
    else if (digitalRead(Lsen) == 0 && digitalRead(Rsen) ==1) { //보정
      right();
      }
    }
    
    else if(room==4){ //4번 방 출발
      if(digitalRead(Lsen) == 0 && digitalRead(Rsen) == 0) { //양쪽 흰색
        forward();
       }
    else if(digitalRead(Lsen) == 1 && digitalRead(Rsen) ==1) { //양쪽 검은색
      if(line==0){ //첫 번째 교차로를 만났을 때
        forward();
        delay(500);
        line++;
      }
      else if(line==1){ //두 번째 교차로를 만났을 때
        forward();
        delay(90);
        spin_right();
        delay(1000);
        line++;
      }
      else if(line==2){ //세 번째 교차로를 만났을 때
        Stop();
        lcd.home();
        lcd.print("ARRIVED             ");
        delay(1000);
        m=2;
      }
    }
    else if (digitalRead(Lsen) == 1 && digitalRead(Rsen) ==0) { //보정
      left();
      }
    else if (digitalRead(Lsen) == 0 && digitalRead(Rsen) ==1) { //보정
      right();
      }
    }
  }
  
  else if(m==2){ //메디컬 체크
    lcd.home();
    lcd.print("STARTING...        ");
    Serial.print("STARTING...");
    int a = mlx.readAmbientTempC();
    boolean b = 0;
    int sum = 0;
    double ave = 0;
    if(!b){
    for(int x = 0;i<30;x++) {
      sum = sum + a;
      delay(100);
    }
    ave = sum/30;
    Serial.print("Average :");
    Serial.println(ave);
    }
    Serial.println(a);
    delay(100);

    lcd.init();
    String strTemp = String("");
    strTemp += (double)(mlx.readObjectTempC());
    lcd.setCursor(2,0);
    lcd.print("Temperature");
   lcd.setCursor(5,1);
   lcd.print(strTemp);
   lcd.setCursor(10,1);
   lcd.print("'c");
   delay(10000);

////심박
  int myBPM = pulseSensor.getBeatsPerMinute();
  
  lcd.init();

  if (pulseSensor.sawStartOfBeat()) {            // Constantly test to see if "a myBPM happened".
    Serial.println("♥  A HeartBeat Happened ! "); // If test is "true", print a message "a heartmyBPM happened".
    Serial.print("BPM: ");                        // Print phrase "BPM: " 
    Serial.println(myBPM);                     // Print the value inside of myBPM. 
    double calValue = analogRead(A0); 
    Serial.println(calValue);
    delay(20);
  }
  
  lcd.setCursor(0,0); // 0,0 set
  lcd.print(" Heart Beat ");
  lcd.setCursor(0,1);
  lcd.print(" Monitor ");
  
 
  if(myBPM<100){
   lcd.setCursor(11,1);
   lcd.print(" "); //2자리 수: 공백 1칸
   lcd.print(myBPM);
  else if(myBPM<1000){
    lcd.setCursor(11,1);
    lcd.print(" ");
    lcd.print(myBPM);
  }
   
  lcd.setCursor(10,1);
  lcd.write(0);
 
  while (myBPM>0){
   if (x==0){
     lcd.setCursor(10,1);
     lcd.createChar(0,heart);
     x=1;
    }
    delay(1000);
  
    if(x==1){
     lcd.setCursor(10,1);
     lcd.createChar(0,heart2);
     x=0;
    }
   } 
  delay(10000);
  m=3;
 }
  
  else if(m==3){ //후진
    back();
    delay(2000);
    if(room==1){ //1번 방에서 후진 시작
      if(digitalRead(Lsen)==0 && digitalRead(Rsen)==0){ //양쪽 흰색 때 후진
        back();
      }
      else if(digitalRead(Lsen)==1 && digitalRead(Rsen)==1){ //양쪽 검은색
        spin_left(); //제자리로
        delay(1000);
        m=4;        
      }
      else if (digitalRead(Lsen) == 1 && digitalRead(Rsen) ==0) { //후진 보정
        right();
      }
      else if (digitalRead(Lsen) == 0 && digitalRead(Rsen) ==1) { //후진 보정
        left();
      }
    }
    
    if(room==2){ //2번 방에서 후진 시작
      if(digitalRead(Lsen)==0 && digitalRead(Rsen)==0){ //양쪽 흰색 때 후진
        back();
      }
      else if(digitalRead(Lsen)==1 && digitalRead(Rsen)==1){ //양쪽 검은색
        spin_right(); //제자리로
        delay(1000);
        m=4;        
      }
      else if (digitalRead(Lsen) == 1 && digitalRead(Rsen) ==0) { //후진 보정
        right();
      }
      else if (digitalRead(Lsen) == 0 && digitalRead(Rsen) ==1) { //후진 보정
        left();
      }
    }
    
    if(room==3){ //3번 방에서 후진 시작
      if(digitalRead(Lsen)==0 && digitalRead(Rsen)==0){ //양쪽 흰색 때 후진
        back();
      }
      else if(digitalRead(Lsen)==1 && digitalRead(Rsen)==1){ //양쪽 검은색
        spin_left(); //제자리로
        delay(1000);
        m=4;
        }
      else if (digitalRead(Lsen) == 1 && digitalRead(Rsen) ==0) { //후진 보정
        right();
      }
      else if (digitalRead(Lsen) == 0 && digitalRead(Rsen) ==1) { //후진 보정
        left();
      }
    }
      if(room==4){ //3번 방에서 후진 시작
        if(digitalRead(Lsen)==0 && digitalRead(Rsen)==0){ //양쪽 흰색 때 후진
          back();
        }
        else if(digitalRead(Lsen)==1 && digitalRead(Rsen)==1){ //양쪽 검은색
          spin_right(); //제자리로
          delay(1000);
          m=3;
          }
        else if (digitalRead(Lsen) == 1 && digitalRead(Rsen) ==0) { //후진 보정
          right();
        }
        else if (digitalRead(Lsen) == 0 && digitalRead(Rsen) ==1) { //후진 보정
          left();
        }
      }
  }
  else if(m==4){
    if(digitalRead(Lsen)==0 && digitalRead(Rsen)==0){
          forward();
    }
    if (digitalRead(Lsen) == 1 && digitalRead(Rsen) ==0) { //전진 보정
          left();
    }
    if (digitalRead(Lsen) == 0 && digitalRead(Rsen) ==1) { //전진 보정
          right();
    }
    if (digitalRead(Lsen) == 1 && digitalRead(Rsen) ==1) {
          forward();
    } 
  }
}
