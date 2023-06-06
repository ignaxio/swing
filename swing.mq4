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
input int      apt_distancia_pivot_point=15;// lejania del pivot point
input int      apt_multiplicador_tp=3;// TP multiplicador
input double   apt_multiplicador_sl=0.3;// TP multiplicador
input double   apt_riesgo=1;// Porcentaje de riesgo de cuenta
input double   apt_angulo_tendncia=10;// Angulo de media para tendencia
input double   apt_porcentaje_breakeven=0.5;// porcentaje breakeven
input bool     apt_include_compras=true;// Compras
input bool     apt_include_ventas=true;// Ventas

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


// TODO: esperar a que el precio caiga un poco para hacer la entrada, mirar grafica, poner porcentaje de bajada y barras maximas
// Con esto el SL se reduce mucho, subir el TP

// TODO: Cambiar el breakeven por un porcentaje de ganancias... no solo breakeven.


  if(IsNewBarOnChart()) {
    get_angulo_media();
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

  //check_breakeven();

    if(media_atravesada && rsi_correcto) {
        // Compra
        if(apt_include_compras && tendencia == 1 && awesome < 0 && get_awesome_actual() > 0) {
//            compra();
            venta();
        }
        // Venta
        if(apt_include_ventas && tendencia == 2 && awesome > 0 && get_awesome_actual() < 0) {
//            venta();
            compra();
        }
    }

    // El servidor tiene una hora adelantado las 15:00 en el servidor son las 16:00
    
if(Hour()>=9) {
    }
}
//+------------------------------------------------------------------+
