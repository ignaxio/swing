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
static int tendencia = 0;
static bool media_atravesada = false;

#include "./Include/Functions.mqh"


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

// 2- Check ruptura media
// 3- Awesome oscilator

  if(IsNewBarOnChart()) {
    set_medias();
    set_tendencia();
    // El primer indicador listo, cuando desactivarlo? cuando vuelva a atravesar se desactiva
    if(check_atraviesa_media()) {
        media_atravesada = true;
    }
  }
 

  
  // El servidor tiene una hora adelantado las 15:00 en el servidor son las 16:00
  if(Hour()>=16) {
  }
}
//+------------------------------------------------------------------+
