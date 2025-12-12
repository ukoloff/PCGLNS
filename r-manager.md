# RoutingManager и PCGLNS

Взаимодействие программ:
- RoutingManager для генерации заданий на резку
- PCGLNS (этот репозиторий) для маршрутизации
- [j2pcgtsp](https://ukoloff.github.io/j2pcgtsp/) для визуализации маршрута

 ## Установка PCGLNS

 Специализированного установщика для PCGLNS нет,
 самый прямой путь - скачать репозиторий, например:
```sh
git clone https://github.com/ukoloff/PCGLNS
```

Кроме того, 
для работы программы требуется [Julia](https://julialang.org/),
причём версия v12 уже не годится,
требуется более старшая.
Рекомендуем v10:
- [zip / Portable](https://julialang-s3.julialang.org/bin/winnt/x64/1.10/julia-1.10.10-win64.zip)
- [Установщик](https://julialang-s3.julialang.org/bin/winnt/x64/1.10/julia-1.10.10-win64.exe)

Для работы конвертера [PCGTSP > PCGLNS](./convertToPCGLNS.py)
требуется Python,
проблем с версией не обнаружено:
+ [v3.14](https://www.python.org/ftp/python/3.14.2/python-3.14.2-amd64.exe)

### Scoop
Всё ПО удобнее установить при помощи
[Scoop](https://scoop.sh/):
```powershell
# Сам Scoop
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# git
scoop install main/git

# python
scoop install main/python

# Julia
scoop bucket add versions
scoop install versions/julia-lts
```

## Инструкция

### Sirius
Для генерации деталей, листов и заданий на раскрой
может использоваться САПР "Сириус".
Описание работы с ней не входит в рамки
данного документа.

Дистрибутив САПР "Сириус"
доступен в 
[облаке](https://cloud.mail.ru/public/76fL/qeNrGdK1Q/2021Q1).

САПР "Сириус" использует формат
[DBS](https://github.com/ukoloff/dbs.js/wiki/DBS)
для хранения геометрии.
RoutingManager принимает на вход
[JSON](https://github.com/ukoloff/dbs.js/tree/master/json-schema)-файл.
Для конвертации созданы
[утилиты](https://github.com/ukoloff/dbs.js),
в частности
- [dbs2json](https://github.com/ukoloff/dbs.js/tree/master/src/dbs2json) для конвертации
- [rm-launch](https://github.com/ukoloff/dbs.js/tree/master/src/rm-launch),
    которая 
    + конвертирует DBS в JSON
    + Сразу же запускает RoutingManager
    + Название запускаемой программы прописано в тексте утилиты и может быть изменено в текстовом редакторе
    + Утилита по умолчанию добавлена в меню САПР "Сириус" как `Маршрутизация`

### RoutingManager

Работоспособность текущей схемы была проверена
с версией программы
`RoutingManager2025.exe`

Для работы PCGLNS 
`RoutingManager`
должен экспортировать 3 файла:
+ PCGTSP (метрическая) - матрица расстояний между точками врезки    
    + Файл: `имя.pcgtsp`
    + [Пример](https://github.com/ukoloff/j2pcgtsp/blob/master/data/8877.pcgtsp)
+ JSON - координаты точек врезки и их разбиение на кластеры
    + Файл: `имя.json`
    + [Пример](https://github.com/ukoloff/j2pcgtsp/blob/master/data/8877.json)
+ JSON для DBS - описание геометрии контуров
    + Файл: `имя.dbs.json`
    + [Пример](https://github.com/ukoloff/j2pcgtsp/blob/master/data/8877_01.DBS.JSON)
    + Если `RoutingManager` получает геометрию из Сириус в виде JSON,
        то можно использовать этот входной файл, 
        экспорт не требуется

### PCGLNS

PCGLNS - утилита командной строки,
для её запуска был создан специальный 
[GUI](./pcglns-gui.ps1)
на PowerShell,
который в свою очередь можно запустить ярлыком примерно такого содержания 
```powershell
powershell -f path/to/pcglns-gui.ps1
```

Данная утилита
+ Просит указать исходный файл в формате PCGTSP 
    (сформированный при помощи `RoutingManager`)
    + Можно сразу указать файл в формате PCGLNS
+ Самостоятельно запускает [конвертер из PCGTSP в PCGLNS](./convertToPCGLNS.py)
+ Позволяет ввести параметры алгоритма
    + Режим: быстрый, медленный или по умолчанию
    + Trials (количество попыток?) - целое число
    + Restarts (количество перезапусков?) - целое число
    + Epsilon: число от 0.0 до 1.0
    + Reopts: число от 0.0 до 1.0
+ Запускает собственно [PCGLNS](./runPCGLNS.jl) с указанными параметрами
+ По окончании открывает программу визуализации 

На этом этапе JSON-файлы не используются,
они нужны на последнем этапе - визуализации.

### j2gtsp
Утилита позволяет визуализировать маршрут.

Утилита существует в нескольких видах,
основной - веб-сайт
https://ukoloff.github.io/j2pcgtsp/
.
Там же есть ссылки на скачивание:
+ [offline-версия](https://ukoloff.github.io/j2pcgtsp/j2gtsp.html) сайта, для работы без доступа в Интернет
+ Утилиты командной строки 
    (для Windows и Linux), 
    для генерации HTML-файла, допускают автоматизацию

На страницу визуализации следует загрузить 
(через кнопку Upload или Drag-n-drop)
файлы:
+ `имя.dbs.json`, созданный в `RoutingManager` или САПР "Сириус"
+ `имя.json`, созданный в `RoutingManager`
+ `имя.result.txt`, созданный эвристикой PCGLNS 
    ([пример](https://github.com/ukoloff/j2pcgtsp/blob/master/data/8877-2.result%20(2).txt))

Утилита рассчитывает и отображает длину холостого хода
и позволяет посмотреть полученный путь
или экспортировать его в HTML-файл.
