#!/bin/bash

folder=$1
n=$2

# Проверка на количество аргументов
if [ "$#" -ne 2 ]; then
    echo "Ошибка: требуется 2 аргумента (путь и число)."
    exit 1
fi

# Проверка корректности пути
if [ ! -d "$folder" ]; then
    echo "Ошибка: Директория \"$folder\" не существует."
    exit 1
fi

# Проверка корректности числа
if ! [[ "$n" =~ ^[0-9]+$ ]]; then
    echo "Ошибка: Значение \"$n\" не является корректным числом."
    exit 1
fi

# Если все проверки пройдены
echo "Проверка пройдена. Директория и число корректны."

#проценты
#для суперпользователя нужно использовать sudo du
res=$(du -s $folder | awk '{print $1}')
load=$(du -s $folder/* | awk '{sum += $1} END {print sum}')

if [ "$res" -ne 0 ]; then
        percentage=$((($load * 100) / $res))
else
        percentage=0
fi
echo "Папка $folder заполнена на $percentage%"

# Проверка, заполнена ли папка более чем на 70%
if [ "$percentage" -gt 70 ]; then
    echo "Папка заполнена более чем на 70%, начинаем архивацию..."
# Используем временный файл для хранения подходящих файлов
        temp_file=$(mktemp)


# Находим файлы, измененные за последние 30 дней, и сохраняем в temp_file
        echo "Список всех файлов в папке:"
        for file in "$folder"/*; do
            if [ -f "$file" ]; then
                timestamp=$(stat -c %Y "$file")
                if [ "$timestamp" -gt "$(date -d '30 days ago' +%s)" ]; then
                        echo "$timestamp $file" >> "$temp_file"
                         human_readable_date=$(date -d "@$timestamp" "+%Y-%m-%d %H:%M:%S")
                        echo "$human_readable_date $file"
                fi
            fi
        done | sort -rn

        oldest_files=$(sort -n "$temp_file" | head -n "$n" | awk '{print $2}')

        echo "Выбранные файлы для архивации:"
        if [ -z "$oldest_files" ]; then
            echo "Нет файлов для архивирования."
        else
            files_array=()
            for file in $oldest_files; do
                if [ -f "$file" ]; then
                    human_readable_date=$(date -d "@$(stat -c %Y "$file")" "+%Y-%m-%d %H:%M:%S")
                    echo "$human_readable_date ${file##8/}"
                    files_array+=("$file")  # Добавляем полный путь к файлу
                else
                    echo "Файл не существует: $file"
                fi
            done


        # Определяем путь к архиву
            archive_file="$folder/archive.tar.gz"

            # Создаем архив с N(N=2) самыми старыми файлами
            #для суперпользователя нужно использовать sudo tar        
            tar -zcf "$archive_file" -C "$folder" "${files_array[@]}" -P

            echo "Архив создан: $archive_file"

        # Удаляем файлы после архивирования #для суперпользователя нужно использовать sudo rm
            for file in "${files_array[@]}"; do
                echo "Удаляем файл: $file"
                rm "$file"
            done
        fi
        rm "$temp_file"
else
        echo "Папка заполнена не больше, чем на 70%. Архивация не нужна."
fi

