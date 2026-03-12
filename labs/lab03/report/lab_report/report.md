---
## Front matter
title: "Лабораторная работа №3"
subtitle: "Агентное моделирование: Daisyworld"
author: "Чувакина Мария Владимировна"

## Generic otions
lang: ru-RU
toc-title: "Содержание"

## Bibliography
bibliography: bib/cite.bib
csl: pandoc/csl/gost-r-7-0-5-2008-numeric.csl

## Pdf output format
toc: true # Table of contents
toc-depth: 2
lof: true # List of figures
lot: true # List of tables
fontsize: 12pt
linestretch: 1.5
papersize: a4
documentclass: scrreprt
## I18n polyglossia
polyglossia-lang:
  name: russian
  options:
	- spelling=modern
	- babelshorthands=true
polyglossia-otherlangs:
  name: english
## I18n babel
babel-lang: russian
babel-otherlangs: english
## Fonts
mainfont: IBM Plex Serif
romanfont: IBM Plex Serif
sansfont: IBM Plex Sans
monofont: IBM Plex Mono
mathfont: STIX Two Math
mainfontoptions: Ligatures=Common,Ligatures=TeX,Scale=0.94
romanfontoptions: Ligatures=Common,Ligatures=TeX,Scale=0.94
sansfontoptions: Ligatures=Common,Ligatures=TeX,Scale=MatchLowercase,Scale=0.94
monofontoptions: Scale=MatchLowercase,Scale=0.94,FakeStretch=0.9
mathfontoptions:
## Biblatex
biblatex: true
biblio-style: "gost-numeric"
biblatexoptions:
  - parentracker=true
  - backend=biber
  - hyperref=auto
  - language=auto
  - autolang=other*
  - citestyle=gost-numeric
## Pandoc-crossref LaTeX customization
figureTitle: "Рис."
tableTitle: "Таблица"
listingTitle: "Листинг"
lofTitle: "Список иллюстраций"
lotTitle: "Список таблиц"
lolTitle: "Листинги"
## Misc options
indent: true
header-includes:
  - \usepackage{indentfirst}
  - \usepackage{float} # keep figures where there are in the text
  - \floatplacement{figure}{H} # keep figures where there are in the text
---



## 1. Цель работы
Изучить парадигму агентного моделирования, освоить основные понятия (агент, среда, правила поведения) и реализовать агентную модель «Daisyworld» на языке Julia с использованием библиотеки `Agents.jl`.

---

## 2. Задание

1. Создать рабочий каталог для кода.
2. Установить необходимые пакеты.
3. Выполнить предложенный код модели Daisyworld.
4. Преобразовать код в литературный стиль.
5. Сгенерировать из литературного кода:
   - чистый код;
   - jupyter notebook;
   - документацию в формате Quarto.
6. Выполнить код из jupyter notebook.
7. Интегрировать документацию в формате Quarto в отчёт.
8. Добавить в код в литературном стиле вычисление для набора параметров.
9. Сгенерировать из литературного кода с параметрами:
   - чистый код;
   - jupyter notebook;
   - документацию в формате Quarto.
10. Выполнить код из jupyter notebook с параметрами.
11. Интегрировать документацию с параметрами в формате Quarto в отчёт.


---

## 3. Этапы выполнения

### 3.1. Подготовка рабочего пространства

- Создан каталог `labs/lab03`

