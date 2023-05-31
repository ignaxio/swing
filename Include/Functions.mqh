//+------------------------------------------------------------------+
//|                                               MovingAverages.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"




//+------------------------------------------------------------------+
//| Funcion de compra
//+------------------------------------------------------------------+
bool compra() {
    bool check_order = false;
    int order_id = 0;
    double lots = get_lots();
    //  	double order_tp = tp;
    double order_sl = get_last_low_pivot_point();
    order_id = OrderSend(Symbol(),OP_BUY,lots,Ask,5,order_sl,0,"swing",MAGIC,0,Green);
    if(!order_id) {
        Print("Order send error ",GetLastError());
    } else {
        compra_abierta_barra_actual = true;
    }
  return check_order;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion de compra
//+------------------------------------------------------------------+
bool venta() {
    bool check_order = false;
    int order_id = 0;
    double lots = get_lots();
//  	double order_tp = tp;
    double order_sl = get_last_high_pivot_point();
    order_id = OrderSend(Symbol(),OP_SELL,lots,Bid,5,order_sl,0,"swing",MAGIC,0,Green);
    if(!order_id) {
      Print("Order send error ",GetLastError());
    } else {
        venta_abierta_barra_actual = true;
    }
    return check_order;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que checkea si hay operaciones abieras                                                                |
//+------------------------------------------------------------------+
double get_lots() {
  double lots = false;
  //double availableMarginCall = AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
  double lots_to_call = (AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL))/MarketInfo(Symbol(),MODE_MARGINREQUIRED);


  return NormalizeDouble(lots_to_call*0.1,Digits);
  //return 0.1;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que checkea si hay operaciones abieras                                                                |
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
//| Funcion que checkea si hay operaciones abieras                                                                |
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
//| Reiniciamos todos los parametros
//+------------------------------------------------------------------+
double get_awesome_actual() {
    return iAO(NULL,0,0);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Reiniciamos todos los parametros
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
//| Devulve el valor de la media en la barra anterior
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
void set_tendencia() {
    if(media_1>media_2) {
         tendencia = 1;
    } else if(media_1<media_2) {
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
//| Funcion que retorna el procentaje de rebote
//+------------------------------------------------------------------+
void set_rsi() {
    rsi = iRSI(NULL,0,14,PRICE_CLOSE,0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que retorna el procentaje de rebote
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
//| Funcion que retorna el procentaje de rebote
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
//| Funcion que normalñiza doubles con 2 decimales                                                       |
//+------------------------------------------------------------------+
double nor2(double value_to_normalize) { 
  return NormalizeDouble(value_to_normalize,2);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 1 decimales                                                       |
//+------------------------------------------------------------------+
double nor1(double value_to_normalize) { 
  return NormalizeDouble(value_to_normalize,1);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 0 decimales                                                       |
//+------------------------------------------------------------------+
double nor0(double value_to_normalize) { 
  return NormalizeDouble(value_to_normalize,0);
}
//+------------------------------------------------------------------+
