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

