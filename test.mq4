//+------------------------------------------------------------------+
//|                           MyRobot2014_ENG-Build600-ShortSell.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern string  INITIAL_DATA = "INITIAL DATA";
extern int     Magic = 22222;
extern double  Spead_Filter = 4.0;
extern int     Slippage = 5;
extern string  Comments = "Auto profit";
extern string  Parameter_Lots = "Parameter Lot";
extern int     Lot_Point = 2;
extern double  Lot = 0.01;
extern double  Lot_Gain = 1.11;
extern string  DATA_ENTRY = "DATA ENTRY";
extern int     Max_Trade = 1000;
extern int     Trade_Step = 15;
extern string  EXIT_OPTIONS = "EXIT OPTIONS";
extern int     TakeProfit = 10;
extern string  TRADE_OPTION = "TRADE OPTION";
extern bool    UseTimeFilter = FALSE;
extern int     Strat_Time_Trade = 16;
extern int     Stop_Time_Trade = 2;
extern string  EXIT_FILTER = "EXIT_FILTER";
extern bool    CloseEmergency = FALSE;
extern double  LossPercentStop = 20.0;
extern bool    CloseInTime = FALSE;
extern double  WaitTimeMinute = 0.0;

extern bool    ClearOrderWhenNoTrade = FALSE;
extern string  Detail = "FixLot=0,DoubleLot=1,DoubleFromHistory=2";
extern int     Lot_Option = 1;

bool global_ignor_timecondition = FALSE;
bool global_concern_timecondition = TRUE;

int global_current_time_buy = 0;
int global_current_time_sell = 0;

int global_index = 0;
int global_stoploss = 0;
double global_equity;
double global_lastopen_pricebuy;
double global_lastopen_pricesell;
double global_lot_use;
double global_be_sl_price = 0.0;
double global_equity_no_order;
double global_equity_have_order;
bool global_have_new_round;
int global_waittime;
int global_total_order_comment = 0;
int global_total_order;
bool global_nextrade_enable = FALSE;
bool global_next_buy = FALSE;
bool global_next_sell = FALSE;
int global_ticket;
bool global_normal_trade = FALSE;
double global_ask;
double global_bid;
double global_be_tp_price;
double global_be_price;
int global_opencandletime = 0;
int global_factor = 1;
string global_lable = "lblfin_";
bool           order1,order2,order3,order4,order5,order6,order7,order8,order9;
bool           order_m1;
bool           order_c1,order_c2;

int init() {
   double loc_lot_step;
   if (sub_truefunction() == 1) {
      if (IsTesting() == TRUE) sub_display_comment();
      if (IsTesting() == FALSE) sub_display_comment();
      loc_lot_step = MarketInfo(Symbol(), MODE_LOTSTEP);
      if(loc_lot_step == 0.01) Lot_Point = 2;
      if(loc_lot_step == 0.1) Lot_Point = 1;
      if(loc_lot_step == 1) Lot_Point = 0;
      if (!(Digits == 5 || Digits == 3)) return (0);
      global_factor = 10;
      return (0);
   }
   return (0);
}
	    	 	 		 	    	 			 				   		  	  				 						  		     			    		 			 		 	 							  	 	  	 	  	 	 				 	 			  	  	   		 		  	 	 	 			  	     			
int deinit() {
   return (0);
}
	  		 		 			 		  	    								 	  			  		 	    	  	 			  		 			 		    			 		   						 		  		 			 	      	 	  			  				 	 				 		 	    	 	  			 		