![Созданный каталог](image/1.png){#fig:001 width=70%}

- Создан проект DrWatson в `labs/lab03/project`

![Созданный проект DrWatson](image/2.png){#fig:002 width=70%}

- Установлены необходимые пакеты: `Agents.jl`, `CairoMakie`, `DataFrames`, `Literate.jl`, `StatsBase`, `JLD2`, `DrWatson` и др.

![Установка необходимые пакеты](image/3.png){#fig:003 width=70%}

- Проверена установка пакетов скриптом `scripts/test_setup.jl`

### 3.2. Реализация модели Daisyworld
- Создан файл `src/daisyworld.jl` с определением агента `Daisy` и функций:
  - `update_surface_temperature!` — расчёт температуры клетки
  - `diffuse_temperature!` — диффузия температуры
  - `propagate!` — размножение маргариток
  - `daisy_step!` — шаг агента (старение и смерть)
  - `daisyworld_step!` — глобальный шаг модели
  - `daisyworld` — функция инициализации
  
Создадим скрипты

![Создание скрипты](image/4.png){#fig:004 width=70%}

### 3.3. Базовые скрипты
Созданы и запущены следующие скрипты:

| Файл | Назначение | Результат |
|------|------------|-----------|
| `daisyworld.jl` | Базовая визуализация | `daisy_step001.png`, `daisy_step005.png`, `daisy_step045.png` |
| `daisyworld-animate.jl` | Анимация модели | `daisyworld_simulation.mp4` |
| `daisyworld-count.jl` | Анализ численности | `daisy_count.png` |
| `daisyworld-luminosity.jl` | Влияние солнечной активности | `daisy_luminosity_ramp.png`, `daisy_luminosity_change.png` |

### 3.4. Литературное программирование
Созданы литературные версии всех скриптов (`*_literate.jl`) с подробными Markdown-комментариями:

- `daisyworld_literate.jl`
- `daisyworld-animate_literate.jl`
- `daisyworld-count_literate.jl`
- `daisyworld-luminosity_literate.jl`
- `daisyworld_param_literate.jl`
- `daisyworld-count_param_literate.jl`
- `daisyworld-luminosity_param_literate.jl`

С помощью `scripts/tangle.jl` сгенерированы:
- Чистый код в папку `scripts/` (подпапки для каждого скрипта)
- Jupyter notebooks в папку `notebooks/`
- Quarto-документы в папку `markdown/`

### 3.5. Параметрические исследования
Созданы и запущены три параметрических скрипта:

#### 3.5.1. Базовая параметрическая визуализация (`daisyworld__param.jl`)
Исследованы комбинации параметров:
- `max_age`: 25, 40
- `init_white`: 0.2, 0.8

Получено 4 графика, сохранённых в `plots/daisyworld_param/`

#### 3.5.2. Параметрическое исследование численности (`daisyworld-count__param.jl`)
Для тех же комбинаций параметров построены графики динамики численности.
Получено 4 графика в `plots/daisyworld-count_param/`

#### 3.5.3. Комплексное параметрическое исследование (`daisyworld-luminosity__param.jl`)
Со сценарием `:ramp` (изменение солнечной активности) построены комплексные графики (численность, температура, активность).
Получено 4 графика в `plots/daisyworld-luminosity_param/`

#### 3.5.4. Генерация производных форматов

Сгенерируем производные форматы для всех литературных скриптов

![Генерация производных форматов](image/5.png){#fig:005 width=70%}

### 3.6. Создание отчёта

- Создан файл `report.qmd` в папке `report/`
- Подключена преамбула `preamble.tex` для поддержки русского языка:
  ```latex
  \usepackage{fontspec}
  \usepackage{polyglossia}
  \setmainlanguage{russian}
  \setotherlanguage{english}
  \setmainfont{FreeSerif}
  \setsansfont{FreeSans}
  \setmonofont{FreeMono}
```
  
Добавлены все графики с подписями

Скомпилированы report.pdf и report.docx

![Компиляция](image/6.png){#fig:006 width=70%}

### 3.7. Отправка на GitVerse и GitHub

Все изменения добавлены в Git

Создан коммит: feat: complete lab03 agent-based modeling with all analyses

Изменения отправлены на GitVerse и GitHub

# 4. Полученные результаты


#### 4.1. Базовая визуализация

На рисунках 1-3 показана эволюция модели Daisyworld на разных шагах:

Шаг 0 — начальное случайное распределение маргариток (20% чёрных, 20% белых)

Шаг 5 — начало самоорганизации, формируются первые кластеры

Шаг 45 — установление равновесия, система пришла к стабильному состоянию

![Начальное состояние (шаг 0)](image/daisy_step001.png){#fig:step1 width=70%}

![После 5 итераций (шаг 5)](image/daisy_step005.png){#fig:step5 width=70%}

![После 45 итераций (шаг 45)](image/daisy_step045.png){#fig:step45 width=70%}

#### 4.2. Анализ численности

График динамики численности (рис. 4) показывает, как черные и белые маргаритки конкурируют и приходят к равновесию. Чёрные маргаритки нагревают планету, создавая условия для белых, которые её охлаждают — возникает отрицательная обратная связь, обеспечивающая саморегуляцию.

![Динамика численности маргариток](image/daisy_count.png){#fig:count width=100%}

#### 4.3. Влияние солнечной активности

Сценарий ramp (рис. 5)

Солнечная активность сначала растёт (шаги 200-400), затем остаётся постоянной, потом снижается (шаги 500-750). Система успевает адаптироваться к изменениям, численность маргариток колеблется, но температура остаётся в пригодных пределах.
Сценарий change (рис. 6)

Солнечная активность постоянно растёт. При превышении критического уровня маргаритки погибают, система теряет способность к саморегуляции.

![Влияние солнечной активности (сценарий ramp)](image/daisy_luminosity_ramp.png){#fig:luminosity-ramp width=100%}

![Влияние солнечной активности (сценарий change)](image/daisy_luminosity_change.png){#fig:luminosity-change width=100%}

### 4.4. Параметрические исследования

#### 4.4.1. Базовая параметрическая визуализация

Исследованы четыре комбинации параметров (рис. 7-10):

- max_age=25, init_white=0.2

- max_age=25, init_white=0.8

- max_age=40, init_white=0.2

- max_age=40, init_white=0.8

![Параметрическое исследование (max_age=25, init_white=0.2)](image/daisyworld_param/daisyworld_param_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.2_max_age=25_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:param1 width=100%}

![Параметрическое исследование (max_age=25, init_white=0.8)](image/daisyworld_param/daisyworld_param_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.8_max_age=25_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:param2 width=100%}

![Параметрическое исследование (max_age=40, init_white=0.2)](image/daisyworld_param/daisyworld_param_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.2_max_age=40_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:param3 width=100%}

![Параметрическое исследование (max_age=40, init_white=0.8)](image/daisyworld_param/daisyworld_param_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.8_max_age=40_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:param4 width=100%}

#### 4.4.2. Параметрическое исследование численности

Графики динамики численности для тех же комбинаций параметров (рис. 11-14).

#### 4.4.3. Комплексное параметрическое исследование

Графики, показывающие численность, температуру и солнечную активность для всех комбинаций 

Выводы из параметрического исследования:

- Увеличение max_age делает популяцию более стабильной

- Начальная доля белых (init_white) сильно влияет на переходный процесс

- Система стремится к равновесию независимо от начальных условий

- Наибольшая общая численность достигается при max_age=40

# 5. Выводы

В ходе выполнения лабораторной работы:

- Освоены основные понятия агентного моделирования: агент, среда, правила поведения, эмерджентность.

- Изучен пакет Agents.jl — основной инструмент для агентного моделирования в Julia.

- Реализована модель Daisyworld, демонстрирующая саморегуляцию климата через взаимодействие чёрных и белых маргариток.

- Проведён анализ динамики системы при различных значениях параметров.

- Освоено литературное программирование с использованием Literate.jl — созданы скрипты, объединяющие код и документацию.

- Сгенерированы производные форматы: чистый код, Jupyter notebooks, Quarto-документы.

- Подготовлен отчёт в форматах PDF и DOCX.

- Результаты отправлены на GitVerse.

Работа позволила на практике освоить принципы агентного моделирования и закрепить навыки работы с языком Julia.

# 6. Список литературы

1. Datseris G., Vahdati A. R., DuBois T. C. Agents.jl: a performant and feature-full agent-based modeling software of minimal code complexity // SIMULATION. — 2022. — DOI: 10.1177/00375497211068820.
2. Watson A. J., Lovelock J. E. Biological homeostasis of the global environment: the parable of Daisyworld // Tellus B: Chemical and Physical Meteorology. — 1983. — Vol. 35, no. 4. — P. 284.
3. Wood A. J. et al. Daisyworld: A review // Reviews of Geophysics. — 2008. — Vol. 46, no. 1.


