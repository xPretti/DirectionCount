//+------------------------------------------------------------------+
//|                                                         Math.mqh |
//|                                        Copyright 2023, Upcoding. |
//|                                         https://www.upcoding.net |
//+------------------------------------------------------------------+

#ifndef MATH_INCLUDED
#define MATH_INCLUDED

#include "../../Enumerators/IncrementEnum.mqh"

// clang-format off
class CMath
{
  public:
    CMath();
    ~CMath();

    // Methods
    static double ToPositive(double value) { if(value < 0) {return (value * -1);} return (value); };
    static int ToPositive(int value) { if(value < 0){return (value * -1);} return (value); };
    static double ToNegative(double value) { if(value > 0){return (value * -1);} return (value); };
    static int ToNegative(int value) { if(value > 0) {return (value * -1);} return (value); };
    static uint ToCountStep(double value, double step);
    static uint ToCountGradualStep(double value, double step, double stepMultiplier = 1);
    static double ToDivide(double value, double divide);
    static double ToRestDivide(double value, double divide);
    
    //- GET
    static double GetPercent(double value, double target);
    static double GetCorrectPrice(string symbol, double price);
    static double GetPercentOfValue(double value, double percent);
    static double GetDecimalDigits(string symbol);
    //- to points
    static double GetTicksToPoints(string symbol, double ticksValue);
    static double GetMoneyToPoints(string symbol, double moneyValue);
    static double GetPipsToPoints(string symbol, double pips);
    static double GetPercentEquilityToPoints(string symbol, double percent);
    static double GetPercentMarketToPoints(string symbol, double percent);

    //- cálculos
    static double GetMedian(double v1, double v2) { return ((v1 + v2) / 2); };
    static double GetVariation(double v1, double v2) { return (v1 < v2 ? NormalizeDouble(((v2 - v1) / v1 * 100), 2) : -NormalizeDouble(((v1 - v2) / v2 * 100), 2)); };
    static double GetHitPercent(double gain, double loss);
    static double GetIncrement(double value, double valueToIncrement, ENUM_INCREMENT_METHOD_TYPE incrementType);
    static double GetIncrementByPercentage(double value, double valueToIncrement, ENUM_INCREMENT_METHOD_TYPE incrementType);
    static int GetRandomInt(int min, int max);
    
    //- comparadores
    static bool IsNearlyEqual(double a, double b) { return (MathAbs(a - b) < 1.0e-8); };
    static bool IsEqual(double a, double b) { return (a == b || IsNearlyEqual(a, b)); };
    static bool IsDifferent(double a, double b) { return (a != b && !IsNearlyEqual(a, b)); };
    static bool IsGreater(double a, double b) { return (a > b && !IsNearlyEqual(a, b)); };
    static bool IsSmaller(double a, double b) { return (a < b && !IsNearlyEqual(a, b)); };
    static bool IsGreaterOrEqual(double a, double b) { return (a >= b || IsNearlyEqual(a, b)); };
    static bool IsSmallerOrEqual(double a, double b) { return (a <= b || IsNearlyEqual(a, b)); };
};
// clang-format on

/**
 * Contrutores e Destrutores
 */
CMath::CMath()
{
}
CMath::~CMath()
{
}

/**
 * Conversores
 */
uint CMath::ToCountStep(double value, double step)
{
  uint roundValue = (uint)MathFloor(value / step);
  return (roundValue);
}
uint CMath::ToCountGradualStep(double value, double step, double stepMultiplier = 1)
{
  double newValue = value;
  double newStep  = step;
  uint count      = 0;
  while(ToCountStep(newValue, newStep) > 0)
    {
      count++;
      newValue -= newStep;
      newStep += step = (step * stepMultiplier);
    }
  return (count);
}

/**
 * Corrige o preço passado como parâmetro para o valor correto do ativo
 */
double CMath::GetCorrectPrice(string symbol, double price)
{
  double tickSize        = SymbolInfoDouble(symbol, SYMBOL_POINT);
  int digits             = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
  double roundValue      = round(price / tickSize);
  double normalizedPrice = roundValue * tickSize;
  normalizedPrice        = NormalizeDouble(normalizedPrice, digits);
  return (normalizedPrice);
}

/**
 * Retorna a quantidade de porcentagem do valor
 */
