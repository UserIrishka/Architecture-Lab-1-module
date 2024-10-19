#!/bin/bash

# Проверяем, был ли передан аргумент (имя папки).
if [ $# -eq 0 ]; then
  echo "Необходимо указать имя папки в качестве аргумента."
  exit 1
fi

# Получаем имя папки из аргумента.
folder_name=$1

# Проверяем, существует ли папка.
if [ -d "$folder_name" ]; then
  echo "Папка с таким именем уже существует."
  exit 1
fi

# Создаем раздел на 1 ГБ.
dd if=/dev/zero of=/tmp/1GB_disk.img bs=1M count=1024
mkfs.ext4 /tmp/1GB_disk.img

# Создаем точку монтирования.
mkdir "$folder_name"

# Создаем три файла в папке.
cd "$folder_name"
touch file1.txt
touch file2.txt
touch file3.txt
touch file4.txt
touch file5.txt

# Выводим сообщение о завершении.
echo "Папка '$folder_name' создана с ограничением на 1 ГБ и пятью файлами."

# Размонтируем раздел.
umount "$folder_name"

# Удаляем временный файл образа диска.
rm /tmp/1GB_disk.img