int start() {
   double loc_5to4digits;
   double loc_order_lot_buy;
   double loc_order_lot_sell;
   double local_close_2;
   double local_close_1;
   double loc_spread;
   string loc_analyzespread;
   string loc_textspread_ok;
   string loc_textspreadanalyze;
   string loc_notimetradecondition;
   string loc_usetimetradecondition;
   double loc_totalprofit;
   double loc_total_lot;
   
   if (sub_truefunction() == 1) {
      sub_display_comment();
      sub_showearntext();
      if (Digits <= 3) loc_5to4digits = 0.01;
      else loc_5to4digits = 0.0001;
      loc_spread = NormalizeDouble((Ask - Bid) / loc_5to4digits, 1);
      loc_analyzespread = "  OK";
      if (loc_spread > Spead_Filter) loc_analyzespread = "  TOO HIGH !";
      loc_textspread_ok = "Spread = " + DoubleToStr(loc_spread, 1);
      loc_textspreadanalyze = loc_analyzespread;
      ObjectCreate("klc14", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("klc14", "Funds: " + DoubleToStr(AccountEquity(), 2), 14, "Courier New", Yellow);
      ObjectSet("klc14", OBJPROP_CORNER, 1);
      ObjectSet("klc14", OBJPROP_XDISTANCE, 10);
      ObjectSet("klc14", OBJPROP_YDISTANCE, 93);
      ObjectCreate("klc15", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("klc15", "Free: " + DoubleToStr(AccountFreeMargin(), 2), 14, "Courier New", Yellow);
      ObjectSet("klc15", OBJPROP_CORNER, 1);
      ObjectSet("klc15", OBJPROP_XDISTANCE, 10);
      ObjectSet("klc15", OBJPROP_YDISTANCE, 124);
      ObjectCreate("klc16", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("klc16", "Profit:   " + DoubleToStr(AccountProfit(), 2), 14, "Courier New", Yellow);
      ObjectSet("klc16", OBJPROP_CORNER, 1);
      ObjectSet("klc16", OBJPROP_XDISTANCE, 10);
      ObjectSet("klc16", OBJPROP_YDISTANCE, 143);
      ObjectCreate("klc17", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("klc17", "Lot: " + DoubleToStr(Lot, 2), 14, "Courier New", LightGray);
      ObjectSet("klc17", OBJPROP_CORNER, 1);
      ObjectSet("klc17", OBJPROP_XDISTANCE, 10);
      ObjectSet("klc17", OBJPROP_YDISTANCE, 175);
      ObjectCreate("klc18", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("klc18", "Working Lot: " + DoubleToStr(global_lot_use, 2), 14, "Courier New", LightGray);
      ObjectSet("klc18", OBJPROP_CORNER, 1);
      ObjectSet("klc18", OBJPROP_XDISTANCE, 10);
      ObjectSet("klc18", OBJPROP_YDISTANCE, 193);
      ObjectCreate("klc19", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("klc19", "Spread: " + DoubleToStr(loc_spread, 1) + loc_textspreadanalyze, 14, "Courier New", Gray);
      ObjectSet("klc19", OBJPROP_CORNER, 1);
      ObjectSet("klc19", OBJPROP_XDISTANCE, 10);
      ObjectSet("klc19", OBJPROP_YDISTANCE, 229);
      ObjectCreate("klc20", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("klc20", "Server Time: " + TimeToStr(TimeCurrent(), TIME_MINUTES), 14, "Courier New", LightGray);
      ObjectSet("klc20", OBJPROP_CORNER, 3);
      ObjectSet("klc20", OBJPROP_XDISTANCE, 10);
      ObjectSet("klc20", OBJPROP_YDISTANCE, 8);
      if (ClearOrderWhenNoTrade) {
         if (!(Hour() >= Strat_Time_Trade && Hour() <= Stop_Time_Trade)) {
            sub_closeall();
            Comment("                              Time to trade has not come yet!");
            return (0);
         }
      }
      loc_notimetradecondition = "false";
      loc_usetimetradecondition = "false";
      if (UseTimeFilter == FALSE || (UseTimeFilter && (Stop_Time_Trade > Strat_Time_Trade && Hour() >= Strat_Time_Trade && Hour() <= Stop_Time_Trade)) ||( Strat_Time_Trade > Stop_Time_Trade &&(!(Hour() >= Stop_Time_Trade && Hour() <= Strat_Time_Trade)))) loc_notimetradecondition = "true";
         
      if (UseTimeFilter && Stop_Time_Trade > Strat_Time_Trade && Hour() >= Strat_Time_Trade && Hour() <= Stop_Time_Trade)loc_usetimetradecondition = "true";
         
      if (CloseInTime) {
         if (TimeCurrent() >= global_waittime) {
            sub_closeall();
            Print("All trades will be closed due to a timeout");
         }
      }
      if (global_opencandletime == Time[0]) return (0);
      global_opencandletime = Time[0];
      loc_totalprofit = sub_checkprofit();
      if (CloseEmergency) {
         if (loc_totalprofit < 0.0 && MathAbs(loc_totalprofit) > LossPercentStop / 100.0 * sub_check_equity()) {
            sub_closeall();
            Print("All trades will be closed due to excess Equity");
            global_normal_trade = FALSE;
         }
      }
      global_total_order = sub_cnt_order();
      if (global_total_order == 0) global_have_new_round = FALSE;
      for (global_index = OrdersTotal() - 1; global_index >= 0; global_index--) {
         order1 = OrderSelect(global_index, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_BUY) {
               global_next_buy = TRUE;
               global_next_sell = FALSE;
               loc_order_lot_buy = OrderLots();
               break;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_SELL) {
               global_next_buy = FALSE;
               global_next_sell = TRUE;
               loc_order_lot_sell = OrderLots();
               break;
            }
         }
      }
      if (global_total_order > 0 && global_total_order <= Max_Trade) {
         RefreshRates();
         global_lastopen_pricebuy = sub_check_lastbuy_openprice();
         global_lastopen_pricesell = sub_check_lastsell_openprice();
         if (global_next_buy && global_lastopen_pricebuy - Ask >= Trade_Step * global_factor * Point) global_nextrade_enable = TRUE;
         if (global_next_sell && Bid - global_lastopen_pricesell >= Trade_Step * global_factor * Point) global_nextrade_enable = TRUE;
      }
      if (global_total_order < 1) {
         global_next_sell = FALSE;
         global_next_buy = FALSE;
         global_nextrade_enable = TRUE;
         global_equity = AccountEquity();
      }
      if (global_nextrade_enable) {
         global_lastopen_pricebuy = sub_check_lastbuy_openprice();
         global_lastopen_pricesell = sub_check_lastsell_openprice();
         if (global_next_sell) {
            if (global_ignor_timecondition || loc_usetimetradecondition == "true") {
               sub_close_order_buy_sel(0, 1);
               global_lot_use = NormalizeDouble(Lot_Gain * loc_order_lot_sell, Lot_Point);
            } else global_lot_use = sub_cal_lot(OP_SELL);
            if (global_concern_timecondition && loc_notimetradecondition == "true") {
               global_total_order_comment = global_total_order;
               if (global_lot_use > 0.0) {
                  RefreshRates();
                  global_ticket = sub_sendorder(1, global_lot_use, Bid, Slippage * global_factor, Ask, 0, 0, Comments + "- " + global_total_order_comment, Magic, 0, Red);
                  if (global_ticket < 0) {
                     Print(" error correction: ", sub_showerrormessage(GetLastError()));
                     return (0);
                  }
                  global_lastopen_pricesell = sub_check_lastsell_openprice();
                  global_nextrade_enable = FALSE;
                  global_normal_trade = TRUE;
               }
            }
         } else {
            if (global_next_buy) {
               if (global_ignor_timecondition || loc_usetimetradecondition == "true") {
                  sub_close_order_buy_sel(1, 0);
                  global_lot_use = NormalizeDouble(Lot_Gain * loc_order_lot_buy, Lot_Point);
               } else global_lot_use = sub_cal_lot(OP_BUY);
               if (global_concern_timecondition && loc_notimetradecondition == "true") {
                  global_total_order_comment = global_total_order;
                  if (global_lot_use > 0.0) {
                     global_ticket = sub_sendorder(0, global_lot_use, Ask, Slippage * global_factor, Bid, 0, 0, Comments + "- " + global_total_order_comment, Magic, 0, Blue);
                     if (global_ticket < 0) {
                        Print(" error correction: ", sub_showerrormessage(GetLastError()));
                        return (0);
                     }
                     global_lastopen_pricebuy = sub_check_lastbuy_openprice();
                     global_nextrade_enable = FALSE;
                     global_normal_trade = TRUE;
                  }
               }
            }
         }
      }
      if (global_nextrade_enable && global_total_order < 1) {
         local_close_2 = iClose(Symbol(), 0, 2);
         local_close_1 = iClose(Symbol(), 0, 1);
         global_bid = Bid;
         global_ask = Ask;
         if ((!global_next_sell) && !global_next_buy && loc_notimetradecondition == "true") {
            global_total_order_comment = global_total_order;
            if (local_close_2 > local_close_1) {
               global_lot_use = sub_cal_lot(OP_SELL);
               if (global_lot_use > 0.0) {
                  global_ticket = sub_sendorder(1, global_lot_use, global_bid, Slippage * global_factor, global_bid, 0, 0, Comments + "- " + global_total_order_comment, Magic, 0, Red);
                  if (global_ticket < 0) {
                     Print(global_lot_use, " error correction: ", sub_showerrormessage(GetLastError()));
                     return (0);
                  }
                  global_lastopen_pricebuy = sub_check_lastbuy_openprice();
                  global_normal_trade = TRUE;
               }
            } else {
               global_lot_use = sub_cal_lot(OP_BUY);
               if (global_lot_use > 0.0) {
                  global_ticket = sub_sendorder(0, global_lot_use, global_ask, Slippage * global_factor, global_ask, 0, 0, Comments + "- " + global_total_order_comment, Magic, 0, Blue);
                  if (global_ticket < 0) {
                     Print(global_lot_use, " error correction: ", sub_showerrormessage(GetLastError()));
                     return (0);
                  }
                  global_lastopen_pricesell = sub_check_lastsell_openprice();
                  global_normal_trade = TRUE;
               }
            }
         }
         if (global_ticket > 0) global_waittime = TimeCurrent() + 60.0 * (60.0 * WaitTimeMinute);
         global_nextrade_enable = FALSE;
      }
      global_total_order = sub_cnt_order();
      global_be_price = 0;
      loc_total_lot = 0;
      for (global_index = OrdersTotal() - 1; global_index >= 0; global_index--) {
         order2 = OrderSelect(global_index, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               global_be_price += OrderOpenPrice() * OrderLots();
               loc_total_lot += OrderLots();
            }
         }
      }
      if (global_total_order > 0) global_be_price = NormalizeDouble(global_be_price / loc_total_lot, Digits);
      if (global_normal_trade) {
         for (global_index = OrdersTotal() - 1; global_index >= 0; global_index--) {
            order3 = OrderSelect(global_index, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
               if (OrderType() == OP_BUY) {
                  global_be_tp_price = global_be_price + TakeProfit * global_factor * Point;
                  global_be_sl_price = global_be_price - global_stoploss * global_factor * Point;
                  global_have_new_round = TRUE;
               }
            }
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
               if (OrderType() == OP_SELL) {
                  global_be_tp_price = global_be_price - TakeProfit * global_factor * Point;
                  global_be_sl_price = global_be_price + global_stoploss * global_factor * Point;
                  global_have_new_round = TRUE;
               }
            }
         }
      }
      if (!(global_normal_trade)) return (0);
      if (global_have_new_round != TRUE) return (0);
      for (global_index = OrdersTotal() - 1; global_index >= 0; global_index--) {
         order4 = OrderSelect(global_index, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) order_m1 = OrderModify(OrderTicket(), global_be_price, OrderStopLoss(), global_be_tp_price, 0, Yellow);
         global_normal_trade = FALSE;
      }
      return (0);
   }
   return (0);
}
	      	 		 		   	 		  				  			  	   			 			 		  		 	   			 	  		 		  		 	 	 					    	  	 		 	 	 		 	 	 				 	  	  			 		    	 	 		   	    				

double sub_normalize_price(double Ad_0) {
   return (NormalizeDouble(Ad_0, Digits));
}
					 	 	  	 				 	   	    			  		 		    	      		  					   				  	   	  	 	       		 	 		 	 		 	 	    	 	   		 		 			  	  		 	 	 	   		 					   

int sub_close_order_buy_sel(bool Ai_0 = TRUE, bool Ai_4 = TRUE) {
   int Li_ret_8 = 0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      if (OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_BUY && Ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), sub_normalize_price(Bid), 5, CLR_NONE)) {
                     Print("Error closing BUY " + OrderTicket());
                     Li_ret_8 = -1;
                  }
               } else {
                  if (global_current_time_buy == iTime(NULL, 0, 0)) return (-2);
                  global_current_time_buy = iTime(NULL, 0, 0);
                  Print("Attempting to close the deal BUY " + OrderTicket() + ". Trade context busy");
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && Ai_4) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!((!OrderClose(OrderTicket(), OrderLots(), sub_normalize_price(Ask), 5, CLR_NONE)))) continue;
                  Print("Error closing SELL " + OrderTicket());
                  Li_ret_8 = -1;
                  continue;
               }
               if (global_current_time_sell == iTime(NULL, 0, 0)) return (-2);
               global_current_time_sell = iTime(NULL, 0, 0);
               Print("Attempting to close the deal SELL " + OrderTicket() + ". Trade context busy");
               return (-2);
            }
         }
      }
   }
   return (Li_ret_8);
}
	  	  		 						  	  	 						 	 	  		   		 	 	  	  	  		  		  		 		  	 			 			  					  		  						 	  	   	 	 				  		 	 	 			  		 	  	 	 	  	 	 		
