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