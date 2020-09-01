**Домашнее задание № 5
«Управление пакетами. Дистрибьюция софта»**

**Для создания виртуальной машины используется Vagrantfile со следующим содержимым:**

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.network "private_network", ip: "192.168.189.10"
  config.vm.provision "shell", path: "scripts.sh"
end
```

**При выполнении команды vagrant up создаётся виртуальная машина с CentOS 7, внутри которой выполняется скрипт scripts.sh

**Скрипт scripts.sh делает следующее**

**Устанавливаем нужные для работы пакеты**

**Обновляем систему**

```
sudo yum -y update
```

**Устанавливает текстовый редактор NANO**

```
sudo yum -y install nano
```

**Устанавливаем WGET, для загрузки пакетов**

```
sudo yum -y install wget
```
**Создаем дерево папок для nginx и для репозитория**

```
sudo mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

sudo mkdir -p usr/share/nginx/html/repo

```

**Устанавливаем необходимые пакеты**

```
sudo yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc
```
**Загружает SRPM-пакет Nginx**

```
sudo wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
```

**Устанавливает загруженный Nginx**

```
sudo rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
```

**Скачиваем и разархивируем файлы для openssl**

```
sudo wget https://www.openssl.org/source/latest.tar.gz
tar -xf latest.tar.gz
```

**Производим соборку RPM-пакета**

```
sudo rpmbuild -bb rpmbuild/SPECS/nginx.spec
```

**Уставливает собранный пакет, используя программу yum**

```
sudo yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
```

**Запустим сервис Nginx**

```
systemctl start nginx
systemctl enable nginx
```

**Создадим репозиторий**

**Копируем в этот каталог /usr/share/nginx/html/repo/ два RPM-пакета: пакет Nginx, собранный ранее. также скачаем RPM для postgresql**

```
sudo cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
sudo wget https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm -O /usr/share/nginx/html/repo/pgdg-redhat96-9.6-3.noarch.rpm
```
**Инициализируем репозиторий**

```
createrepo /usr/share/nginx/html/repo/
```

**Настраиваем в Nginx доступ к просмотру каталога, для этого вносим изменения в файле /etc/nginx/conf.d/default.conf**

```
sed -i '/index.html index.htm/a \        autoindex on;' /etc/nginx/conf.d/default.conf
```
**Перезапустим nginx для применения изменений**

```
nginx -s reload
```
**проверим**

```
[vagrant@localhost ~]$ sudo systemctl start nginx
[vagrant@localhost ~]$ nginx -V
nginx version: nginx/1.18.0
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-39) (GCC)
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
```
На хостовой машине в браузере откроем страницу http://192.168.189.10 (где IP-адрес — это адрес, указанный в Vagrantfile) и убедимся, что Nginx работает:
https://github.com/MaksimDor/HomeWork_5_RPM/blob/master/foto%20ngenx.JPG
