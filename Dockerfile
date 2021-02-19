FROM python:3
# Install libmariadb3 from MariaDB repository, because Debian Buster have broken package
# See:
# - https://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg1749639.html
# - https://packages.debian.org/sid/amd64/libmariadb3/filelist - have caching_sha2_password.so
# - https://packages.debian.org/buster/amd64/libmariadb3/filelist - missing caching_sha2_password.so
# - https://packages.debian.org/bullseye/amd64/libmariadb3/filelist - have caching_sha2_password.so 
RUN apt-get update \
&& apt-get install -y --no-install-recommends software-properties-common dirmngr \
&& apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc' \
&& VERSION_CODENAME=$(sed -E -n 's/VERSION=.*\((.+?)\).*$/\1/gp' /etc/os-release) \
&& add-apt-repository "deb [arch=amd64,arm64,ppc64el] https://mirrors.chroot.ro/mariadb/repo/10.5/debian $VERSION_CODENAME main" \
&& apt-get update \
&& apt-get install -y libmariadb3 \
&& rm -rf /var/lib/apt/lists/*
RUN pip install django mysqlclient
CMD sh -c "python manage.py migrate; python manage.py runserver"