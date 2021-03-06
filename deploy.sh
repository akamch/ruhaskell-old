#!/bin/bash

# Скрипт для для автоматического обновления сайта на GitHub Pages. 

USAGE="Запускаем так: ./deploy.sh [\"Сообщение о коммите\"]

Пример:
  ./deploy.sh \"Обновление стиля.\"
  ./deploy.sh

Во втором случае разворачивание происходит без коммита, это удобно при pull request.
" 

# При любой ошибке скрипт вылетает...
set -e

# Устанавливаем переменную, для нашего коммит-сообщения...  
COMMIT_MESSAGE=$1

echo "Учитываем изменения в ветке master, если таковые имеются..."
if [ "$1" != "" ]
then
    # Сообщение о коммите задано, значит коммитим изменения в ветку master...
    git add .
    git commit -a -m "$COMMIT_MESSAGE"
    git push -f origin master
fi

echo "Собираем новую версию сайта..."
./just_build.sh

echo "Копируем во временное место, предварительно удалив старое, если нужно..."
rm -rf /tmp/_site/ || true 1> /dev/null
cp -R _site /tmp/

echo "Переключаемся на ветку 'gh-pages'..."
git checkout gh-pages

echo "Копируем прямо в корень содержимое подготовленного каталога _site..."
cp -R /tmp/_site/* .

echo "Учитываем все последние новшества, если таковые имеются, и публикуем на GitHub Pages..."
if [ "$1" != "" ]
then
    # Сообщение о коммите задано, следовательно в ветке gh-pages тоже произошли изменения...
    git add .
    git commit -a -m "$COMMIT_MESSAGE"
    git push -f origin gh-pages
fi

echo "Возвращаемся в мастер..."
git checkout master

echo "Готово!"
