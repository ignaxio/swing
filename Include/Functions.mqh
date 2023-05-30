//+------------------------------------------------------------------+
//|                                               MovingAverages.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| Return the actual tendencia, 1=alcista, 2=bajista
//+------------------------------------------------------------------+
int get_tendencia(double m1, double m2) {
    int tendencia = 0;
    if(m1>m2) {
         tendencia = 1;
    } else if(m1<m2) {
        tendencia = 2;
    }
    return(tendencia);
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
bool check_atraviesa_media() {
  bool result = false;
//  if(precio_low_patron<media_1 && precio_high_patron>media_1) {
//  	result=true;
//  }
//  if(precio_low_patron<media_2 && precio_high_patron>media_2) {
//  	result=true;
 // }
  return result;
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
