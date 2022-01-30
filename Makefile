WEBHOOK_URL = ""
SLOW_LOG = /var/log/mysql/mariadb-slow.log
KATARIBE_LOG = /var/log/nginx/access-with_time.log
ALP_LOG = /var/log/nginx/access-ltsv.log

GO_SERVICE_NAME = isucondition.go

# Git関連変数
GIT_EMAIL = git@github.com
GIT_USERNAME = ISUCON-Server

.PHONY: pre-bench
pre-bench: git-pull reset-ngx reset-mysql build

.PHONY: git-pull
git-pull:
	git pull

.PHONY: reset-ngx
reset-ngx:
	sudo rm /var/log/nginx/access-with_time.log
	sudo rm /var/log/nginx/access-ltsv.log
	sudo nginx -t
	sudo systemctl restart nginx

.PHONY: kataribe
cat-kataribe:
	sudo cat "$(KATARIBE_LOG)" | kataribe

.PHONY: set-alp
set-alp:
	wget https://github.com/tkuchiki/alp/releases/download/v0.4.0/alp_linux_amd64.zip
	sudo apt install unzip
	unzip alp_linux_amd64.zip
	sudo mv alp /usr/local/bin/alp

.PHONY: alp
alp:
	alp -f "$(ALP_LOG)" --avg -r

.PHONY: alp-sum
alp-sum:
	alp -f "$(ALP_LOG)" --sum -r

.PHONY: reset-mysql
reset-mysql:
	sudo rm -f $(SLOW_LOG)
	sudo systemctl restart mysql
	sudo systemctl restart mysqld
	sudo systemctl restart mariadb

.PHONY: slow
slow: 
	sudo mysqldumpslow -s t -t 10 "$(SLOW_LOG)"

# ビルドして、サービスのリスタートを行う
# リスタートを行わないと反映されないので注意
.PHONY: build
build:
	cd /home/isucon/webapp/go; \
	go build -o isucondition *.go; \
	sudo systemctl restart isucondition.go.service;

.PHONY: git-setuser
git-setuser:
	git config --global user.email "$(GIT_EMAIL)"
	git config --global user.name "$(GIT_USERNAME)"
	sudo git config --global user.email "$(GIT_EMAIL)"
	sudo git config --global user.name "$(GIT_USERNAME)"

.PHONY: send-pprof
send-pprof:
	go tool pprof -png -output /home/isucon/webapp/profile.png http://localhost:6060/debug/pprof/profile?seconds=60
	curl -X POST -F img=@/home/isucon/webapp/profile.png $(WEBHOOK_URL)

.PHONY: journal
journal:
	journalctl -u $(GO_SERVICE_NAME).service
