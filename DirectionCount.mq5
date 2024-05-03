//+------------------------------------------------------------------+
//|                                               DirectionCount.mq5 |
//|                                        Copyright 2023, UpCoding. |
//|                                         https://www.upcoding.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, UpCoding."
#property link "https://www.upcoding.net"
#property version "1.00"

// Descrição
#property description "▸ Indicador de contagem de candles."
#property description ""
#property description "Buffers:"
#property description "0 = Soma total de candles;"
#property description "1 = Candles de alta;"
#property description "2 = Candles neutras; (close==open)"
#property description "3 = Candles de baixa;"
#property description ""

// Inputs
input uint inputCandles              = 0;              // Distancia em candles para calcular: [0 = Até abertura]
input ENUM_TIMEFRAMES inputTimeFrame = PERIOD_CURRENT; // Tempo gráfico:
input bool inputShowComment          = false;          // Ativar comentário com informações do valores?

// Configuração das linas
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 0

// Bibliotecas
#include "Include/Sources/Utilities/Candle.mqh"
#include "Include/Sources/Utilities/Math/Math.mqh"

double _count[];
double _upCount[];
double _neutralcount[];
double _downCount[];

/*
 * Inicialização
 */
int OnInit()
{
  SetIndexBuffer(0, _count, INDICATOR_DATA);
  SetIndexBuffer(1, _upCount, INDICATOR_CALCULATIONS);
  SetIndexBuffer(2, _neutralcount, INDICATOR_CALCULATIONS);
  SetIndexBuffer(3, _downCount, INDICATOR_CALCULATIONS);

  string periorName = EnumToString(inputTimeFrame);
  StringReplace(periorName, "PERIOD_", "");
  string name = StringFormat("DirCount(%d, %s, %s)", inputCandles, periorName, (string)inputShowComment);
  IndicatorSetString(INDICATOR_SHORTNAME, name);
  return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
  Comment("");
};

/*
 * Calculador
 */
int OnCalculate(const int rates_total, const int prev_calculated, const datetime& time[], const double& open[], const double& high[], const double& low[], const double& close[],
                const long& tick_volume[], const long& volume[], const int& spread[])
{
  static int lastCandle = -1;
  int candlesPercent    = (int)CMath::GetPercentOfValue(rates_total, 10);
  int pos               = prev_calculated == 0 ? rates_total - candlesPercent : prev_calculated - 1;
  for(int i = pos; i < rates_total; i++)
    {
      int candle           = rates_total - i;
      datetime startTime   = 0;
      datetime currentTime = CTime::GetTime(Symbol(), candle, inputTimeFrame);
      if(inputCandles == 0)
        {
          startTime = CTime::GetStartTime(Symbol(), GetTimeType(inputTimeFrame));
        }
      else
        {
          startTime = CTime::GetTime(Symbol(), candle + (inputCandles - 1), inputTimeFrame);
        }
      int startCandle = CCandle::GetCandleIndex(Symbol(), startTime, inputTimeFrame);
      UpdateBuffers(i, startCandle, candle);
    }
  return (rates_total);
}

void UpdateBuffers(int bufferIndex, int startCandle, int endCandle)
{
  double up      = 0;
  double neutral = 0;
  double down    = 0;
  double all     = 0;
  int dir        = 0;
  for(int i = startCandle; i >= endCandle; i--)
    {
      dir = CCandle::GetDirection(Symbol(), i, inputTimeFrame);
      if(dir == 0)
        {
          neutral++;
        }
      else if(dir == 1)
        {
          up++;
        }
      else
        {
          down++;
        }
      all = up + neutral + down;
    }
  _count[bufferIndex]        = all;
  _upCount[bufferIndex]      = up;
  _neutralcount[bufferIndex] = neutral;
  _downCount[bufferIndex]    = down;
  SendComment(bufferIndex);
}

void SendComment(int bufferIndex)
{
  if(inputShowComment)
    {
      if(bufferIndex >= 0)
        {
          int size = (int)_count.Size() - 1;
          if(bufferIndex == size)
            {
              double all     = _count[bufferIndex];
              double up      = _upCount[bufferIndex];
              double neutral = _neutralcount[bufferIndex];
              double down    = _downCount[bufferIndex];
              Comment(StringFormat("\nDIRECTIONCOUNT:\n\nTotais: %.0f\nAltas: %.0f\nBaixas: %.0f\nNeutras: %.0f", all, up, down, neutral));
            }
        }
    }
}

ENUM_TIME_TYPE GetTimeType(ENUM_TIMEFRAMES type)
{
  if(type == PERIOD_CURRENT)
    {
      type = _Period;
    }
  switch(type)
    {
    case PERIOD_D1:
    case PERIOD_W1:
    case PERIOD_MN1:
      {
        return (TIME_TYPE_YEAR);
      }
    default:
      return (TIME_TYPE_DAY);
    }
}