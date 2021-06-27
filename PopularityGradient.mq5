//+------------------------------------------------------------------+
//|                                           PopularityGradient.mq5 |
//|                                               Tymoteusz Urbaniak |
//|                                                         tymur.pl |
//+------------------------------------------------------------------+
#property copyright "Tymoteusz Urbaniak"
#property link      "tymur.pl"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Canvas\Canvas.mqh>

CCanvas C;
int pBars = 0;

int OnInit()
  {
//---
   ChartSetInteger(0,CHART_FOREGROUND,true);   
   int Width=(ushort)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);                               // get Window width
   int Height=(ushort)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);                             // get Window height
   if(!C.CreateBitmapLabel(0,0,"CanvasExamlple",0,0,Width,Height,COLOR_FORMAT_ARGB_NORMALIZE)) // create canvas with the size of the current window
      Print("Error creating canvas: ",GetLastError());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   C.Destroy();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int nBars = Bars(_Symbol, _Period);
   
   if(nBars != pBars){
      pBars = nBars;
   }else{
      return;
   }

   int highestCandleIndex;
   int lowestCandleIndex;
   double High[];
   double Low[];
   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Low, true);
   CopyHigh(_Symbol, _Period, 0, 100, High);
   CopyLow(_Symbol, _Period, 0, 100, Low);

   highestCandleIndex = ArrayMaximum(High, 0, 100);
   lowestCandleIndex = ArrayMinimum(Low, 0, 100);

   double highestPrice = High[highestCandleIndex];
   double lowestPrice = Low[lowestCandleIndex];

   int highestPriceInt = NormalizeDouble(highestPrice * 100, 0);
   int lowestPriceInt = NormalizeDouble(lowestPrice * 100, 0);

   MqlRates priceInfo[];
   ArraySetAsSeries(priceInfo, true);
   int data = CopyRates(_Symbol, _Period, 0, Bars(_Symbol, _Period), priceInfo);
   string linePrefix = "line_";
   C.Erase();   

   for(int i = lowestPriceInt; i < highestPriceInt; i++)
     {
      string lineName = linePrefix + IntegerToString(i);
      int found = ObjectFind(0, lineName);
      double castedWhole = i;
      double price = castedWhole/100;

      if(found < 0)
        {
         //ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, price);
        }

      uchar alpha = GetAlphaForPrice(price, priceInfo);
      uint lineColor = ColorToARGB(clrBlueViolet, alpha);
      //bool lineModified = ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
      
      int y = PriceToCanvasCord(price);
      
      if(y == -1){
         continue;
      }
      C.LineHorizontal(0, C.Width(), y, lineColor);
      C.Update(true);
     }
  }
//+------------------------------------------------------------------+
int PriceToCanvasCord(double price){
   double priceMin=ChartGetDouble(0,CHART_PRICE_MIN,0);
   double priceMax=ChartGetDouble(0,CHART_PRICE_MAX,0);
   double chartMax = priceMax - priceMin;
   price = price - priceMin;
   double chartMin = 0;
   int canvasHeight = C.Height();
   
   if(chartMax == 0){
      return -1;
   }
   int result = NormalizeDouble(((canvasHeight * price) / chartMax), 0);
   
   return canvasHeight - result;
}

uchar GetAlphaForPrice(double price, MqlRates &priceInfo[])
  {
   int size = ArraySize(priceInfo);
   uchar counter = 0;

   for(int i = 0; i < size; i++)
     {
      if((price > priceInfo[i].low) && (price < priceInfo[i].high))
        {
         counter = counter + 1;
        }
     }

   return counter;
  }
//+------------------------------------------------------------------+
