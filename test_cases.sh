#!/bin/bash

#Test 1
DIRECTORY="$1"
NUMBER="$2"
Test_n=1
echo -e
# Выводим сообщение с использованием переменных
echo "В тесте $Test_n,мы проверяем скрипт с: \"$DIRECTORY\" и числом $NUMBER"
# Вызываем 1ый скрипт, передавая переменные как аргументы
./example.sh "$DIRECTORY" "$NUMBER"

# Проверяем код возврата последней команды
if [ $? -eq 0 ]; then
        echo "Первый скрипт завершился успешно."
        echo "Тест $Test_n пройден"
else
        echo "Первый скрипт завершился с ошибкой. Первый скрипт вывел ошибку. Код возврата: $?"     
        echo "Тест $Test_n не пройден"
fi
echo -e

#TEST_2
Test_n=2
echo "В тесте номер $Test_n, мы проверяем, что будет, если запустить скрипт без аргументов"
# Путь к скрипту
SCRIPT="./example.sh"

# Время ожидания в секундах
TIMEOUT=10

# Запускаем скрипт с таймаутом и сохраняем вывод и код возврата
output=$(timeout $TIMEOUT $SCRIPT 2>&1)
exit_code=$?

# Проверяем, не истекло ли время ожидания
if [ $exit_code -eq 124 ]; then
    echo "Тест номер $Test_n не пройден: Скрипт не отвечает в течение $TIMEOUT секунд."
else
    # Ожидаемое сообщение об ошибке
 expected_output="Пожалуйста, передайте путь и количество файлов в виде аргументов"

    # Проверяем, что код возврата не равен 0 (что означает ошибку)
    if [ $exit_code -ne 0 ]; then
        echo "Тест номер $Test_n пройден: Скрипт завершился с ошибкой."
    else
        echo "Тест номер $Test_n не пройден: Скрипт завершился успешно, хотя должен был завершиться с ошибкой." 
    fi

    # Проверяем, содержит ли вывод ожидаемое сообщение об ошибке
    if [[ $output == *"$expected_output"* ]]; then
        echo "Вывод содержит ожидаемое сообщение об ошибке."
    else
        echo "Вывод не содержит ожидаемого сообщения об ошибке."
    fi
fi

#Test 3
DIRECTORY="$1"
NUMBER=two
Test_n=3
echo -e
echo " В тесте $Test_n, мы проверяем скрипт с: \"$DIRECTORY\" и числом $NUMBER"
echo "(Передан верный формат пути, но неверный - n)"

./example.sh "$DIRECTORY" "$NUMBER"

# Проверяем код возврата последней команды
if [ $? -eq 0 ]; then
        echo "Первый скрипт завершился успешно."
        echo "Тест $Test_n пройден"
else
        echo "Первый скрипт завершился с выводом ошибки. Код возврата: $?."
        echo "Тест $Test_n пройден"
fi


#TEST_4
echo -e
DIRECTORY="$1"
NUMBER=13
Test_n=4
echo "В тесте $Test_n, мы проверяем скрипт с: \"$DIRECTORY\" и числом $NUMBER"
echo "(верный путь, но нет возможности архивировать такое кол-во файлов)"
./example.sh "$DIRECTORY" "$NUMBER"
# Проверяем код возврата последней команды
if [ $? -eq 0 ]; then
        echo "Скрипт завершился успешно."
        echo "Тест $Test_n пройден"
else
        echo "Первый скрипт завершился с выводом ошибки. Код возврата: $?."
        echo "Тест $Test_n пройден."
fi



#Test5
echo -e
Test_n=5
echo "В тесте $Test_n, мы проверяем скрипт при условии, что папка занята меньше, чем на 70%"
# Установка временной директории для тестирования
test_folder=$(mktemp -d)
echo "Создана временная директория: $test_folder"

# Создание тестовых файлов
for i in {1..2}; do
    echo "Тестовый файл $i" > "$test_folder/file$i.txt"
done

# Получение размера папки
res=$(du -s "$test_folder" | awk '{print $1}')
load=$(du -s "$test_folder"/* | awk '{sum += $1} END {print sum}')

#echo "Размер папки: $res"
#echo "Размер загруженных файлов: $load"

if [ "$res" -ne 0 ]; then
        percentage=$((($load * 100) / $res))
else
        percentage=0
fi
echo "Папка $folder заполнена на $percentage%"

# Проверка, что размер папки меньше 70%
if [ "$percentage" -lt 70 ]; then
    echo "Папка заполнена менее чем на 70%, запускаем тест с основным скриптом..."
    echo -e
    echo "Работа первого скрипта:"
    # Вызов основного скрипта
    ./example.sh "$test_folder" 2
    if [ $? -eq 0 ]; then
        echo "Первый скрипт завершился успешно."
        echo "Тест $Test_n пройден"
    else
        echo "Первый скрипт завершился с ошибкой."
        echo "Тест $Test_n не пройден"
    fi
else
    echo "Папка заполнена более чем на 70%, тест не имеет смысла."
fi

# Очистка временной директории
rm -rf "$test_folder"
echo "Тест завершен, временная директория удалена."
