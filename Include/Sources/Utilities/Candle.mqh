//+------------------------------------------------------------------+
//|                                                       Candle.mqh |
//|                                        Copyright 2023, Upcoding. |
//|                                         https://www.upcoding.net |
//+------------------------------------------------------------------+

#ifndef CANDLE_INCLUDED
#define CANDLE_INCLUDED

#include "Time.mqh"

class CCandle
{
  private:
    static MqlTick candleTicks;
    static MqlRates candleRates[];

  public:
    CCandle();
    ~CCandle();

    // Methods
    // GET
    static double GetOpen(string symbol, int c, ENUM_TIMEFRAMES time);
    static double GetClose(string symbol, int c, ENUM_TIMEFRAMES time);
    static long GetTickVolume(string symbol, int c, ENUM_TIMEFRAMES time);
    static long GetRealVolume(string symbol, int c, ENUM_TIMEFRAMES time);
    static double GetHigh(string symbol, int c, ENUM_TIMEFRAMES time);
    static double GetLow(string symbol, int c, ENUM_TIMEFRAMES time);
    static datetime GetTime(string symbol);
    static datetime GetTime(string symbol, int c, ENUM_TIMEFRAMES time);
    static int GetSpread(string symbol, int c, ENUM_TIMEFRAMES time);
    static int GetDirection(string symbol, int c, ENUM_TIMEFRAMES time);
    static int GetTimeLeft(string symbol, ENUM_TIMEFRAMES time);
    static int GetCandleIndex(string symbol, datetime time, ENUM_TIMEFRAMES timeFrame);
    static double GetHigh(int startCandle, int endCandle, string symbol, ENUM_TIMEFRAMES time);
    static double GetLow(int startCandle, int endCandle, string symbol, ENUM_TIMEFRAMES time);
};

MqlTick CCandle::candleTicks;
MqlRates CCandle::candleRates[];

/**
 * Contrutor e destrutor
 */
CCandle::CCandle()
{
}
CCandle::~CCandle()
{
}

/**
 * Retorna os valores de uma candle
 */
double CCandle::GetOpen(string symbol, int c, ENUM_TIMEFRAMES time)
{
  if(CopyRates(symbol, time, c, 1, candleRates) <= 0)
    {
      return (0);
    }
  return (candleRates[0].open);
}
double CCandle::GetClose(string symbol, int c, ENUM_TIMEFRAMES time)
{
  if(CopyRates(symbol, time, c, 1, candleRates) <= 0)
    {
      return (0);
    }
  return (candleRates[0].close);
}
long CCandle::GetTickVolume(string symbol, int c, ENUM_TIMEFRAMES time)
{
  if(CopyRates(symbol, time, c, 1, candleRates) <= 0)
    {
      return (0);
    }
  return (candleRates[0].tick_volume);
}
long CCandle::GetRealVolume(string symbol, int c, ENUM_TIMEFRAMES time)
{
  if(CopyRates(symbol, time, c, 1, candleRates) <= 0)
    {
      return (0);
    }
  return (candleRates[0].real_volume);
}
double CCandle::GetHigh(string symbol, int c, ENUM_TIMEFRAMES time)
{
  if(CopyRates(symbol, time, c, 1, candleRates) <= 0)
    {
      return (0);
    }
  return (candleRates[0].high);
}
double CCandle::GetLow(string symbol, int c, ENUM_TIMEFRAMES time)
{
  if(CopyRates(symbol, time, c, 1, candleRates) <= 0)
    {
      return (0);
    }
  return (candleRates[0].low);
}
datetime CCandle::GetTime(string symbol)
{
  if(SymbolInfoTick(symbol, candleTicks))
    {
      return (candleTicks.time);
    }
  return (0);
}
datetime CCandle::GetTime(string symbol, int c, ENUM_TIMEFRAMES time)
{
  if(CopyRates(symbol, time, c, 1, candleRates) <= 0)
    {
      return (0);
    }
  return (candleRates[0].time);
}
int CCandle::GetSpread(string symbol, int c, ENUM_TIMEFRAMES time)
{
  if(CopyRates(symbol, time, c, 1, candleRates) <= 0)
    {
      return (0);
    }
  return (candleRates[0].spread);
}
int CCandle::GetDirection(string symbol, int c, ENUM_TIMEFRAMES time)
{
  double open   = GetOpen(symbol, c, time);
  double close  = GetClose(symbol, c, time);
  int direction = 0;
  if(open > close)
    {
      direction = -1;
    }
  if(open < close)
    {
      direction = 1;
    }
  return (direction);
}
int CCandle::GetTimeLeft(string symbol, ENUM_TIMEFRAMES time)
{
  datetime candleTimeDatetime = (datetime)SeriesInfoInteger(symbol, time, SERIES_LASTBAR_DATE) + PeriodSeconds(time);
  int candleTime              = (int)candleTimeDatetime - (int)GetTime(symbol);
  candleTime -= 1;
  if(candleTime < 0)
    {
      candleTime = 0;
    }
  return (candleTime);
}
int CCandle::GetCandleIndex(string symbol, datetime time, ENUM_TIMEFRAMES timeFrame)
{
  datetime openCandleTime = CTime::GetRoundTime(time, timeFrame);
  int candle = Bars(symbol, timeFrame, openCandleTime, GetTime(symbol, 0, timeFrame)) - 1;
  return (candle >= 0 ? candle : 0);
}

double CCandle::GetHigh(int startCandle, int endCandle, string symbol, ENUM_TIMEFRAMES time)
{
  int fixDir1     = startCandle >= endCandle ? endCandle : startCandle;
  int fixDir2     = startCandle >= endCandle ? startCandle : endCandle;
  double result   = 0;
  double getValue = 0;
  for(int i = fixDir1; i <= fixDir2; i++)
    {
      getValue = GetHigh(symbol, i, time);
      result   = getValue > result ? getValue : result;
    }
  return (result);
}
double CCandle::GetLow(int startCandle, int endCandle, string symbol, ENUM_TIMEFRAMES time)
{
  int fixDir1     = startCandle >= endCandle ? endCandle : startCandle;
  int fixDir2     = startCandle >= endCandle ? startCandle : endCandle;
  double result   = 0;
  double getValue = 0;
  for(int i = fixDir1; i <= fixDir2; i++)
    {
      getValue = GetLow(symbol, i, time);
      result   = getValue < result || result == 0 ? getValue : result;
    }
  return (result);
}

#endif /* CANDLE_INCLUDED */