double sub_cal_lot(int A_cmd_0) {
   double Ld_ret_4;
   int datetime_12;
   switch (Lot_Option) {
   case 0:
      Ld_ret_4 = Lot;
      break;
   case 1:
      Ld_ret_4 = NormalizeDouble(Lot * MathPow(Lot_Gain, global_total_order_comment), Lot_Point);
      break;
   case 2:
      datetime_12 = 0;
      Ld_ret_4 = Lot;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
         if (OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
               if (datetime_12 < OrderCloseTime()) {
                  datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) {
                     Ld_ret_4 = NormalizeDouble(OrderLots() * Lot_Gain, Lot_Point);
                     continue;
                  }
                  Ld_ret_4 = Lot;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), A_cmd_0, Ld_ret_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (Ld_ret_4);
}
	    	 	 		 	    	 			 				   		  	  				 						  		     			    		 			 		 	 							  	 	  	 	  	 	 				 	 			  	  	   		 		  	 	 	 			  	     			
int sub_cnt_order() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      order5 = OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}
		     	  	 		     		  		 	  			 		   							 		 			 	    		 	  	  		  				 	 			 	    	 		 		 	   		 	 						 	 		  			  	    	   		   		   				
void sub_closeall() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      order6 = OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_BUY) order_c1 = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage * global_factor, Blue);
            if (OrderType() == OP_SELL) order_c2 = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage * global_factor, Red);
         }
         Sleep(1000);
      }
   }
}
			 	  		    	  	 		   	    						  	 		 	 	  				 			  	  			    		   	 	    		    	  			   	 		 		  	  	 	 	 			  					   	  		 		     		 				 
