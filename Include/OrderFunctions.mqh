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
double get_sl_from_array(double order_id) {
    double result = 0;
    if(ArrayRange(orders_to_check,0)>0) {
        for(int i=0;i<ArrayRange(orders_to_check,0);i++) {
            if(orders_to_check[i][0] == (string)order_id) {
                return  StrToDouble(orders_to_check[i][4]);
            }
        }
    }
    return result;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que cierra operaciones si llega al apt_multiplicador_tp y el rsi es correcto
//+------------------------------------------------------------------+
void check_cierre_rsi() {


    // Vamos a cerrar con el RSI solo sin mirar el SL






    if(get_actual_rsi()>apt_rsi_cerrar_compras) {
         if(OrdersTotal()>0) {
            for(int i = OrdersTotal()-1; i >= 0; i--) {
                if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC && OrderType() == OP_BUY && Bid > OrderOpenPrice()) {
                    // Cogemos el SL del array
//                    double sl = OrderOpenPrice() - get_sl_from_array(OrderTicket());
//                    double tp = OrderOpenPrice() + (sl * apt_multiplicador_tp);
                    if(Bid > OrderOpenPrice()) {
                        Print("OrderTicket() = " + (string)OrderTicket());
                        bool check_close = OrderClose(OrderTicket(),OrderLots(),Bid,5);
                        if(check_close==false) {
                            Alert("OrderSelect failed");
                        }
                    }
                }
            }
         }
    }
    if(get_actual_rsi()<apt_rsi_cerrar_ventas) {
        if(OrdersTotal()>0) {
            for(int i = OrdersTotal()-1; i >= 0; i--) {
                if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC && OrderType() == OP_SELL && Ask < OrderOpenPrice()) {
                    // Cogemos el SL del array
//                    double sl = OrderOpenPrice() - get_sl_from_array(OrderTicket());
//                    double tp = OrderOpenPrice() - (sl * apt_multiplicador_tp);
                    if(Ask < OrderOpenPrice()) {
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
bool buy_limit_2() {

    // Si apt_porcentaje_caida_entrada_1 es diferente de 0 le metemos un buy stop por 20 barras
    // Hay que sacar el porcentaje del SL para meterle el buy stop
    // como vamos a contar las barras para desactivar??? creo que tiene una fecha de caducidad.... :)
    bool check_order = false;
    int order_id = 0;
    double precio_entrada = calculate_sl_with_porcentaje_caida_entrada_2();
    double order_sl = calculate_sl();
    double order_tp = 0;
    if(!apt_include_tp_with_rsi) {
        order_tp = calculate_tp(order_sl);
    }
    double lots = get_lots_by_sl(order_sl);
    if(lots>0) {
        order_id = OrderSend(Symbol(),OP_BUYLIMIT,lots,precio_entrada,5,order_sl,order_tp,"swing",MAGIC,TimeCurrent()+(60*50),Green);
        if(!order_id) {
            Print("Order send error ",GetLastError());
        } else {
            reiniciar_parametros();

            ArrayResize(orders_to_check,ArrayRange(orders_to_check,0)+1);
            orders_to_check[ArrayRange(orders_to_check,0)-1][0] = (string)order_id; //OrderNumber
            orders_to_check[ArrayRange(orders_to_check,0)-1][1] = (string)OrderType(); //OrderNumber
            orders_to_check[ArrayRange(orders_to_check,0)-1][2] = (string)OrderOpenPrice(); //OrderOpenPrice
            orders_to_check[ArrayRange(orders_to_check,0)-1][3] = (string)OrderTakeProfit(); //OrderTakeProfit
            orders_to_check[ArrayRange(orders_to_check,0)-1][4] = (string)OrderStopLoss(); //OrderStopLoss
            orders_to_check[ArrayRange(orders_to_check,0)-1][5] = (string)OrderSwap(); //OrderSwap
            orders_to_check[ArrayRange(orders_to_check,0)-1][6] = (string)OrderOpenTime(); //OrderOpenTime
        }
    }
    return check_order;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion de compra
//+------------------------------------------------------------------+
bool buy_limit_1() {

    // Si apt_porcentaje_caida_entrada_1 es diferente de 0 le metemos un buy stop por 20 barras
    // Hay que sacar el porcentaje del SL para meterle el buy stop
    // como vamos a contar las barras para desactivar??? creo que tiene una fecha de caducidad.... :)
    bool check_order = false;
    int order_id = 0;
    double precio_entrada = calculate_sl_with_porcentaje_caida_entrada_1();
    double order_sl = calculate_sl();
    double order_tp = 0;
    if(!apt_include_tp_with_rsi) {
        order_tp = calculate_tp(order_sl);
    }
    double lots = get_lots_by_sl(order_sl);
    if(lots>0) {
        order_id = OrderSend(Symbol(),OP_BUYLIMIT,lots,precio_entrada,5,order_sl,order_tp,"swing",MAGIC,TimeCurrent()+(60*50),Green);
        if(!order_id) {
            Print("Order send error ",GetLastError());
        } else {
            reiniciar_parametros();

            ArrayResize(orders_to_check,ArrayRange(orders_to_check,0)+1);
            orders_to_check[ArrayRange(orders_to_check,0)-1][0] = (string)order_id; //OrderNumber
            orders_to_check[ArrayRange(orders_to_check,0)-1][1] = (string)OrderType(); //OrderNumber
            orders_to_check[ArrayRange(orders_to_check,0)-1][2] = (string)OrderOpenPrice(); //OrderOpenPrice
            orders_to_check[ArrayRange(orders_to_check,0)-1][3] = (string)OrderTakeProfit(); //OrderTakeProfit
            orders_to_check[ArrayRange(orders_to_check,0)-1][4] = (string)OrderStopLoss(); //OrderStopLoss
            orders_to_check[ArrayRange(orders_to_check,0)-1][5] = (string)OrderSwap(); //OrderSwap
            orders_to_check[ArrayRange(orders_to_check,0)-1][6] = (string)OrderOpenTime(); //OrderOpenTime
        }
    }
    return check_order;
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
    if(lots>0) {
        order_id = OrderSend(Symbol(),OP_BUY,lots,Ask,5,order_sl,order_tp,"swing",MAGIC,0,Green);
        if(!order_id) {
            Print("Order send error ",GetLastError());
        } else {
            reiniciar_parametros();

            ArrayResize(orders_to_check,ArrayRange(orders_to_check,0)+1);
            orders_to_check[ArrayRange(orders_to_check,0)-1][0] = (string)order_id; //OrderNumber
            orders_to_check[ArrayRange(orders_to_check,0)-1][1] = (string)OrderType(); //OrderNumber
            orders_to_check[ArrayRange(orders_to_check,0)-1][2] = (string)OrderOpenPrice(); //OrderOpenPrice
            orders_to_check[ArrayRange(orders_to_check,0)-1][3] = (string)OrderTakeProfit(); //OrderTakeProfit
            orders_to_check[ArrayRange(orders_to_check,0)-1][4] = (string)OrderStopLoss(); //OrderStopLoss
            orders_to_check[ArrayRange(orders_to_check,0)-1][5] = (string)OrderSwap(); //OrderSwap
            orders_to_check[ArrayRange(orders_to_check,0)-1][6] = (string)OrderOpenTime(); //OrderOpenTime
        }
    }
    return check_order;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion de compra
//+------------------------------------------------------------------+
bool sell_limit_1() {

    // Si apt_porcentaje_caida_entrada_1 es diferente de 0 le metemos un buy stop por 20 barras
    // Hay que sacar el porcentaje del SL para meterle el buy stop
    // como vamos a contar las barras para desactivar??? creo que tiene una fecha de caducidad.... :)
    bool check_order = false;
    int order_id = 0;
    double precio_entrada = calculate_sl_with_porcentaje_caida_entrada_1();
    double order_sl = calculate_sl();
    double order_tp = 0;
    if(!apt_include_tp_with_rsi) {
        order_tp = calculate_tp(order_sl);
    }
    double lots = get_lots_by_sl(order_sl);
    if(lots>0) {
        order_id = OrderSend(Symbol(),OP_BUYLIMIT,lots,precio_entrada,5,order_sl,order_tp,"swing",MAGIC,TimeCurrent()+(60*50),Green);
        if(!order_id) {
            Print("Order send error ",GetLastError());
        } else {
            reiniciar_parametros();

            ArrayResize(orders_to_check,ArrayRange(orders_to_check,0)+1);
            orders_to_check[ArrayRange(orders_to_check,0)-1][0] = (string)order_id; //OrderNumber
            orders_to_check[ArrayRange(orders_to_check,0)-1][1] = (string)OrderType(); //OrderNumber
            orders_to_check[ArrayRange(orders_to_check,0)-1][2] = (string)OrderOpenPrice(); //OrderOpenPrice
            orders_to_check[ArrayRange(orders_to_check,0)-1][3] = (string)OrderTakeProfit(); //OrderTakeProfit
            orders_to_check[ArrayRange(orders_to_check,0)-1][4] = (string)OrderStopLoss(); //OrderStopLoss
            orders_to_check[ArrayRange(orders_to_check,0)-1][5] = (string)OrderSwap(); //OrderSwap
            orders_to_check[ArrayRange(orders_to_check,0)-1][6] = (string)OrderOpenTime(); //OrderOpenTime
        }
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
    if(lots>0) {
        order_id = OrderSend(Symbol(),OP_SELL,lots,Bid,5,order_sl,order_tp,"swing",MAGIC,0,Green);
        if(!order_id) {
          Print("Order send error ",GetLastError());
        } else {
            reiniciar_parametros();

            ArrayResize(orders_to_check,ArrayRange(orders_to_check,0)+1);
            orders_to_check[ArrayRange(orders_to_check,0)-1][0] = (string)order_id; //OrderNumber
            orders_to_check[ArrayRange(orders_to_check,0)-1][1] = (string)OrderType(); //OrderNumber
            orders_to_check[ArrayRange(orders_to_check,0)-1][2] = (string)OrderOpenPrice(); //OrderOpenPrice
            orders_to_check[ArrayRange(orders_to_check,0)-1][3] = (string)OrderTakeProfit(); //OrderTakeProfit
            orders_to_check[ArrayRange(orders_to_check,0)-1][4] = (string)OrderStopLoss(); //OrderStopLoss
            orders_to_check[ArrayRange(orders_to_check,0)-1][5] = (string)OrderSwap(); //OrderSwap
            orders_to_check[ArrayRange(orders_to_check,0)-1][6] = (string)OrderOpenTime(); //OrderOpenTime
        }
    }
    return check_order;
}
//+------------------------------------------------------------------+
