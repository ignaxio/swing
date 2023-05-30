//+------------------------------------------------------------------+
//|                                               MovingAverages.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
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
    double result = nor1(iMA(NULL,0,media,0,MODE_SMA,PRICE_CLOSE,1));
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
