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
input int      apt_distancia_pivot_point=15;// Media 2

// Varaibles staticas
static double media_1 = 0;
static double media_2 = 0;
static double rsi = 0;
static int tendencia = 0;
static double awesome = 0;
static int contador = 0; // Contador desde que se atrviesa la barra, máximo 10 barras.

static bool media_atravesada = false;
static bool rsi_correcto = false;
static bool awesome_correcto = false;

static bool compra_abierta_barra_actual = false;
static bool venta_abierta_barra_actual = false;

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


// TODO: Poner margen en SL, coger points???....

// TODO: Calcular TP, poner un parametro para definir *2 o *3 o *4 ????

// TODO: Nos falta ir checkeando que el RSI no se unda...

// TODO: Hacer funcion para el riesgo, todas las entradas tiene que llevar el mismo riesgo


  if(IsNewBarOnChart()) {
    compra_abierta_barra_actual = false;
    venta_abierta_barra_actual = false;

    if(contador>8) {
        // Reiniciamos todos los parametros
        reiniciar_parametros();
    }

    set_medias();
    set_tendencia();
    // El primer indicador listo, cuando desactivarlo? cuando vuelva a atravesar se desactiva
    if(check_atraviesa_media()) {
        media_atravesada = true;
         contador++;
    }
    // Ahora el RSI
    set_rsi();
    if(media_atravesada &&  check_rsi()) {
        rsi_correcto = true;
    }
    // Ahora el awesome oscilator, lets do it
    set_awesome();
  }


    if(media_atravesada && rsi_correcto) {
        // Compra
        if(!compra_abierta_barra_actual) {
            if(tendencia == 1 && awesome < 0 && get_awesome_actual() > 0) {
                compra();
            }
        }
        // Venta
        if(!venta_abierta_barra_actual) {
            if(tendencia == 2 && awesome > 0 && get_awesome_actual() < 0) {
                venta();
            }
        }
    }

    // El servidor tiene una hora adelantado las 15:00 en el servidor son las 16:00
    if(Hour()>=16) {
    }
}
//+------------------------------------------------------------------+
