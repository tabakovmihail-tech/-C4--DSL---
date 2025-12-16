package com.example.structurizr;

import java.io.File;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.structurizr.Workspace;
import com.structurizr.model.Container;
import com.structurizr.model.Model;
import com.structurizr.model.Person;
import com.structurizr.model.SoftwareSystem;
import com.structurizr.model.Tags;
import com.structurizr.view.ContainerView;
import com.structurizr.view.Shape;
import com.structurizr.view.Styles;
import com.structurizr.view.SystemContextView;
import com.structurizr.view.ViewSet;

public class FileManagerModel {
    public static void main(String[] args) throws Exception {
        // ======================= Workspace ======================
        Workspace workspace = new Workspace(
                "File Manager",
                "C4-модель настольного файлового менеджера"
        );
        Model model = workspace.getModel();

        // ======================= Уровень 1: System Context ======================
        Person user = model.addPerson("Пользователь", "Работает с файлами через графический интерфейс");
        SoftwareSystem fileManager = model.addSoftwareSystem("Файловый менеджер", "Настольное приложение");
        SoftwareSystem operatingSystem = model.addSoftwareSystem("Операционная система", "Файловая система и API");

        user.uses(fileManager, "Просматривает дерево каталогов, выполняет операции");
        fileManager.uses(operatingSystem, "Выполняет операции через системные API");

        // ======================= Уровень 2: Containers ======================
        Container desktopApp = fileManager.addContainer(
                "Desktop GUI Application",
                "Графический интерфейс файлового менеджера",
                "Python + PyQt5/tkinter"
        );

        Container fileOpsModule = fileManager.addContainer(
                "File Operations Module",
                "Модуль выполнения операций над файлами",
                "Python"
        );

        Container localStorage = fileManager.addContainer(
                "Local Storage",
                "Локальное хранилище настроек",
                "JSON / SQLite"
        );

        // Связи между контейнерами
        user.uses(desktopApp, "Взаимодействует через GUI");
        desktopApp.uses(fileOpsModule, "Передает команды");
        desktopApp.uses(localStorage, "Читает и сохраняет настройки");
        fileOpsModule.uses(operatingSystem, "Выполняет операции");
        fileOpsModule.uses(localStorage, "Записывает логи");

        // ======================= Views (диаграммы) ======================
        ViewSet views = workspace.getViews();

        SystemContextView contextView = views.createSystemContextView(
                fileManager, "SystemContext", "Контекстная диаграмма"
        );
        contextView.addAllSoftwareSystems();
        contextView.addAllPeople();

        ContainerView containerView = views.createContainerView(
                fileManager, "Containers", "Контейнеры"
        );
        containerView.addAllContainers();
        containerView.add(user);
        containerView.add(operatingSystem);

        // ======================= Styles ======================
        Styles styles = views.getConfiguration().getStyles();
        styles.addElementStyle(Tags.PERSON)
                .background("#08427b").color("#ffffff").shape(Shape.Person);
        styles.addElementStyle(Tags.SOFTWARE_SYSTEM)
                .background("#1168bd").color("#ffffff");
        styles.addElementStyle(Tags.CONTAINER)
                .background("#438dd5").color("#ffffff");

        // ======================= Сохранение workspace ======================
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.enable(SerializationFeature.INDENT_OUTPUT);
            objectMapper.disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);
            
            File output = new File("file-manager-workspace.json");
            objectMapper.writeValue(output, workspace);
            
            System.out.println("✅ Workspace успешно сохранён: " + output.getAbsolutePath());
            System.out.println("📁 Файл: " + output.getAbsolutePath());
        } catch (Exception e) {
            System.err.println("❌ Ошибка при сохранении: " + e.getMessage());
            e.printStackTrace();
        }
    }
}