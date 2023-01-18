# Alert manager

- [Задание](#Задание)
- [Установка](#Установка)
- [Настройка пары простых алертов](#Настройка_пары_простых_алертов)
- [Настройка отправки алертов в telegram](#Настройка_отправки_алертов_в_telegram)

## Задание
1. Установить Node Exporter и добавить его в Prometheus
2. Поскольку не все коллекторы используются в вашей системе, необходимо отключить те, которые не используются.
3. Сделать простой скрипт для Textfile-collector по любой метрике, которая отсутствует в node-exporter, обосновать почему вы решили ее использовать.

## Установка
Скачиваем архив со всеми необходимыми файлами
```
wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanag0.24.0.linux-amd64.tar.gz
```
Распакуем архив в директорию /tmp
```
tar xvf alertmanager-0.24.0.linux-amd64.tar.gz -C /tmp
```
Скопируем бинарные файлы Alertmanager и утилиты проверок amtool
```
cp /tmp/alertmanager-0.24.0.linux-amd64/alertmanager /usr/local/bin/
cp /tmp/alertmanager-0.24.0.linux-amd64/amtool /usr/local/bin/
```
Создадим директорию для конфигурационных файлов и DB Alertmanager
```
mkdir -p /etc/alertmanager
mkdir /var/lib/alertmanager
```
Добавим в /etc/alertmanager/alertmanager.yml
```
global:
  smtp_smarthost: localhost:25
  smtp_from: alertmanager@example.com   
  resolve_timeout: 3m 
receivers:
  - name: 'myemail'
    email_configs:
      - to: 'iv.medvedev179@gmail.com'
route:   
  receiver: myemail   
  repeat_interval: 1m   
  routes: 
  - group_by:     
    - alertname 
inhibit_rules:   
  - source_match:       
      severity: 'critical'     
    target_match:       
      severity: 'warning'    
    equal: ['alertname', 'dev', 'instance']
```
Создадим специального пользователя и группу
```
useradd --no-create-home --shell /bin/false alertmanager
```
Сменим разрешения на директории 
```
chown alertmanager:alertmanager -R /etc/alertmanager
chown alertmanager:alertmanager -R /var/lib/alertmanager
```
Создадим юнит для запуска, добавим в /lib/systemd/system/alertmanager.service
```
[Unit] 
Description=Alertmanager service 

[Service] 
User=alertmanager 
Group=alertmanager 

ExecStart=/usr/local/bin/alertmanager --config.file /etc/alertmanager/alertmanager.yml --storage.path=/var/lib/alertmanager/ --web.listen-address=0.0.0.0:9093 --data.retention=480h 

[Install] 
WantedBy=multi-user.target
```

Запустим сервис
```
systemctl daemon-reload 
systemctl enable alertmanager.service 
systemctl start alertmanager.service
```

Добавим Alertmanager в конфигурацию Prometheus /etc/prometheus/prometheus.yml
```
alerting:   
  alertmanagers: 
  - static_configs:     
    - targets:       
      - localhost:9093 
rule_files: 
- /etc/prometheus/dynamic-rules.yml
```

Применим изменения Prometheus
```
systemctl restart prometheus.service
```

## Настройка пары простых алертов

## Настройка отправки алертов в telegram