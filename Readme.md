# Разворачивание инфраструктуры

## terrafrom - разворачивание необходимой инфраструктуры в YC
- В каталоге terrafrom запустить terraform apply для разворачивания кластера, terrafrom destroy для удаления
- Ingress удаляется долго, хз, обратить внимание на зависимость модуля ingress от node_groups - иначе удаление происходит коряво, ноду умирают раньше чем ingress
- Набор yml переработан и основан на https://github.com/claustrophobia-com/yandex-cloud-kubernetes
