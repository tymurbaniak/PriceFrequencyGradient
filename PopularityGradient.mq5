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

input double detailsLevel = 100;

CCanvas C;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
void  OnChartEvent(
   const int       id,       // event ID
   const long&     lparam,   // long type event parameter
   const double&   dparam,   // double type event parameter
   const string&   sparam    // string type event parameter
)
  {
   Draw();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   Draw();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw()
  {
   int highestCandleIndex;
   int lowestCandleIndex;
   double High[];
   double Low[];
   uchar alpha[];
   uchar normalizedAlpha[];

   int numberOfConsideredBars = ChartGetInteger(0, CHART_VISIBLE_BARS, 0);

   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Low, true);
   CopyHigh(_Symbol, _Period, 0, numberOfConsideredBars, High);
   CopyLow(_Symbol, _Period, 0, numberOfConsideredBars, Low);

   highestCandleIndex = ArrayMaximum(High, 0, numberOfConsideredBars);
   lowestCandleIndex = ArrayMinimum(Low, 0, numberOfConsideredBars);

   double highestPrice = High[highestCandleIndex];
   double lowestPrice = Low[lowestCandleIndex];

   int highestPriceInt = NormalizeDouble(highestPrice * detailsLevel, 0);
   int lowestPriceInt = NormalizeDouble(lowestPrice * detailsLevel, 0);
   ArrayResize(alpha, highestPriceInt);
   ArrayResize(normalizedAlpha, highestPriceInt);

   MqlRates priceInfo[];
   ArraySetAsSeries(priceInfo, true);
   int data = CopyRates(_Symbol, _Period, 0, Bars(_Symbol, _Period), priceInfo);
   string linePrefix = "line_";
   C.Erase(0);

   for(int i = lowestPriceInt; i < highestPriceInt; i++)
     {
      double castedWhole = i;
      double price = castedWhole/detailsLevel;

      alpha[i] = GetAlphaForPrice(price, priceInfo);
     }

   NormalizeAlpha(alpha, normalizedAlpha);

   for(int i = lowestPriceInt; i < highestPriceInt; i++)
     {
      double castedWhole = i;
      double price = castedWhole/detailsLevel;
      uint lineColor = ColorToARGB(clrBlueViolet, normalizedAlpha[i]);

      int y = PriceToCanvasCord(price);

      if(y == -1)
        {
         continue;
        }
      C.LineHorizontal(0, C.Width(), y, lineColor);
     }
   C.Update(true);
  }
//+------------------------------------------------------------------+
void NormalizeAlpha(uchar &alpha[], uchar &normalizedAlpha[])
  {
   int maxIndex = ArrayMaximum(alpha, 0, ArraySize(alpha));
   uchar max = alpha[maxIndex];

   for(int i = 0; i < ArraySize(alpha); i++)
     {
      normalizedAlpha[i] = (alpha[i] * 255)/max;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceToCanvasCord(double price)
  {
   double priceMin=ChartGetDouble(0,CHART_PRICE_MIN,0);
   double priceMax=ChartGetDouble(0,CHART_PRICE_MAX,0);
   double chartMax = priceMax - priceMin;
   price = price - priceMin;
   double chartMin = 0;
   int canvasHeight = C.Height();

   if(chartMax == 0)
     {
      return -1;
     }
   int result = NormalizeDouble(((canvasHeight * price) / chartMax), 0);

   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