int sub_sendorder(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_unused_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56) {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int Li_72 = 100;
   switch (Ai_0) {
   case 2:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, sub_stoploss_buy(Ad_24, global_stoploss * global_factor), sub_takeprofit_buy(A_price_12, Ai_36), A_comment_40, A_magic_48,
            A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, sub_stoploss_buy(Ad_24, global_stoploss * global_factor), sub_takeprofit_buy(A_price_12, Ai_36), A_comment_40, A_magic_48,
            A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         RefreshRates();
         ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, sub_stoploss_buy(Bid, global_stoploss * global_factor), sub_takeprofit_buy(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, sub_stoploss_sell(Ad_24, global_stoploss * global_factor), sub_takeprofit_sell(A_price_12, Ai_36), A_comment_40, A_magic_48,
            A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, sub_stoploss_sell(Ad_24, global_stoploss * global_factor), sub_takeprofit_sell(A_price_12, Ai_36), A_comment_40, A_magic_48,
            A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, sub_stoploss_sell(Ask, global_stoploss * global_factor), sub_takeprofit_sell(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (ticket_60);
}
	  	 	 						   		  		 	 			  			 		 			  	 					 	     			      	  		 	  						 			 	 		 			  			  			   	 	  		 		  						 	 			  		     	  		 

double sub_stoploss_buy(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Point);
}
		 	      				 	    	   	 		 		  			  	 			 	 	  		  	 	  	  	 		   	   					 	 	 		     					      	 					 		   			 		   		        	  			 	 		 	

double sub_stoploss_sell(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Point);
}
	  	  		 						  	  	 						 	 	  		   		 	 	  	  	  		  		  		 		  	 			 			  					  		  						 	  	   	 	 				  		 	 	 			  		 	  	 	 	  	 	 		

double sub_takeprofit_buy(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Point);
}
			 	        	 	  		    	   			  	  	 	 		 	  	  	 			 	   			 		 		    		    	 	   	    	   	    		  				 	 	   	  			     	     		   				 			 	

