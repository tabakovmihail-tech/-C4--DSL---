workspace "File Manager" "C4-модель настольного файлового менеджера" {
  model {
    user = person "Пользователь" "Работает с файлами и каталогами на своем компьютере через графический интерфейс."

    fileManager = softwareSystem "Файловый менеджер" "Настольное приложение для операций с файлами и папками, архивации и поиска." {
      desktopApp = container "Desktop GUI Application" "Графический интерфейс файлового менеджера, окна и виджеты для работы с файловой системой." "Python + PyQt5/tkinter" {
        uiLayer = component "UI Layer" "Окна, панели, дерево каталогов, таблица файлов, диалоговые окна." "PyQt5/tkinter Widgets"
        commandController = component "Command Controller" "Обработка действий пользователя, формирование команд к модулю файловых операций." "Python"
        settingsService = component "SettingsService" "Чтение/запись настроек и истории в локальное хранилище." "Python"
      }
      
      fileOpsModule = container "File Operations Module" "Модуль выполнения операций с файлами и каталогами через системные API." "Python (os, shutil, модули архивации)" {
        fileSystemService = component "FileSystemService" "Реализация операций копирования, перемещения, удаления, переименования, архивации, поиска." "Python"
        loggingSecurity = component "LoggingAndSecurity" "Логирование действий и проверки безопасности при критических операциях." "Python"
      }
      
      localStorage = container "Local Storage" "Локальное хранилище настроек, истории и служебных данных." "JSON / SQLite" {
        // Этот контейнер теперь просто хранилище без компонентов
      }
    }

    operatingSystem = softwareSystem "Операционная система" "Файловая система и системные API, предоставляющие доступ к дискам, файлам и каталогам." {
      tags "External"
    }

    // Все отношения объявляем внутри блока model
    user -> fileManager "Работает с файлами и папками через приложение"
    fileManager -> operatingSystem "Выполняет операции с файлами и каталогами" "Системные вызовы / API"

    // Relationships Level 2 (Containers)
    user -> desktopApp "Взаимодействует через графический интерфейс" "Mouse/Keyboard"
    desktopApp -> fileOpsModule "Отправляет команды на выполнение операций с файлами" "Внутрипроцессные вызовы"
    desktopApp -> localStorage "Читает и сохраняет настройки, историю, закладки" "Файловый доступ / SQL"
    fileOpsModule -> operatingSystem "Вызывает системные API для работы с файлами" "OS API (fs operations)"
    fileOpsModule -> localStorage "При необходимости читает/пишет вспомогательные данные" "Файловый доступ / SQL"

    // Relationships Level 3 (Components)
    user -> uiLayer "Взаимодействует с окнами и панелями"
    uiLayer -> commandController "Передает события пользовательских действий"
    commandController -> fileSystemService "Вызывает операции над файлами и папками"
    commandController -> settingsService "Читает/сохраняет пользовательские настройки и историю"
    commandController -> loggingSecurity "Фиксирует действия и запрашивает проверки безопасности"

    settingsService -> localStorage "Работает с конфигурацией и служебными данными" "JSON/SQL"
    
    fileSystemService -> operatingSystem "Выполняет операции в файловой системе" "OS API"
    fileSystemService -> loggingSecurity "Записывает результаты операций и ошибки"
    loggingSecurity -> localStorage "Сохраняет логи и параметры безопасности (при необходимости)" "JSON/SQL"
  }

  views {
    systemContext fileManager "SystemContext" {
      include *
      autoLayout
    }

    container fileManager "Containers" {
      include *
      autoLayout
    }

    // Создаем отдельные диаграммы компонентов для каждого контейнера
    component desktopApp "DesktopAppComponents" {
      include *
      autoLayout
    }

    component fileOpsModule "FileOperationsComponents" {
      include *
      autoLayout
    }
    
    styles {
      element "Person" {
        background "#08427b"
        color "#ffffff"
        shape Person
      }
      element "Software System" {
        background "#1168bd"
        color "#ffffff"
      }
      element "Container" {
        background "#438dd5"
        color "#ffffff"
      }
      element "Component" {
        background "#85bbf0"
        color "#000000"
      }
    }
  }
}