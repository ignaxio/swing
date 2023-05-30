//+------------------------------------------------------------------+
//|                                                   SWING strategy |
//|                                                    Ignacio Farre |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Ignacio Farre"
#property link      ""
#property version   "2.00"
#property strict

#define MAGIC  222

//--- input parameters
input int      apt_media_1=20;// Media 1
input int      apt_media_2=200;// Media 2

// Varaibles staticas
static double media_1 = 0;
static double media_2 = 0;




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {


//El precio tiene que atravesar la m20
//La m20 tiene que estar en tendencia con m200
//Awesome oscillator tiene que cambiar de tendencia
//A la hora de la entrada chequear que el RSI no haya caído más de 53
//Entradas con 1 SL 3 TP. hacer pruebas con 1SL 2TP
//Hacer pruebas con Breakeven…

// 1- Asignaremos tendencia
// 2- Check ruptura media
// 3- Awesome oscilator

  if(IsNewBarOnChart()) {
    media_1=nor1(iMA(NULL,0,apt_media_1,0,MODE_SMA,PRICE_CLOSE,1));
    media_2=nor1(iMA(NULL,0,apt_media_2,0,MODE_SMA,PRICE_CLOSE,1));
  }
 

  
  // El servidor tiene una hora adelantado las 15:00 en el servidor son las 16:00
  if(Hour()>=16) {
  }
}
//+------------------------------------------------------------------+