double CMath::GetPercentOfValue(double value, double percent)
{
  double correntPercent = percent / 100;
  value *= correntPercent;
  return (NormalizeDouble(value, 2));
}
double CMath::GetHitPercent(double gain, double loss)
{
  double total = gain + loss;
  if(total > 0)
    {
      return (NormalizeDouble(((gain * 100) / total), 2));
    }
  return (0);
}
double CMath::GetPercent(double value, double target)
{
  double percent = (((value - target) / target) * 100.0) + 100;
  return (NormalizeDouble(percent, 2));
}

/**
 * Retorna o valor incrementado pelo tipo
 */
double CMath::GetIncrement(double value, double valueToIncrement, ENUM_INCREMENT_METHOD_TYPE incrementType)
{
  switch(incrementType)
    {
    case INCREMENT_METHOD_TYPE_MULTIPLY:
      return (value * valueToIncrement);
    case INCREMENT_METHOD_TYPE_REMOVE:
      return (value - valueToIncrement);
    case INCREMENT_METHOD_TYPE_DIVIDE:
      return (ToDivide(value, valueToIncrement));
    case INCREMENT_METHOD_TYPE_DEFINE:
      return (valueToIncrement);
    default:
      return (value + valueToIncrement);
    }
}
double CMath::GetIncrementByPercentage(double value, double valueToIncrement, ENUM_INCREMENT_METHOD_TYPE incrementType)
{
  switch(incrementType)
    {
    case INCREMENT_METHOD_TYPE_MULTIPLY:
      return (value * GetPercentOfValue(value, valueToIncrement));
    case INCREMENT_METHOD_TYPE_REMOVE:
      return (value - GetPercentOfValue(value, valueToIncrement));
    case INCREMENT_METHOD_TYPE_DIVIDE:
      return (ToDivide(value, GetPercentOfValue(value, valueToIncrement)));
    case INCREMENT_METHOD_TYPE_DEFINE:
      return (GetPercentOfValue(value, valueToIncrement));
    default:
      return (value + GetPercentOfValue(value, valueToIncrement));
    }
}

/**
 * Gera um número aleatório
 */
int CMath::GetRandomInt(int min, int max)
{
  double f = (MathRand() / 32768.0);
  return min + (int)(f * (max - min));
}

/**
 * Retorna a quantidade de digitos convertidos em decimais
 */
double CMath::GetDecimalDigits(string symbol)
{
  int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
  if(digits > 1)
    {
      string zeroToAdd      = StringFormat("0.%%0%d", digits);
      string fixDigitFormat = StringFormat("%s.f", zeroToAdd);
      string decimalString  = StringFormat(fixDigitFormat, 10);
      double digitDecimal   = StringToDouble(decimalString);
      return (digitDecimal);
    }
  return (0);
}

/**
 * Conversores para pontos
 */
double CMath::GetTicksToPoints(string symbol, double ticksValue)
{
  double ticks = SymbolInfoDouble(symbol, SYMBOL_POINT);
  return (ticks * ticksValue);
}
double CMath::GetMoneyToPoints(string symbol, double moneyValue)
{
  double ticks      = SymbolInfoDouble(symbol, SYMBOL_POINT);
  double ticksMoney = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
  double minVolume  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
  return (ticks * (moneyValue / (ticksMoney * minVolume)));
}
double CMath::GetPipsToPoints(string symbol, double pips)
{
  double digits = GetDecimalDigits(symbol) * pips;
  return (digits);
}
double CMath::GetPercentEquilityToPoints(string symbol, double percent)
{
  double accountEquility = AccountInfoDouble(ACCOUNT_EQUITY);
  double percentValue    = GetPercentOfValue(accountEquility, percent);
  return (GetMoneyToPoints(symbol, percentValue));
}
double CMath::GetPercentMarketToPoints(string symbol, double percent)
{
  double bid          = SymbolInfoDouble(symbol, SYMBOL_BID);
  double percentValue = GetPercentOfValue(bid, percent);
  return (percentValue);
}

// Métodos seguros
double CMath::ToDivide(double value, double divide)
{
  if(divide != 0)
    {
      return (value / divide);
    }
  return (value);
}
double CMath::ToRestDivide(double value, double divide)
{
  if(divide != 0)
    {
      return (MathMod(value, divide));
    }
  return (value);
}

#endif /* MATH_INCLUDED */
