local settings = {}

settings.REPOSITORY = "https://raw.githubusercontent.com/Krobys/casino/master"
settings.TITLE = "Приветствуем ваc у нас в казино"
settings.ADMINS = { "Krobys" }

-- CHEST - Взаимодействие сундука и МЕ сети
-- PIM - Взаимодействие PIM и МЕ сети
-- CRYSTAL - Взаимодействие кристального сундука и алмазного сундука
-- CRYSTAL_ME - Взаимодействие кристального сундука и МЕ сети
-- DEV - Оплата не взимается, награда не выдается, не требует внешних компонентов
settings.PAYMENT_METHOD = "CRYSTAL_ME"
settings.CONTAINER_PAY = "DOWN"
settings.CONTAINER_GAIN = "UP"

return settings;