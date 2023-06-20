//+------------------------------------------------------------------+
//|                                                   SWING strategy |
//|                                                    Ignacio Farre |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Ignacio Farre"
#property link      ""
#property version   "2.00"
#property strict

#define MAGIC  2223

//--- input parameters
input int      apt_media_1=20;// Media 1
input int      apt_media_2=200;// Media 2
input int      apt_distancia_pivot_point=15;// lejania del pivot point
input bool     apt_include_tp_with_rsi=true;// Incluir TP con RSI
input double   apt_rsi_cerrar_compras=90;// RSI para cerrar compras
input double   apt_rsi_cerrar_ventas=10;// RSI para cerrar ventas


input int      apt_multiplicador_tp=3;// TP multiplicador
input double   apt_multiplicador_sl=1;// SL multiplicador
input double   apt_riesgo=0.1;// Porcentaje de riesgo de cuenta
input double   apt_angulo_tendncia=0.1;// Angulo de media para tendencia
input bool     apt_include_breakeven=false;// Incluir breakeven
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

static string orders_to_check[][50];


#include "./Include/swingBasicFunctions.mqh"


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
if(ArrayRange(orders_to_check,0)>0) {
	  for(int i=0;i<ArrayRange(orders_to_check,0);i++) {
	    Print("Order numero = " + orders_to_check[i][0]);
	    Print("---------Order type = " + orders_to_check[i][1]);
	    Print("---------Order price = " + orders_to_check[i][2]);
	    Print("---------Order TP = " + orders_to_check[i][3]);
	    Print("---------Order SL = " + orders_to_check[i][4]);
	    Print("---------Order Swap = " + orders_to_check[i][5]);
	    Print("---------Order time = " + orders_to_check[i][6]);
	  }
  }



 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {



    // TODO: Hay que guradar datos en un array, para tener el SL y el TP originales





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

    if(apt_include_tp_with_rsi) {
        check_cierre_rsi();
    }

    if(apt_include_breakeven) {
        check_breakeven();
    }

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

//+------------------------------------------------------------------+
//| Funcion que retorna el procentaje de rebote                                                               |
//+------------------------------------------------------------------+
void set_datos_basicos_to_array(int order_id) {
	if(OrderSelect(order_id, SELECT_BY_TICKET) && OrderMagicNumber() == MAGIC) {
		if(ArrayRange(orders_to_check,0)>0) {
	 		for(int i=0;i<ArrayRange(orders_to_check,0);i++) {
	 			if(orders_to_check[i][0] == (string)order_id) {
	 				orders_to_check[i][1] = (string)OrderType(); //OrderNumber
					orders_to_check[i][2] = (string)OrderOpenPrice(); //OrderOpenPrice
					orders_to_check[i][3] = (string)OrderTakeProfit(); //OrderTakeProfit
					orders_to_check[i][4] = (string)OrderStopLoss(); //OrderStopLoss
					orders_to_check[i][5] = (string)OrderSwap(); //OrderSwap
					orders_to_check[i][6] = (string)OrderOpenTime(); //OrderOpenTime
//					orders_to_check[i][7] = (string)nor2(tamano_patron); //tamano_patron
//					orders_to_check[i][8] = (string)nor2(precio_low_patron); //precio_low_patron
//					orders_to_check[i][9] = (string)nor2(precio_high_patron); //precio_high_patron
//					orders_to_check[i][10] = (string)nor2(porcentaje_retorno); //porcentaje_retorno

	 			}
	 		}
	 	}
	}
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que cierra operaciones si llega al apt_multiplicador_tp y el rsi es correcto
//+------------------------------------------------------------------+
void check_cierre_rsi() {
    if(OrdersTotal()>0) {
        for(int i = OrdersTotal()-1; i >= 0; i--) {
            if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC && OrderType() == OP_BUY && Bid > OrderOpenPrice()) {
//                double sl = OrderOpenPrice() - OrderStopLoss();
//                double tp = OrderOpenPrice() + (sl * apt_multiplicador_tp);
//                if(Bid > tp) {
                    if(get_actual_rsi()>apt_rsi_cerrar_compras) {
                        Print("OrderTicket() = " + (string)OrderTicket());
                        bool check_close = OrderClose(OrderTicket(),OrderLots(),Bid,5);
                        if(check_close==false) {
                            Alert("OrderSelect failed");
                        }
                    }
//                }
            }
            if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC && OrderType() == OP_SELL && Ask < OrderOpenPrice()) {
//                double sl = OrderStopLoss() - OrderOpenPrice();
//                double tp = OrderOpenPrice() - (sl * apt_multiplicador_tp);
//                if(Ask < tp) {
                    if(get_actual_rsi()<apt_rsi_cerrar_ventas) {
                        Print("OrderTicket() = " + (string)OrderTicket());
                        bool check_close = OrderClose(OrderTicket(),OrderLots(),Ask,5);
                        if(check_close==false) {
                            Alert("OrderSelect failed");
                        }
                    }
//                }
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
                    double breackeven = OrderOpenPrice() + 1;
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
                    double breackeven = OrderOpenPrice() - 1;
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
    if(lots>0) {
        order_id = OrderSend(Symbol(),OP_BUY,lots,Ask,5,order_sl,order_tp,"swing",MAGIC,0,Green);
        if(!order_id) {
            Print("Order send error ",GetLastError());
        } else {
            reiniciar_parametros();

            ArrayResize(orders_to_check,ArrayRange(orders_to_check,0)+1);
            orders_to_check[ArrayRange(orders_to_check,0)-1][0] = (string)order_id; //OrderNumber
            set_datos_basicos_to_array(order_id);
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
            set_datos_basicos_to_array(order_id);
        }
    }
    return check_order;
}
//+------------------------------------------------------------------+
