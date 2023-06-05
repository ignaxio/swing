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
//input double   apt_porcentaje_breakeven=0.5;// porcentaje breakeven
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

// TODO: No segui con la depuración sin tener mas data, mirar el scrip the data...

// TODO: Poner margen en SL, coger points???.... de momento tengo puesto 4

// TODO: Nos falta ir checkeando que el RSI no se unda... IMPORTANTE

// TODO: V2: Esto ya será otra version.... hay que mover el SL para pillar esas entradas largas. quizás hay que hacer 2 entradas, una cerramos en 2 o 3 y la otra intentamos dejar correr beneficios.
// El 50% de entradas llegan al 1/1 y el 24% 30% llegan a 3/1 y 20% 25% llegan al 4/1  y 10% 17% llegan al 6/1rsi_correcto
// Meter el SL y ir moviendolo, hacer un imput cada cuando mover el SL. Cuando llege al 1 poner breakeven al 2 mover al 1, al 3 mover al 2, al 4 mover al 3, etc....


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
            compra();
        }
        // Venta
        if(apt_include_ventas && tendencia == 2 && awesome > 0 && get_awesome_actual() < 0) {
            venta();
        }
    }

    // El servidor tiene una hora adelantado las 15:00 en el servidor son las 16:00
    
if(Hour()>=9) {
    }
}
//+------------------------------------------------------------------+
