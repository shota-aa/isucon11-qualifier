WEBHOOK_URL = ""

# Git関連変数
GIT_EMAIL = git@github.com
GIT_USERNAME = ISUCON-Server

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