double sub_takeprofit_sell(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Point);
}
		    		  	 			    		 			 	  	 	 		    						  	 			 		   		 		 	  		 					 	  		 	   		 		 				   		   								 		  	 	  	   		   		 	 		   	 		

double sub_checkprofit() {
   double loc_profit = 0;
   for (global_index = OrdersTotal() - 1; global_index >= 0; global_index--) {
      order7 = OrderSelect(global_index, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) loc_profit += OrderProfit();
   }
   return (loc_profit);
}
	   	 		 		  		  	 	  					 		 	  	 	  		 		   	  					  						 		 	  			 	    				 	 		  	  			 	 	    	 		 			  	 		 	 		 	 		 	 	  	 	   		 		

double sub_check_equity() {
   if (sub_cnt_order() == 0) global_equity_no_order = AccountEquity();
   if (global_equity_no_order < global_equity_have_order) global_equity_no_order = global_equity_have_order;
   else global_equity_no_order = AccountEquity();
   global_equity_have_order = AccountEquity();
   return (global_equity_no_order);
}
				 		 	  		 			 	 			    	    		 	 	   	  		  		    			     		  	 			  	 			     	 		 		 		 	 	 	 		 	 	  	 	 		 	    	  	 		 	 	 				 			     

double sub_check_lastbuy_openprice() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      order8 = OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUY) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}
	 	  	  		  	  							   	    	 	    		    				 	  	   			 	   	 					      			  	   	  	   	   								   		   	     	 		   	  						 	  	   	  

