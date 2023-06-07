//+------------------------------------------------------------------+
//|                                               MovingAverages.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

//+------------------------------------------------------------------+
//| Funcion que cierra operaciones si llega al apt_multiplicador_tp y el rsi es correcto
//+------------------------------------------------------------------+
void check_cierre_rsi() {
    if(OrdersTotal()>0) {
        for(int i = OrdersTotal()-1; i >= 0; i--) {
            if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC && OrderType() == OP_BUY && Bid > OrderOpenPrice()) {
                double sl = OrderOpenPrice() - OrderStopLoss();
                double tp = OrderOpenPrice() + (sl * apt_multiplicador_tp);
                if(Bid > tp) {
                    if(get_actual_rsi()>85) {
                        Print("OrderTicket() = " + (string)OrderTicket());
                        bool check_close = OrderClose(OrderTicket(),OrderLots(),Bid,5);
                        if(check_close==false) {
                            Alert("OrderSelect failed");
                        }
                    }
                }
            }
            if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC && OrderType() == OP_SELL && Ask < OrderOpenPrice()) {
                double sl = OrderStopLoss() - OrderOpenPrice();
                double tp = OrderOpenPrice() - (sl * apt_multiplicador_tp);
                if(Ask < tp) {
                    if(get_actual_rsi()<15) {
                        Print("OrderTicket() = " + (string)OrderTicket());
                        bool check_close = OrderClose(OrderTicket(),OrderLots(),Ask,5);
                        if(check_close==false) {
                            Alert("OrderSelect failed");
                        }
                    }
                }
            }
        }
    }
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que coloca el breakeven
//+------------------------------------------------------------------+
void check_breakeven() {
    // Tenemos que recorrer el array de operaciones y ver si podemos colocar el breakeven.
    if(OrdersTotal()>0) {
        for(int i = OrdersTotal()-1; i >= 0; i--) {
             if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC && OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice()) {
                double distancia_breakeven = get_price_to_set_breakeven();
                if(Bid > OrderOpenPrice() + distancia_breakeven) {
                    double breackeven = OrderOpenPrice() + 2;
                    bool Check_modify = OrderModify(OrderTicket(),OrderOpenPrice(),breackeven,OrderTakeProfit(),0,Orange);
                    if(Check_modify==false) {
                        Alert("OrderSelect failed");
                        break;
                    }
                }
             }

             if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC && OrderType() == OP_SELL && OrderStopLoss() < OrderOpenPrice()) {
                double distancia_breakeven = get_price_to_set_breakeven();
                if(Ask < OrderOpenPrice() - distancia_breakeven) {
                    double breackeven = OrderOpenPrice() - 2;
                    bool Check_modify = OrderModify(OrderTicket(),OrderOpenPrice(),breackeven,OrderTakeProfit(),0,Orange);
                    if(Check_modify==false) {
                        Alert("OrderSelect failed");
                        break;
                    }
                }
             }
        }
    }
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion de compra
//+------------------------------------------------------------------+
bool compra() {
    bool check_order = false;
    int order_id = 0;
    double order_sl = calculate_sl();
    double order_tp = 0;
    if(!apt_include_tp_with_rsi) {
        order_tp = calculate_tp(order_sl);
    }
    Print("order_tp = " + (string)order_tp);
    double lots = get_lots_by_sl(order_sl);
    order_id = OrderSend(Symbol(),OP_BUY,lots,Ask,5,order_sl,order_tp,"swing",MAGIC,0,Green);
    if(!order_id) {
        Print("Order send error ",GetLastError());
    } else {
        reiniciar_parametros();
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
    double order_sl = calculate_sl();
    double order_tp = 0;
    if(!apt_include_tp_with_rsi) {
        order_tp = calculate_tp(order_sl);
    }
    Print("order_tp = " + (string)order_tp);
    double lots = get_lots_by_sl(order_sl);
    order_id = OrderSend(Symbol(),OP_SELL,lots,Bid,5,order_sl,order_tp,"swing",MAGIC,0,Green);
    if(!order_id) {
      Print("Order send error ",GetLastError());
    } else {
        reiniciar_parametros();
    }
    return check_order;
}
//+------------------------------------------------------------------+
