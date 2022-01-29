WEBHOOK_URL = ""

# Git関連変数
GIT_EMAIL = git@github.com
GIT_USERNAME = ISUCON-Server

.PHONY: restart-nginx
restart-nginx:
	sudo rm /var/log/nginx/access-with_time.log
	sudo rm /var/log/nginx/access-ltsv.log
	sudo nginx -t
	sudo systemctl restart nginx

.PHONY: cat-kataribe
cat-kataribe:
	sudo cat /var/log/nginx/access-with_time.log | kataribe

# alp
ALP_SORT = sum

.PHONY: set-alp
set-alp:
	wget https://github.com/tkuchiki/alp/releases/download/v0.4.0/alp_linux_amd64.zip
	sudo apt install unzip
	unzip alp_linux_amd64.zip
	sudo mv alp /usr/local/bin/alp

.PHONY: alp
alp:
	alp -f /var/log/nginx/access-ltsv.log --"$(ALP_SORT)"

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