double sub_check_lastsell_openprice() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      order9 = OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_SELL) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}
	 	 				 	    	  			 					  	  	    		 		  	 	 	   		 	  	 		 	 				 				    	 			  				      		 			 	  	  	  		    	  	 	  				 			 		 	 	 	  		

void sub_display_comment() {
   Comment("                              Server:  ", AccountServer(), 
      "\n", "                              Leverage:   ", "1:" + DoubleToStr(AccountLeverage(), 0), 
      "\n", 
      "\n", "                              Lot Gain  =  ", Lot_Gain, 
      "\n", "                              Trade Step          =  ", Trade_Step, 
      "\n", "                              TakeProfit       =  ", TakeProfit, 
      "\n", "                              Slippage  =  ", Slippage, 
   "\n");
}
		 		 	   		 			      	 	 				   				   			      		 				  	 					     	 				    	 			 	  			 		        				  		  					    			 	       				 			  	

string sub_showerrormessage(int error_code=-1)
{
   if (error_code<0) {error_code=GetLastError();}
   string error_string="";
 
   switch(error_code)
     {
      //-- codes returned from trade server
      case 0:   return("");
      case 1:   error_string="No error returned"; break;
      case 2:   error_string="Common error"; break;
      case 3:   error_string="Invalid trade parameters"; break;
      case 4:   error_string="Trade server is busy"; break;
      case 5:   error_string="Old version of the client terminal"; break;
      case 6:   error_string="No connection with trade server"; break;
      case 7:   error_string="Not enough rights"; break;
      case 8:   error_string="Too frequent requests"; break;
      case 9:   error_string="Malfunctional trade operation (never returned error)"; break;
      case 64:  error_string="Account disabled"; break;
      case 65:  error_string="Invalid account"; break;
      case 128: error_string="Trade timeout"; break;
      case 129: error_string="Invalid price"; break;
      case 130: error_string="Invalid Sl or TP"; break;
      case 131: error_string="Invalid trade volume"; break;
      case 132: error_string="Market is closed"; break;
      case 133: error_string="Trade is disabled"; break;
      case 134: error_string="Not enough money"; break;
      case 135: error_string="Price changed"; break;
      case 136: error_string="Off quotes"; break;
      case 137: error_string="Broker is busy (never returned error)"; break;
      case 138: error_string="Requote"; break;
      case 139: error_string="Order is locked"; break;
      case 140: error_string="Only long trades allowed"; break;
      case 141: error_string="Too many requests"; break;
      case 145: error_string="Modification denied because order too close to market"; break;
      case 146: error_string="Trade context is busy"; break;
      case 147: error_string="Expirations are denied by broker"; break;
      case 148: error_string="Amount of open and pending orders has reached the limit"; break;
      case 149: error_string="Hedging is prohibited"; break;
      case 150: error_string="Prohibited by FIFO rules"; break;
      //-- mql4 errors
      case 4000: error_string="No error"; break;
      case 4001: error_string="Wrong function pointer"; break;
      case 4002: error_string="Array index is out of range"; break;
      case 4003: error_string="No memory for function call stack"; break;
      case 4004: error_string="Recursive stack overflow"; break;
      case 4005: error_string="Not enough stack for parameter"; break;
      case 4006: error_string="No memory for parameter string"; break;
      case 4007: error_string="No memory for temp string"; break;
      case 4008: error_string="Not initialized string"; break;
      case 4009: error_string="Not initialized string in array"; break;
      case 4010: error_string="No memory for array string"; break;
      case 4011: error_string="Too long string"; break;
      case 4012: error_string="Remainder from zero divide"; break;
      case 4013: error_string="Zero divide"; break;
      case 4014: error_string="Unknown command"; break;
      case 4015: error_string="Wrong jump"; break;
      case 4016: error_string="Not initialized array"; break;
      case 4017: error_string="dll calls are not allowed"; break;
      case 4018: error_string="Cannot load library"; break;
      case 4019: error_string="Cannot call function"; break;
      case 4020: error_string="Expert function calls are not allowed"; break;
      case 4021: error_string="Not enough memory for temp string returned from function"; break;
      case 4022: error_string="System is busy"; break;
      case 4050: error_string="Invalid function parameters count"; break;
      case 4051: error_string="Invalid function parameter value"; break;
      case 4052: error_string="String function internal error"; break;
      case 4053: error_string="Some array error"; break;
      case 4054: error_string="Incorrect series array using"; break;
      case 4055: error_string="Custom indicator error"; break;
      case 4056: error_string="Arrays are incompatible"; break;
      case 4057: error_string="Global variables processing error"; break;
      case 4058: error_string="Global variable not found"; break;
      case 4059: error_string="Function is not allowed in testing mode"; break;
      case 4060: error_string="Function is not confirmed"; break;
      case 4061: error_string="Send mail error"; break;
      case 4062: error_string="String parameter expected"; break;
      case 4063: error_string="Integer parameter expected"; break;
      case 4064: error_string="Double parameter expected"; break;
      case 4065: error_string="Array as parameter expected"; break;
      case 4066: error_string="Requested history data in update state"; break;
      case 4099: error_string="End of file"; break;
      case 4100: error_string="Some file error"; break;
      case 4101: error_string="Wrong file name"; break;
      case 4102: error_string="Too many opened files"; break;
      case 4103: error_string="Cannot open file"; break;
      case 4104: error_string="Incompatible access to a file"; break;
      case 4105: error_string="No order selected"; break;
      case 4106: error_string="Unknown symbol"; break;
      case 4107: error_string="Invalid price parameter for trade function"; break;
      case 4108: error_string="Invalid ticket"; break;
      case 4109: error_string="Trade is not allowed in the expert properties"; break;
      case 4110: error_string="Longs are not allowed in the expert properties"; break;
      case 4111: error_string="Shorts are not allowed in the expert properties"; break;
      case 4200: error_string="Object is already exist"; break;
      case 4201: error_string="Unknown object property"; break;
      case 4202: error_string="Object is not exist"; break;
      case 4203: error_string="Unknown object type"; break;
      case 4204: error_string="No object name"; break;
      case 4205: error_string="Object coordinates error"; break;
      case 4206: error_string="No specified subwindow"; break;
      case 4207: error_string="Some error in object function"; break;
      default:   error_string="Unknown error";
     }
   error_string=StringConcatenate(error_string," ("+error_code+")");
   return(error_string);
}
						  	  	   		 	  	     		 	 		 				  	   		 		  	  		   	  	  	  	   	 	 		    			  		 	    	 	  			 	      		 		 	 	  			  	 	  	 	 				 	  

