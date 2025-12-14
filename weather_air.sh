#!/bin/sh
# Tổng hợp thời tiết & chất lượng không khí TP.HCM
# API: Open-Meteo (không cần API key)

LAT=10.8231
LON=106.6297
TZ="Asia/Ho_Chi_Minh"

WEATHER_URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current_weather=true&timezone=$TZ"
AIR_URL="https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$LAT&longitude=$LON&current=pm2_5,pm10&timezone=$TZ"

WEATHER_JSON=$(wget -qO- "$WEATHER_URL")
AIR_JSON=$(wget -qO- "$AIR_URL")

# Thời tiết
TEMP=$(echo "$WEATHER_JSON" | jsonfilter -e '@.current_weather.temperature')
CODE=$(echo "$WEATHER_JSON" | jsonfilter -e '@.current_weather.weathercode')

# Không khí
PM25=$(echo "$AIR_JSON" | jsonfilter -e '@.current.pm2_5')

# Map weathercode → tiếng Việt
case "$CODE" in
  0) DESC="Trời quang" ;;
  1|2) DESC="Ít mây" ;;
  3) DESC="Nhiều mây" ;;
  45|48) DESC="Sương mù" ;;
  51|53|55) DESC="Mưa phùn" ;;
  61|63|65) DESC="Mưa" ;;
  80|81|82) DESC="Mưa rào" ;;
  95) DESC="Dông" ;;
  96|99) DESC="Dông mạnh" ;;
  *) DESC="Không xác định" ;;
esac

# Đánh giá PM2.5
if [ "$PM25" -le 12 ]; then
  AIR_LEVEL="Tốt"
elif [ "$PM25" -le 35 ]; then
  AIR_LEVEL="Trung bình"
else
  AIR_LEVEL="Kém"
fi

# Output
echo "TP.HCM: ${TEMP}°C - $DESC | PM2.5: ${PM25} µg/m³ ($AIR_LEVEL)"
