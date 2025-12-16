
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Начало генерации документации ===${NC}"

# Используем текущую директорию
PROJECT_DIR="$PWD"
echo -e "${GREEN}Рабочая директория:${NC} $PROJECT_DIR"
echo -e "${GREEN}Windows путь:${NC} $(pwd -W)"

# Преобразуем путь для Docker (Windows -> Linux формат)
if [[ "$PROJECT_DIR" == /[a-zA-Z]/* ]]; then
    # Git Bash формат /d/path -> D:/path
    DRIVE_LETTER="${PROJECT_DIR:1:1}"
    WIN_PATH="${DRIVE_LETTER^^}:${PROJECT_DIR:2}"
    DOCKER_PATH="/${DRIVE_LETTER}${PROJECT_DIR:2}"
else
    WIN_PATH="$PROJECT_DIR"
    DOCKER_PATH="$PROJECT_DIR"
fi

echo -e "${GREEN}Docker путь:${NC} $DOCKER_PATH"

# 1. Генерация C4-диаграмм
echo -e "${BLUE}[1/3] Генерация C4-диаграмм...${NC}"

mkdir -p "docs/c4-diagrams"

echo "Компиляция и запуск Java-кода..."
if mvn clean compile exec:java -Dexec.mainClass=com.example.structurizr.FileManagerModel; then
    echo -e "${GREEN}✓ Java-код выполнен успешно${NC}"
else
    echo -e "${RED}Ошибка выполнения Java-кода${NC}"
    exit 1
fi

# Перемещаем файл
if [ -f "file-manager-workspace.json" ]; then
    mv "file-manager-workspace.json" "docs/c4-diagrams/"
    echo -e "${GREEN}✓ Файл диаграмм: docs/c4-diagrams/file-manager-workspace.json${NC}"
else
    echo -e "${YELLOW}⚠ Файл не найден${NC}"
fi

# 2. Генерация кода из Swagger
echo -e "${BLUE}[2/3] Генерация Flask сервера...${NC}"

API_SPEC="docs/api-specification/file-manager-api.yaml"
if [ -f "$API_SPEC" ]; then
    echo -e "${GREEN}Найден файл API спецификации${NC}"
    echo -e "${BLUE}Docker путь:${NC} $DOCKER_PATH"

    docker run --rm \
        -v "${DOCKER_PATH}:/local" \
        swaggerapi/swagger-codegen-cli-v3:3.0.54 generate \
        -i /local/docs/api-specification/file-manager-api.yaml \
        -l python-flask \
        -o /local/file-manager-api-server \
        --additional-properties=packageName=file_manager_api

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Код сервера сгенерирован${NC}"
    else
        echo -e "${RED}Ошибка генерации кода сервера${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ API спецификация не найдена${NC}"
    exit 1
fi


# 3. Запуск Structurizr Lite
echo -e "${BLUE}[3/3] Запуск Structurizr Lite для просмотра диаграмм...${NC}"

DIAGRAM_PATH="$WIN_PATH/docs/c4-diagrams"
echo "Используем путь: $DIAGRAM_PATH"

# Проверяем наличие Docker
if ! docker ps &> /dev/null; then
    echo -e "${RED}Docker не запущен. Запустите Docker Desktop${NC}"
else
    # Останавливаем предыдущий контейнер если есть
    docker stop structurizr-lite 2>/dev/null
    
    echo "Запуск Structurizr Lite..."
    docker run --rm -d \
        --name structurizr-lite \
        -p 8080:8080 \
        -v "$DIAGRAM_PATH:/usr/local/structurizr" \
        structurizr/lite
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Structurizr Lite запущен${NC}"
        echo -e "${BLUE}Откройте в браузере:${NC} http://localhost:8080"
        echo -e "${YELLOW}Для остановки выполните:${NC} docker stop structurizr-lite"
    else
        echo -e "${RED}Ошибка запуска Structurizr Lite${NC}"
        echo -e "${YELLOW}Попробуйте вручную:${NC}"
        echo "docker run --rm -p 8080:8080 -v \"$DIAGRAM_PATH:/usr/local/structurizr\" structurizr/lite"
    fi
fi

echo -e "${BLUE}=== Генерация завершена ===${NC}"