double sub_check_all_earn_history(int Ai_0) {
   double Ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersHistoryTotal(); pos_12++) {
      if (!(OrderSelect(pos_12, SELECT_BY_POS, MODE_HISTORY))) break;
      if (OrderSymbol() == Symbol())
         if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, Ai_0) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, Ai_0) + 86400) Ld_ret_4 += OrderProfit() + OrderSwap() + OrderCommission();
   }
   return (Ld_ret_4);
}
		 		 		  		 		       			 				 	 				  				    	 		 			   	 			 	     						   		 			 		 			 			        			  			 					 	  			 		      	 		 			 		

void sub_showearntext() {
   double Ld_0 = sub_check_all_earn_history(0);
   string name_8 = global_lable + "1";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 15);
   }
   ObjectSetText(name_8, "earnings today: " + DoubleToStr(Ld_0, 2), 12, "Courier New", Yellow);
   Ld_0 = sub_check_all_earn_history(1);
   name_8 = global_lable + "2";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 30);
   }
   ObjectSetText(name_8, "earnings yesterday: " + DoubleToStr(Ld_0, 2), 12, "Courier New", Yellow);
   Ld_0 = sub_check_all_earn_history(2);
   name_8 = global_lable + "3";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 45);
   }
   ObjectSetText(name_8, "earnings before yesterday: " + DoubleToStr(Ld_0, 2), 12, "Courier New", Yellow);
   name_8 = global_lable + "4";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(name_8, "balance: " + DoubleToStr(AccountBalance(), 2), 14, "Courier New", Yellow);
}	   		 	 		      	 	 	 				 	 		  	 					 		 			  			    				   		 	 	 		 	  						 		 	  	    	 	 	 		 	 		   	  	 	 		 		 		 	 	 	 	  	   	 			
					 			  	 		 	 	   		   			 			 		  	 	     			  			 	   			   	   		 	 	   	   		 				 	 				 	      	   					 			 		  		 			 	   	  					 	 

int sub_truefunction() {
   return (1);
}