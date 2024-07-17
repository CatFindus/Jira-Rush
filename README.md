## [REST API](http://localhost:8080/doc)

## Концепция:

- Spring Modulith
    - [Spring Modulith: достигли ли мы зрелости модульности](https://habr.com/ru/post/701984/)
    - [Introducing Spring Modulith](https://spring.io/blog/2022/10/21/introducing-spring-modulith)
    - [Spring Modulith - Reference documentation](https://docs.spring.io/spring-modulith/docs/current-SNAPSHOT/reference/html/)

```
  url: jdbc:postgresql://localhost:5432/jira
  username: jira
  password: JiraRush
```

- Есть 2 общие таблицы, на которых не fk
    - _Reference_ - справочник. Связь делаем по _code_ (по id нельзя, тк id привязано к окружению-конкретной базе)
    - _UserBelong_ - привязка юзеров с типом (owner, lead, ...) к объекту (таска, проект, спринт, ...). FK вручную будем
      проверять

## Аналоги

- https://java-source.net/open-source/issue-trackers

## Тестирование

- https://habr.com/ru/articles/259055/

Список выполненных задач:

Task 2:Удалить социальные сети: vk, yandex.
Отредаткирован application.yaml убраны OAUTH2 конфигурации, отредактированы HTML файлы login.html, register.html. Убраны элементы соответсвующие VK и Яндекс. Отредакирован all.css убраны стили соответствующие VK и Яндекс.

Task 3:Вынести чувствительную информацию в отдельный проперти файл:
 - логин
 - пароль БД
 - идентификаторы для OAuth регистрации/авторизации
 - настройки почты
 - Значения этих проперти должны считываться при старте сервера из переменных окружения машины
Создан файл secret.properties. В него вынесены конфеденциальные данные в соответсвии с заданием. Отредактирован файл application.yaml.
Задание значений достурно через переменные: DB_USERNAME, DB_PASSWORD, OAUTH2_GITHUB_CLIENT_ID, OAUTH2_GITHUB_CLIENT_SECRET, OAUTH2_GOOGLE_CLIENT_ID, OAUTH2_GOOGLE_CLIENT_SECRET, OAUTH2_GITLAB_CLIENT_ID, OAUTH2_GITLAB_CLIENT_SECRET, MAIL_USERNAME, MAIL_PASSWORD.

Task 4:Переделать тесты так, чтоб во время тестов использовалась in memory БД (H2), а не PostgreSQL. Для этого нужно определить 2 бина, и выборка какой из них использовать должно определяться активным профилем Spring. H2 не поддерживает все фичи, которые есть у PostgreSQL, поэтому тебе прийдется немного упростить скрипты с тестовыми данными.
Тестирование переделано на in memory DB H2. Отредактирован application-test.yaml, подключена база H2.
Создан changelog-test.sql с откорректированными для H2 скриптами. Отредактирован data.sql для возможности использования с DB H2.
Отредактирован класс AbstractControllerTest для использования с новым файлом changelog-test.sql.

Task 5: Написать тесты для всех публичных методов контроллера ProfileRestController. Хоть методов только 2, но тестовых методов должно быть больше, т.к. нужно проверить success and unsuccess path.
Написаны тесты для ProfileRestController. Чтобы сделать тесты пришлось изменить название колонки c "value" на "val" в таблице contact т.к hibernate при запросе сыпался. Value является для h2 зарезервированным именем. Пытался обойти это кастомным репозиторием с нативными запросами, но тогда не подгружаются связанные сущности. Короче решение не очень, но по другому победить не удалось. 
Так же удалил 2 handler пропущенные во 2м задании.

Task 6:Сделать рефакторинг метода com.javarush.jira.bugtracking.attachment.FileUtil#upload чтоб он использовал современный подход для работы с файловой системмой.
Отрефакторен метод upload в классе FileUtil. Метод переделан на nio;