sudo yum -y update
sudo yum -y install nano
sudo cd /vagrant
sudo mkdir -p rpmbuild/RPMS/x86_64/
sudo mkdir -p rpmbuild/SPECS/
sudo mkdir -p mkdir /usr/share/nginx/html/repo

sudo yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils openssl-devel zlib-devel pcre-devel gcc libtool perl-core openssl

sudo wget wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm

sudo rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm

sudo wget https://www.openssl.org/source/latest.tar.gz

sudo tar -xf latest.tar.gz

sudo yum-builddep -y rpmbuild/SPECS/nginx.spec

sed -i 's/--with-debug/--with-openssl=\/rpmbuild\/openssl-1.1.1c/g' /rpmbuild/SPECS/nginx.spec

rpmbuild -bb /rpmbuild/SPECS/nginx.spec

sudo systemctl start nginx
sudo systemctl enable nginx

sudo cp /vagrant/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/

sudo wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm

sudo createrepo /usr/share/nginx/html/repo/

sudo sed -i '/index  index.html index.htm;/s/$/ \n\tautoindex on;/' /etc/nginx/conf.d/default.conf

sudo nginx -s reload

sudo cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=CentOS_7
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
sudo yum clean all

echo FINISH
