Домашнее задание к занятию № 8 — «Управление пакетами. Дистрибьюция софта»
Оглавление
Запуск виртуальной машины
Создание RPM-пакета
Создание репозитория
Проверка
Проверка пакета
Проверка репозитория
Запуск виртуальной машины
Для создания виртуальной машины используется Vagrantfile со следующим содержимым:

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.provision "shell", path: "rpm.sh"
  config.vm.provision "shell", path: "repo.sh"
end
При выполнении команды vagrant up создаётся виртуальная машина с CentOS 7, внутри которой последовательно выполняются скрипты предварительной настройки rpm.sh и repo.sh. В первом скрипте создаётся RPM-пакет, во втором — репозиторий.

Создание RPM-пакета
Скрипт rpm.sh выполняет следующие действия:

Объявляет рабочим каталогом домашнюю директорию пользователя root:

cd /root
Устанавливает нужные для работы пакеты:

yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc
Загружает SRPM-пакет Nginx для дальнейшей работы над ним:

wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
Устанавливает загруженный пакет Nginx в домашнем каталоге пользователя root:

rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
Скачивает и разархивирует исходники для openssl:

wget https://www.openssl.org/source/latest.tar.gz
tar -xf latest.tar.gz
Устанавливает зависимости, чтобы в процессе сборки не было ошибок:

yum-builddep -y rpmbuild/SPECS/nginx.spec
Используя sed, добавляет параметр --with-openssl с путём до распакованных исходников в spec-файл, чтобы Nginx собирался с необходимыми опциями:

ospath="\    --with-openssl=/root/$(ls | grep openssl) \\\\"
sed -i "/\.\/configure/a $ospath" rpmbuild/SPECS/nginx.spec
Собирает RPM-пакет:

rpmbuild -bb rpmbuild/SPECS/nginx.spec
Уставливает собранный пакет, используя программу yum:

yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
Запускает службу Nginx:

systemctl start nginx
systemctl enable nginx
Создание репозитория
Скрипт repo.sh выполняет следующие действия:

Создаёт каталог repo в директории /usr/share/nginx/html:

mkdir /usr/share/nginx/html/repo
Копирует в этот каталог два RPM-пакета: пакет Nginx, собранный при выполнении предыдущего скрипта, и пакет для установки репозитория Percona-Server (предварительно загрузив его из сети):

cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
Инициализирует репозиторий:

createrepo /usr/share/nginx/html/repo/
Настраивает в Nginx доступ к листингу каталога: при помощи sed добавляет директиву autoindex on в location / в файле /etc/nginx/conf.d/default.conf и перезапускает Nginx:

sed -i '/index.html index.htm/a \        autoindex on;' /etc/nginx/conf.d/default.conf
nginx -s reload
Добавляет репозиторий в /etc/yum.repos.d:

cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
Проверка
Проверка пакета
Залогинимся на виртуальной машине командой vagrant ssh и выполним следующие действия:

Убедимся, что пакеты создались:

[vagrant@localhost ~]$ sudo ls -l /root/rpmbuild/RPMS/x86_64/
total 6048
-rw-r--r--. 1 root root 3639064 Jan 28 16:39 nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
-rw-r--r--. 1 root root 2548764 Jan 28 16:39 nginx-debuginfo-1.14.1-1.el7_4.ngx.x86_64.rpm
Проверим статус службы Nginx:

[vagrant@localhost ~]$ systemctl status nginx
● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2020-01-28 16:39:35 UTC; 2min 22s ago
     Docs: http://nginx.org/en/docs/
 Main PID: 29400 (nginx)
   CGroup: /system.slice/nginx.service
           ├─29400 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           └─29529 nginx: worker process
На хостовой машине в браузере откроем страницу http://192.168.33.10 (где IP-адрес — это адрес, указанный в Vagrantfile) и убедимся, что Nginx работает:
