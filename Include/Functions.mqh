//+------------------------------------------------------------------+
//|                                               MovingAverages.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

//+------------------------------------------------------------------+
//| Funcion que coloca el breakeven
//+------------------------------------------------------------------+
double get_price_to_set_breakeven() {
    double distancia = 0;
    if(OrderType() == OP_BUY) {
         distancia =  (OrderOpenPrice() - OrderStopLoss()) * apt_porcentaje_breakeven;
    }
    if(OrderType() == OP_SELL) {
         distancia =  (OrderStopLoss() - OrderOpenPrice()) * apt_porcentaje_breakeven;
    }
    return distancia;
 }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Funcion que calcula los lotes dependiendo del riesgo indicado
//+------------------------------------------------------------------+
double get_lots_by_sl(double sl) {
    double sl_size = 0;
    double lots = 0;
    // Compra
    if(tendencia == 1) {
        sl_size = (Bid-sl)*Point;
    }
    // Venta
    if(tendencia == 2) {
        sl_size = (sl-Ask)*Point;
    }
//    lots = NormalizeDouble(((AccountEquity()*(apt_riesgo*100))/(100*(MarketInfo(Symbol(),MODE_STOPLEVEL)+sl_size)* Point *100000 ))/100,Digits); // Para el oro
    lots = NormalizeDouble((AccountEquity()*(apt_riesgo*100))/(100*(MarketInfo(Symbol(),MODE_STOPLEVEL)+sl_size)* Point *100000 ),Digits);

Print("lots = " + (string)lots);
    if(lots<0.1) {
         lots = 0.1;
    }
    return lots;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que calcula el TP en funcion del SL
//+------------------------------------------------------------------+
double calculate_tp(double order_sl) {
    double result = 0;
    // Compra
    if(tendencia == 1) {
        result = Bid+((Bid-order_sl)*apt_multiplicador_tp);
    }
    // Venta
    if(tendencia == 2) {
        result = Ask-((order_sl-Ask)*apt_multiplicador_tp);
    }
    return result;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que checkea el ultimo pivot point y lo coloca como SL
//+------------------------------------------------------------------+
double calculate_sl() {
    double result = 0;
    // Compra
    if(tendencia == 1) {
        double last_pivot_point = get_last_low_pivot_point();
        result = Bid - ((Bid-last_pivot_point)*apt_multiplicador_sl);
    }
    // Venta
    if(tendencia == 2) {
        double last_pivot_point = get_last_high_pivot_point();
        result = Ask + ((last_pivot_point-Ask)*apt_multiplicador_sl);
    }
    return result;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que devulve los lotes que nos quedan hasta el call out, no la estamos usando ahora
//+------------------------------------------------------------------+
double get_lots() {
  double lots = false;
  //double availableMarginCall = AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
  double lots_to_call = (AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL))/MarketInfo(Symbol(),MODE_MARGINREQUIRED);


  return NormalizeDouble(lots_to_call*0.95,Digits);
  //return 0.1;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que devulve el ultimo pivot low point
//+------------------------------------------------------------------+
double get_last_low_pivot_point() {
double low_pivot = 99999999;
    for(int i=0;i<apt_distancia_pivot_point;i++) {
        if(low_pivot>Low[i]) {
            low_pivot = Low[i];
        }
    }
    return low_pivot;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que devulve el ultimo pivot high point
//+------------------------------------------------------------------+
double get_last_high_pivot_point() {
double high_pivot = 0000000;
    for(int i=0;i<apt_distancia_pivot_point;i++) {
        if(high_pivot<High[i]) {
            high_pivot = High[i];
        }
    }
    return high_pivot;
 }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Devulve el aweso oscilator actual
//+------------------------------------------------------------------+
double get_awesome_actual() {
    return iAO(NULL,0,0);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Devulve el aweso oscilator de la vela anteror
//+------------------------------------------------------------------+
void set_awesome() {
    awesome = iAO(NULL,0,1);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Reiniciamos todos los parametros
//+------------------------------------------------------------------+
void reiniciar_parametros() {
    contador = 0;
    media_atravesada = false;
    rsi_correcto = false;
    awesome_correcto = false;
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Setea el valor de la media en la barra anterior
//+------------------------------------------------------------------+
void set_medias() {
    media_1=get_media(apt_media_1);
    media_2=get_media(apt_media_2);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Devulve el valor de la media en la barra anterior
//+------------------------------------------------------------------+
double get_media(int media) {
    double result = iMA(NULL,0,media,0,MODE_SMA,PRICE_CLOSE,1);
    return(result);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Return the actual tendencia, 1=alcista, 2=bajista
//+------------------------------------------------------------------+
double get_angulo_media() {
    //media_2
    double media_2_antigua = iMA(NULL,0,apt_media_2,0,MODE_SMA,PRICE_CLOSE,apt_media_2);
    double A = media_2 - media_2_antigua;
    double C = apt_media_2; // 200
    return (A/C)*100;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Return the actual tendencia, 1=alcista, 2=bajista
//+------------------------------------------------------------------+
void set_tendencia() {
    // Aqui hay que setear la tendencia dependiendo de la inclinacion de la media m200
//    if(media_1>media_2) {
//         tendencia = 1;
//    } else if(media_1<media_2) {
//        tendencia = 2;
//    }
    tendencia = 0;
    double angulo = get_angulo_media();
    if(angulo>apt_angulo_tendncia) {
         tendencia = 1;
    } else if(angulo<(-apt_angulo_tendncia)) {
        tendencia = 2;
    }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que devuelve true si hay una nueva barra
//+------------------------------------------------------------------+
bool IsNewBarOnChart() {
  bool new_candle = false;
  static datetime lastbar;
  datetime curbar = (datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);

  if(lastbar != curbar) {
    lastbar = curbar;
    new_candle = true;
  }
  return new_candle;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que setea el rsi actual
//+------------------------------------------------------------------+
double get_actual_rsi() {
    return iRSI(NULL,0,14,PRICE_CLOSE,0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que setea el rsi actual
//+------------------------------------------------------------------+
void set_rsi() {
    rsi = iRSI(NULL,0,14,PRICE_CLOSE,0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion chequea si el rsi es correcto para habrir una operación
//+------------------------------------------------------------------+
bool check_rsi() {
    //Alcista
    if(tendencia==1) {
        if(rsi>50) {
            return true;
        }
    }
    //Bajist
    if(tendencia==2) {
        if(rsi<50) {
            return true;
        }
    }
  return false;
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Funcion que setea si se ha atravesado una media
//+------------------------------------------------------------------+
bool check_atraviesa_media() {
    //Alcista
    if(tendencia==1) {
        if(Open[1]<media_1 && Close[1]>media_1) {
            return true;
        }
    }
    //Bajist
    if(tendencia==2) {
        if(Open[1]>media_1 && Close[1]<media_1) {
            return true;
        }
    }
    // si ya tenemos atravies y cambia la tendencia tenemos que desactivar.
  return false;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 2 decimales
//+------------------------------------------------------------------+
double nor2(double value_to_normalize) { 
  return NormalizeDouble(value_to_normalize,2);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 1 decimales
//+------------------------------------------------------------------+
double nor1(double value_to_normalize) { 
  return NormalizeDouble(value_to_normalize,1);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 0 decimales 
//+------------------------------------------------------------------+
double nor0(double value_to_normalize) { 
  return NormalizeDouble(value_to_normalize,0);
}
//+------------------------------------------------------------------+
